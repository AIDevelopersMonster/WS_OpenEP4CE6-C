// ------------------------------------------------------------
//  Module     : i2c
//  Project    : AT24CXX (24C02/04/08/16...) I2C EEPROM demo
//  Board      : WS_OpenEP4CE6-C (и совместимые платы)
//  Author     : original CN design + русские комментарии ChatGPT
//  Description:
//    Пример работы с I2C-EEPROM AT24CXX:
//      - по нажатию кнопки записи записывает байт data_in в
//        фиксированный адрес addr (в примере = 10)
//      - по нажатию кнопки чтения считывает байт из того же адреса
//      - на двухразрядном 7-сегментном индикаторе отображается
//        записанное и считанное значение (в шестнадцатеричном виде)
//
//    Китайский тестовый код:
//      - если PIN_45 притянут к земле, индикатор показывает 0, F,
//        0, D, 0, B, 0, 7  (тест сегментов)
//      - при обмене по I2C периодически пищит буззер (на верхнем модуле)
//
//    Данный модуль:
//      - формирует I2C-тактовую SCL из системного clk
//      - генерирует старт/стоп, отправку адреса и данных, приём данных,
//        ACK/NACK в соответствии с протоколом I2C
//      - мультиплексирует два разряда 7-сегментного индикатора,
//        отображая writeData_reg и readData_reg
//
//  I/O:
//    clk       – системная частота (например, 50 МГц)
//    rst       – асинхронный сброс (активный низкий)
//    data_in   – 4-битный код данных для записи в EEPROM
//    wr_input  – кнопка записи (активный низкий)
//    rd_input  – кнопка чтения (активный низкий)
//    scl       – линия I2C SCL
//    sda       – линия I2C SDA (двунаправленная, открытый коллектор)
//    lowbit    – вывод младшей точки / индикатора (в данном демо = 0)
//    en[1:0]   – выбор разряда 7-сегментного индикатора
//    seg_data  – код сегментов (активный низкий)
//    dgnd[5:0] – «земля» для остальных индикаторов (зажаты в 0)
// ------------------------------------------------------------

/***************************************************************************************************************
IIC test  have  done
if PIN_45 have been putdown ,then the seg will display  0f 0d 0b 07 
we write the data to  the  24cX in specified address , then  read the data from the same address and display it
***************************************************************************************************************/

module i2c(
    clk,
    rst,
    data_in,
    scl,
    sda,
    wr_input,
    rd_input,
    lowbit,
    en,
    seg_data,
    dgnd
);

    // Выходы управления индикатором (подключение к мультиплексору индикаторов платы)
    output [5:0] dgnd;     // остальные разряды индикатора всегда в «0» (отключены)
    input  clk, rst;

    // I2C линии
    output scl;
    inout  sda;

    // Входные данные и кнопки
    input  [3:0] data_in;  // 4-битные данные для записи (будут упакованы в writeData_reg)
    input  wr_input;       // кнопка «запись» (активный низкий)
    input  rd_input;       // кнопка «чтение» (активный низкий)

    // Управление индикатором
    output       lowbit;   // младшая точка / дополнительный вывод (здесь просто 0)
    output [1:0] en;       // выбор разряда
    output [7:0] seg_data; // код сегментов (активный низкий)
    reg    [7:0] seg_data;

    // ---------------------------------
    // Внутренние сигналы
    // ---------------------------------
    reg scl;               // линия SCL формируется вручную
    reg [1:0] en;          // регистр выбора разряда индикатора

    reg [7:0] seg_data_buf;     // буфер данных для индикатора
    reg [23:0] cnt_scan;        // счётчик для мультиплексирования индикатора

    reg sda_buf;           // внутренний регистр для вывода на SDA
    reg link;              // 1 – мы управляем SDA, 0 – линия отпущена (Z)

    // Четыре фазы внутри периода SCL для удобной организации протокола
    reg phase0, phase1, phase2, phase3;

    reg [7:0] clk_div;     // делитель для I2C такта
    reg [1:0] main_state;  // верхний автомат: 00 – ожидание, 01 – запись, 10 – чтение
    reg [2:0] i2c_state;   // состояние I2C автомата: ini, sendaddr, write_data, read_data, read_ini
    reg [3:0] inner_state; // «подсостояние» внутри отправки байта: start, first..eighth, ack, stop
    reg [19:0] cnt_delay;  // грубая задержка между операциями
    reg start_delaycnt;    // флаг запуска счетчика задержки

    reg [7:0] writeData_reg;    // байт для записи в EEPROM
    reg [7:0] readData_reg;     // байт, считанный из EEPROM
    reg [7:0] addr;             // адрес ячейки EEPROM (в примере фиксированное значение)

    // ---------------------------------
    // Параметры делителя для I2C
    // ---------------------------------
    parameter div_parameter = 100;  // полный период внутреннего делителя

    // Подсостояния для inner_state — битовая машинка для передачи байта по I2C
    parameter  start   = 4'b0000, 
               first   = 4'b0001,
               second  = 4'b0010,
               third   = 4'b0011, 
               fourth  = 4'b0100, 
               fifth   = 4'b0101, 
               sixth   = 4'b0110, 
               seventh = 4'b0111, 
               eighth  = 4'b1000, 
               ack     = 4'b1001,   
               stop    = 4'b1010; 

    // Состояния i2c_state – этапы транзакции I2C
    parameter ini       = 3'b000,  // начальная стадия – отправка адреса устройства
              sendaddr  = 3'b001,  // отправка адреса ячейки памяти
              write_data= 3'b010,  // отправка данных на запись
              read_data = 3'b011,  // приём данных при чтении
              read_ini  = 3'b100;  // повторный старт и установка режима чтения

    // Все дополнительные «земли» индикатора притянуты к 0 (не используются)
    assign dgnd   = 6'b000000;

    // Точка/младший разряд пока не используется – просто 0
    assign lowbit = 0;

    // Линия SDA: если link=1 – выводим sda_buf, если 0 – Z (открытый коллектор)
    assign sda = (link) ? sda_buf : 1'bz;

    // ---------------------------------
    // Счётчик задержки между операциями
    // ---------------------------------
    always @(posedge clk or negedge rst)
    begin
        if (!rst)
            cnt_delay <= 0;
        else begin
            if (start_delaycnt) begin
                // простая «пауза» между операциями записи/чтения
                if (cnt_delay != 20'd800000)
                    cnt_delay <= cnt_delay + 1;
                else
                    cnt_delay <= 0;
            end
        end
    end

    // ---------------------------------
    // Формирование четырёх фаз внутри периода I2C
    // clk_div бегает от 0 до div_parameter-1, а в нужные моменты
    // поднимаются флажки phase0..phase3 (один такт clk каждый).
    // ---------------------------------
    always @(posedge clk or negedge rst)
    begin
        if (!rst) begin
            clk_div <= 0;
            phase0  <= 0;
            phase1  <= 0;
            phase2  <= 0;
            phase3  <= 0;
        end
        else begin
            if (clk_div != div_parameter - 1)
                clk_div <= clk_div + 1;
            else
                clk_div <= 0;

            // Каждая фаза – одиночный импульс в разных точках периода делителя
            if (phase0)
                phase0 <= 0;
            else if (clk_div == 99) 
                phase0 <= 1;

            if (phase1)
                phase1 <= 0;
            else if (clk_div == 24)
                phase1 <= 1;

            if (phase2)
                phase2 <= 0;
            else if (clk_div == 49)
                phase2 <= 1;

            if (phase3)
                phase3 <= 0;
            else if (clk_div == 74)
                phase3 <= 1;
        end
    end

    // ============================================================================
    //                     ОСНОВНОЙ АВТОМАТ РАБОТЫ С EEPROM
    // ============================================================================
    // main_state:
    //   00 – ожидание нажатия кнопки записи/чтения
    //   01 – цикл записи байта в EEPROM
    //   10 – цикл чтения байта из EEPROM
    // Внутри используются i2c_state и inner_state для бит-уровневого протокола.
    // ============================================================================
    always @(posedge clk or negedge rst)
    begin
        if (!rst) begin
            start_delaycnt <= 0;
            main_state     <= 2'b00;
            i2c_state      <= ini;
            inner_state    <= start;
            scl            <= 1;   // линия SCL в «1» при простое
            sda_buf        <= 1;   // SDA тоже в «1» (шина свободна)
            link           <= 0;   // не держим шину
            writeData_reg  <= 5;   // какое-то стартовое значение
            readData_reg   <= 0;
            addr           <= 10;  // адрес ячейки EEPROM
        end
        else begin
            case (main_state)
                // ------------------------------------------------------------
                // main_state = 2'b00 : режим ожидания
                // ------------------------------------------------------------
                2'b00: begin  
                    // захватываем новые данные для записи из входов
                    writeData_reg <= data_in;
                    scl           <= 1;
                    sda_buf       <= 1;
                    link          <= 0;
                    inner_state   <= start;
                    i2c_state     <= ini;

                    // ждём, пока истечёт пауза и будет нажата кнопка
                    if ((cnt_delay == 0) && (!wr_input || !rd_input))
                        start_delaycnt <= 1;
                    else if (cnt_delay == 20'd800000) begin
                        start_delaycnt <= 0;
                        if (!wr_input)           // запись
                            main_state <= 2'b01;
                        else if (!rd_input)      // чтение
                            main_state <= 2'b10;
                    end
                end

                // ------------------------------------------------------------
                // main_state = 2'b01 : цикл записи байта в EEPROM
                // ------------------------------------------------------------
                2'b01: begin  
                    // Формируем SCL: high на phase0, low на phase2
                    if (phase0)
                        scl <= 1;
                    else if (phase2)
                        scl <= 0;

                    // Внутренний автомат протокола I2C
                    case (i2c_state)
                        // ------------------------------------------------
                        // ini: старт, отправка адреса устройства (0xA0)
                        // ------------------------------------------------
                        ini: begin   
                            case (inner_state)
                                // Старт-условие: SDA падает при высоком SCL
                                start: begin
                                    if (phase1) begin
                                        link    <= 1;
                                        sda_buf <= 0;
                                    end
                                    if (phase3 && link) begin
                                        inner_state <= first;
                                        sda_buf     <= 1;
                                        link        <= 1;
                                    end
                                end

                                // Дальше идёт побитовая отправка адреса устройства + бит R/W
                                // Здесь прошиты конкретные биты для стандартного адреса 24CXX.
                                first: 
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= second;
                                    end
                                second:
                                    if (phase3) begin
                                        sda_buf     <= 1;
                                        link        <= 1;
                                        inner_state <= third;
                                    end
                                third:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= fourth;
                                    end
                                fourth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= fifth;
                                    end
                                fifth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= sixth;
                                    end
                                sixth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= seventh;
                                    end
                                seventh:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= eighth;
                                    end
                                eighth:
                                    if (phase3) begin
                                        link        <= 0;    // отпускаем SDA – ждём ACK от EEPROM
                                        inner_state <= ack;
                                    end

                                // Чтение ACK от устройства
                                ack: begin
                                    if (phase0) 
                                        sda_buf <= sda;     // считываем текущий уровень SDA
                                    if (phase1) begin
                                        if (sda_buf == 1)   // нет ACK – сброс в ожидание
                                            main_state <= 2'b00;
                                    end
                                    if (phase3) begin
                                        // успешный ACK – переходим к отправке адреса ячейки
                                        link        <= 1;
                                        sda_buf     <= addr[7];
                                        inner_state <= first;
                                        i2c_state   <= sendaddr;
                                    end
                                end
                            endcase
                        end

                        // ------------------------------------------------
                        // sendaddr: отправка адреса ячейки EEPROM (addr)
                        // ------------------------------------------------
                        sendaddr: begin
                            case (inner_state)
                                first: 
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[6];
                                        inner_state <= second;
                                    end
                                second:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[5];
                                        inner_state <= third;
                                    end
                                third:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[4];
                                        inner_state <= fourth;
                                    end
                                fourth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[3];
                                        inner_state <= fifth;
                                    end
                                fifth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[2];
                                        inner_state <= sixth;
                                    end
                                sixth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[1];
                                        inner_state <= seventh;
                                    end
                                seventh:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[0];
                                        inner_state <= eighth;
                                    end
                                eighth:
                                    if (phase3) begin
                                        link        <= 0;
                                        inner_state <= ack;
                                    end
                                ack: begin
                                    if (phase0) 
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        if (sda_buf == 1) 
                                            main_state <= 2'b00;
                                    end
                                    if (phase3) begin
                                        // После ACK отправляем байт данных на запись
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[7];
                                        inner_state <= first;
                                        i2c_state   <= write_data;
                                    end
                                end
                            endcase
                        end

                        // ------------------------------------------------
                        // write_data: отправка байта данных в EEPROM
                        // ------------------------------------------------
                        write_data: begin
                            case (inner_state)
                                first: 
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[6];
                                        inner_state <= second;
                                    end
                                second:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[5];
                                        inner_state <= third;
                                    end
                                third:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[4];
                                        inner_state <= fourth;
                                    end
                                fourth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[3];
                                        inner_state <= fifth;
                                    end
                                fifth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[2];
                                        inner_state <= sixth;
                                    end
                                sixth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[1];
                                        inner_state <= seventh;
                                    end
                                seventh:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= writeData_reg[0];
                                        inner_state <= eighth;
                                    end
                                eighth:
                                    if (phase3) begin
                                        link        <= 0;
                                        inner_state <= ack;
                                    end
                                ack: begin
                                    if (phase0) 
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        if (sda_buf == 1) 
                                            main_state <= 2'b00;
                                    end
                                    else if (phase3) begin
                                        // После ACK формируем стоп-условие
                                        link        <= 1;
                                        sda_buf     <= 0;
                                        inner_state <= stop;
                                    end
                                end
                                stop: begin
                                    if (phase1)
                                        sda_buf <= 1;   // SDA вверх при высоком SCL – STOP
                                    if (phase3) 
                                        main_state <= 2'b00;
                                end
                            endcase
                        end

                        default:
                            main_state <= 2'b00;
                    endcase
                end

                // ------------------------------------------------------------
                // main_state = 2'b10 : цикл чтения байта из EEPROM
                // ------------------------------------------------------------
                2'b10: begin 
                    // Формирование SCL
                    if (phase0)
                        scl <= 1;
                    else if (phase2)
                        scl <= 0;

                    case (i2c_state)
                        // Аналогично ветке записи – сначала отправка адреса устройства на запись
                        ini: begin   
                            case (inner_state)
                                start: begin
                                    if (phase1) begin
                                        link    <= 1;
                                        sda_buf <= 0;
                                    end
                                    if (phase3 && link) begin
                                        inner_state <= first;
                                        sda_buf     <= 1;
                                        link        <= 1;
                                    end
                                end
                                first: 
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= second;
                                    end
                                second:
                                    if (phase3) begin
                                        sda_buf     <= 1;
                                        link        <= 1;
                                        inner_state <= third;
                                    end
                                third:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= fourth;
                                    end
                                fourth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= fifth;
                                    end
                                fifth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= sixth;
                                    end
                                sixth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= seventh;
                                    end
                                seventh:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= eighth;
                                    end
                                eighth:
                                    if (phase3) begin
                                        link        <= 0;
                                        inner_state <= ack;
                                    end
                                ack: begin
                                    if (phase0) 
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        if (sda_buf == 1) 
                                            main_state <= 2'b00;
                                    end
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[7];
                                        inner_state <= first;
                                        i2c_state   <= sendaddr;
                                    end
                                end
                            endcase
                        end

                        // Отправка адреса ячейки так же, как при записи
                        sendaddr: begin
                            case (inner_state)
                                first: 
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[6];
                                        inner_state <= second;
                                    end
                                second:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[5];
                                        inner_state <= third;
                                    end
                                third:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[4];
                                        inner_state <= fourth;
                                    end
                                fourth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[3];
                                        inner_state <= fifth;
                                    end
                                fifth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[2];
                                        inner_state <= sixth;
                                    end
                                sixth:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[1];
                                        inner_state <= seventh;
                                    end
                                seventh:
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= addr[0];
                                        inner_state <= eighth;
                                    end
                                eighth:
                                    if (phase3) begin
                                        link        <= 0;
                                        inner_state <= ack;
                                    end
                                ack: begin
                                    if (phase0) 
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        if (sda_buf == 1) 
                                            main_state <= 2'b00;
                                    end
                                    if (phase3) begin
                                        // После этого готовим повторный старт в режиме чтения
                                        link        <= 1;
                                        sda_buf     <= 1;
                                        inner_state <= start;
                                        i2c_state   <= read_ini;
                                    end
                                end
                            endcase
                        end

                        // read_ini: повторный старт и установка чтения
                        read_ini: begin 
                            case (inner_state)
                                start: begin
                                    if (phase1) begin
                                        link    <= 1;
                                        sda_buf <= 0;
                                    end
                                    if (phase3 && link) begin
                                        inner_state <= first;
                                        sda_buf     <= 1;
                                        link        <= 1;
                                    end
                                end
                                first: 
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= second;
                                    end
                                second:
                                    if (phase3) begin
                                        sda_buf     <= 1;
                                        link        <= 1;
                                        inner_state <= third;
                                    end
                                third:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= fourth;
                                    end
                                fourth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= fifth;
                                    end
                                fifth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= sixth;
                                    end
                                sixth:
                                    if (phase3) begin
                                        sda_buf     <= 0;
                                        link        <= 1;
                                        inner_state <= seventh;
                                    end
                                seventh:
                                    if (phase3) begin
                                        sda_buf     <= 1; // бит чтения R=1
                                        link        <= 1;
                                        inner_state <= eighth;
                                    end
                                eighth:
                                    if (phase3) begin
                                        link        <= 0;    // отпускаем SDA, ждём ACK
                                        inner_state <= ack;
                                    end
                                ack: begin
                                    if (phase0) 
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        if (sda_buf == 1) 
                                            main_state <= 2'b00;
                                    end
                                    if (phase3) begin
                                        // далее – приём данных
                                        link        <= 0;
                                        inner_state <= first;
                                        i2c_state   <= read_data;
                                    end
                                end
                            endcase
                        end

                        // ------------------------------------------------
                        // read_data: поочерёдное считывание 8 бит с SDA
                        // ------------------------------------------------
                        read_data: begin  
                            case (inner_state)
                                // В каждом состоянии: на phase0 берём SDA,
                                // на phase1 сдвигаем байт readData_reg.
                                first: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= second;
                                end
                                second: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= third;
                                end
                                third: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= fourth;                            
                                end
                                fourth: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= fifth;                            
                                end
                                fifth: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= sixth;                            
                                end
                                sixth: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= seventh;                                
                                end
                                seventh: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3)
                                        inner_state <= eighth;                                
                                end
                                eighth: begin
                                    if (phase0)
                                        sda_buf <= sda;
                                    if (phase1) begin
                                        readData_reg[7:1] <= readData_reg[6:0];
                                        readData_reg[0]   <= sda;
                                    end
                                    if (phase3) 
                                        inner_state <= ack;
                                end
                                // После приёма 8-го бита – отвечаем NACK и формируем STOP
                                ack: begin
                                    if (phase3) begin
                                        link        <= 1;
                                        sda_buf     <= 0;   // NACK+STOP
                                        inner_state <= stop;
                                    end
                                end
                                stop: begin
                                    if (phase1) 
                                        sda_buf <= 1;
                                    if (phase3) 
                                        main_state <= 2'b00;
                                end
                            endcase
                        end
                    endcase
                end
            endcase
        end
    end

    // ============================================================================
    //                     МУЛЬТИПЛЕКСОР 7-СЕГМЕНТНОГО ИНДИКАТОРА
    // ============================================================================
    // cnt_scan переключает en[1:0] c большой периодичностью, из-за чего
    // человеческий глаз видит два устойчивых разряда (первый и второй).
    // На одном показываем writeData_reg, на другом readData_reg.
    // ============================================================================
    always @(posedge clk or negedge rst)
    begin
        if (!rst) begin
            cnt_scan <= 0;
            en       <= 2'b10;   // начинаем с старшего разряда
        end
        else begin
            cnt_scan <= cnt_scan + 1;
            if (cnt_scan == 24'hffffff)
                en <= ~en;       // простое переключение между 2'b10 и 2'b01
        end
    end

    // Выбор, какое значение сейчас отдаём на индикатор
    always @(writeData_reg or readData_reg or en)
    begin
        case (en)
            2'b10:
                seg_data_buf = writeData_reg;  // левый разряд – записанное значение
            2'b01:
                seg_data_buf = readData_reg;   // правый разряд – прочитанное
            default:
                seg_data_buf = 0;
        endcase
    end

    // Декодер байта в код 7-сегментного индикатора (hex-таблица 0..F)
    // Вход – младшие 4 бита seg_data_buf, остальное игнорируется.
    always @(seg_data_buf)
    begin   
        case (seg_data_buf)
            8'b0000_0000: seg_data = 8'b11000000;  // 0
            8'b0000_0001: seg_data = 8'b11111001;  // 1
            8'b0000_0010: seg_data = 8'b10100100;  // 2
            8'b0000_0011: seg_data = 8'b10110000;  // 3
            8'b0000_0100: seg_data = 8'b10011001;  // 4
            8'b0000_0101: seg_data = 8'b10010010;  // 5
            8'b0000_0110: seg_data = 8'b10000010;  // 6
            8'b0000_0111: seg_data = 8'b11111000;  // 7
            8'b0000_1000: seg_data = 8'b10000000;  // 8
            8'b0000_1001: seg_data = 8'b10010000;  // 9
            8'b0000_1010: seg_data = 8'b10001000;  // A
            8'b0000_1011: seg_data = 8'b10000011;  // b
            8'b0000_1100: seg_data = 8'b11000110;  // C
            8'b0000_1101: seg_data = 8'b10100001;  // d
            8'b0000_1110: seg_data = 8'b10000110;  // E
            8'b0000_1111: seg_data = 8'b10001110;  // F
            default:      seg_data = 8'b11111111;  // всё погасить
        endcase
    end

endmodule
