// ------------------------------------------------------------
//  Module     : lcd12864
//  Project    : Демонстрация работы ЖКИ 128x64 в текстовом режиме
//  Board      : WS_OpenEP4CE6-C (или любая FPGA/PLD с тактовой ~50 МГц)
//  Description:
//    Исходный (рабочий) пример инициализации LCD12864 и вывода
//    нескольких строк текста (латиница + китайские иероглифы).
//    Логика оставлена максимально как в исходном китайском коде,
//    только добавлены комментарии на русском.
//
//  ВАЖНО:
//    - Структура always-блоков и присваивания оставлены такими же
//      (блокирующие '=' и неблокирующие '<='), чтобы не сломать тайминги.
//    - Все константы и коды состояний сохранены.
// ------------------------------------------------------------

module lcd12864(
    LCD_N,
    LCD_P,
    LCD_RST,
    PSB,
    clk,
    rs,
    rw,
    en,
    dat
);

    // Выходы управления дисплеем / подсветкой
    output reg  LCD_N;
    output reg  LCD_P;
    output reg  LCD_RST;
    output reg  PSB;

    // Тактовый вход
    input       clk;

    // Шина данных и сигналы управления дисплеем
    output [7:0] dat;
    output reg   rs, rw, en;

    //tri en; // в оригинале была попытка сделать трехстабильный вывод EN

    // Внутренние регистры
    reg        e;           // дополнительный флаг для формирования EN
    reg [7:0]  dat;         // регистр данных на шину дисплея

    reg [31:0] counter;     // делитель частоты
    reg [6:0]  current, next; // текущее и следующее состояние автомата
    reg        clkr;        // "медленный" такт для EN
    reg [31:0] cnt;         // счётчик задержки в состоянии nul

    // Коды состояний автомата (команды и данные)
    parameter  set0  = 6'h0;
    parameter  set1  = 6'h1;
    parameter  set2  = 6'h2;
    parameter  set3  = 6'h3;
    parameter  set4  = 6'h4;
    parameter  set5  = 6'h5;
    parameter  set6  = 6'h6;

    parameter  dat0  = 6'h7;
    parameter  dat1  = 6'h8;
    parameter  dat2  = 6'h9;
    parameter  dat3  = 6'hA;
    parameter  dat4  = 6'hB;
    parameter  dat5  = 6'hC;
    parameter  dat6  = 6'hD;
    parameter  dat7  = 6'hE;
    parameter  dat8  = 6'hF;
    parameter  dat9  = 6'h10;

    parameter  dat10 = 6'h12;
    parameter  dat11 = 6'h13;
    parameter  dat12 = 6'h14;
    parameter  dat13 = 6'h15;
    parameter  dat14 = 6'h16;
    parameter  dat15 = 6'h17;
    parameter  dat16 = 6'h18;
    parameter  dat17 = 6'h19;
    parameter  dat18 = 6'h1A;
    parameter  dat19 = 6'h1B;
    parameter  dat20 = 6'h1C;
    parameter  dat21 = 6'h1D;
    parameter  dat22 = 6'h1E;
    parameter  dat23 = 6'h1F;
    parameter  dat24 = 6'h20;
    parameter  dat25 = 6'h21;
    parameter  dat26 = 6'h22;
    parameter  dat27 = 6'h23;
    parameter  dat28 = 6'h24;
    parameter  dat29 = 6'h25;
    parameter  dat30 = 6'h26;
    parameter  dat31 = 6'h27;
    parameter  dat32 = 6'h28;
    parameter  dat33 = 6'h29;
    parameter  dat34 = 6'h2A;
    parameter  dat35 = 6'h2B;
    parameter  dat36 = 6'h2C;
    parameter  dat37 = 6'h2E;
    parameter  dat38 = 6'h2F;
    parameter  dat39 = 6'h30;
    parameter  dat40 = 6'h31;
    parameter  dat41 = 6'h32;
    parameter  dat42 = 6'h33;
    parameter  dat43 = 6'h34;

    parameter  nul   = 6'h35;

    // --------------------------------------------------------
    // Делитель частоты и формирование сигнала EN
    // --------------------------------------------------------
    // da de shi zhong pinlv  (китайский комментарий: "это делитель частоты")
    always @(posedge clk)
    begin
        counter = counter + 1;              // блокирующее "+1" на счётчике

        if (counter == 32'h15ffe) begin     // верхняя граница счётчика
            counter <= 0;                   // сброс счётчика (неблокирующее)
        end
        else if ((counter == 32'hAFFE) || (counter == 32'h57FE)) begin
            clkr = ~clkr;                   // инверсия "медленного" такта
        end

        // Формирование управляющих сигналов дисплея
        en      = clkr | e;                 // EN = OR "медленного" такта и флага e
        rw      = 1'b0;                     // всегда запись
        LCD_N   = 1'b0;                     // условное управление подсветкой/питанием
        LCD_P   = 1'b1;
        LCD_RST = 1'b1;                     // дисплей не сброшен
        PSB     = 1'b1;                     // параллельный 8-битный интерфейс
    end

    // --------------------------------------------------------
    // Основной конечный автомат вывода команд и данных
    // --------------------------------------------------------
    always @(posedge clk)
    begin
        // Переход по состояниям происходит, когда counter достигает 0xAFF0
        if (counter == 32'haff0) begin
            current = next;                 // блокирующее присваивание: текущее = следующее

            case (current)

                // -----------------------------
                // Инициализация ЖКИ
                // -----------------------------
                set0:   begin
                            rs   <= 0;      // команда
                            dat  <= 8'h30;  // функция: 8-битный интерфейс, базовые настройки
                            next <= set1;
                        end

                set1:   begin
                            rs   <= 0;
                            dat  <= 8'h0c;  // включить дисплей, курсор выкл
                            next <= set2;
                        end

                set2:   begin
                            rs   <= 0;
                            dat  <= 8'h6;   // режим автосмещения курсора
                            next <= dat0;
                        end

                set3:   begin
                            rs   <= 0;
                            dat  <= 8'h1;   // очистка дисплея (здесь по сути "вечная" команда)
                            next <= set3;
                        end

                // -----------------------------
                // Первая строка: "KONTAKTS "
                // -----------------------------
                dat0:   begin rs <= 1; dat <= "K"; next <= dat1; end // K
                dat1:   begin rs <= 1; dat <= "O"; next <= dat2; end // O
                dat2:   begin rs <= 1; dat <= "N"; next <= dat3; end // N
                dat3:   begin rs <= 1; dat <= "T"; next <= dat4; end // T
                dat4:   begin rs <= 1; dat <= "A"; next <= dat5; end // A
                dat5:   begin rs <= 1; dat <= "K"; next <= dat6; end // K
                dat6:   begin rs <= 1; dat <= "T"; next <= dat7; end // T
                dat7:   begin rs <= 1; dat <= "S"; next <= dat8; end // S
                dat8:   begin rs <= 1; dat <= " "; next <= nul; end  // пробел
                dat9:   begin rs <= 1; dat <= " "; next <= nul; end  // ещё пробел (почти не используется)

                // -----------------------------
                // Китайские символы (байты GB-кодировки)
                // -----------------------------
                dat10:  begin rs <= 1; dat <= 8'hB5; next <= dat11; end
                dat11:  begin rs <= 1; dat <= 8'hE7; next <= dat12; end
                dat12:  begin rs <= 1; dat <= 8'hd7; next <= dat13; end
                dat13:  begin rs <= 1; dat <= 8'hd3; next <= dat10; end
                // Обратите внимание: переход назад на dat10 -> по кругу выводится пара иероглифов

                // -----------------------------
                // Вторая строка "www.waveshare.ne"
                // -----------------------------
                set4:   begin
                            rs   <= 0;
                            dat  <= 8'h90;  // установка адреса DDRAM второй строки
                            next <= dat14;
                        end

                dat14:  begin rs <= 1; dat <= "w"; next <= dat15; end
                dat15:  begin rs <= 1; dat <= "w"; next <= dat16; end
                dat16:  begin rs <= 1; dat <= "w"; next <= dat17; end
                dat17:  begin rs <= 1; dat <= "."; next <= dat18; end
                dat18:  begin rs <= 1; dat <= "w"; next <= dat19; end
                dat19:  begin rs <= 1; dat <= "a"; next <= dat20; end
                dat20:  begin rs <= 1; dat <= "v"; next <= dat21; end
                dat21:  begin rs <= 1; dat <= "e"; next <= dat22; end
                dat22:  begin rs <= 1; dat <= "s"; next <= dat23; end
                dat23:  begin rs <= 1; dat <= "h"; next <= dat24; end
                dat24:  begin rs <= 1; dat <= "a"; next <= dat25; end
                dat25:  begin rs <= 1; dat <= "r"; next <= dat26; end
                dat26:  begin rs <= 1; dat <= "e"; next <= dat27; end
                dat27:  begin rs <= 1; dat <= "."; next <= dat28; end
                dat28:  begin rs <= 1; dat <= "n"; next <= dat29; end
                dat29:  begin rs <= 1; dat <= "e"; next <= set5;  end

                // -----------------------------
                // Третья строка: "FPGA-NIOS II II "
                // -----------------------------
                set5:   begin
                            rs   <= 0;
                            dat  <= 8'h88;  // установка адреса DDRAM третьей строки
                            next <= dat30;
                        end

                dat30:  begin rs <= 1; dat <= "F"; next <= dat31; end
                dat31:  begin rs <= 1; dat <= "P"; next <= dat32; end
                dat32:  begin rs <= 1; dat <= "G"; next <= dat33; end
                dat33:  begin rs <= 1; dat <= "A"; next <= dat34; end
                dat34:  begin rs <= 1; dat <= "-"; next <= dat35; end
                dat35:  begin rs <= 1; dat <= "N"; next <= dat36; end
                dat36:  begin rs <= 1; dat <= "I"; next <= dat37; end
                dat37:  begin rs <= 1; dat <= "O"; next <= 8'h50; end

                8'h50:  begin rs <= 1; dat <= "S"; next <= 8'h51; end
                8'h51:  begin rs <= 1; dat <= " "; next <= 8'h52; end
                8'h52:  begin rs <= 1; dat <= "I"; next <= 8'h53; end
                8'h53:  begin rs <= 1; dat <= "I"; next <= 8'h54; end
                8'h54:  begin rs <= 1; dat <= " "; next <= nul;   end
                8'h55:  begin rs <= 1; dat <= " "; next <= 8'h56; end
                8'h56:  begin rs <= 1; dat <= "I"; next <= 8'h57; end
                8'h57:  begin rs <= 1; dat <= "I"; next <= set6;  end

                // -----------------------------
                // Четвёртая строка: китайский текст
                // -----------------------------
                set6:   begin
                            rs   <= 0;
                            dat  <= 8'h98;  // адрес DDRAM четвёртой строки
                            next <= dat38;
                        end

                dat38:  begin rs <= 1; dat <= 8'hBF; next <= dat39; end
                dat39:  begin rs <= 1; dat <= 8'haa; next <= dat40; end
                dat40:  begin rs <= 1; dat <= 8'hb7; next <= dat41; end
                dat41:  begin rs <= 1; dat <= 8'ha2; next <= dat42; end
                dat42:  begin rs <= 1; dat <= 8'hB0; next <= dat43; end
                dat43:  begin rs <= 1; dat <= 8'hE5; next <= 8'h55; end

                // -----------------------------
                // nul: небольшая пауза между циклами
                // -----------------------------
                nul:    begin
                            rs  <= 0;
                            dat <= 8'h00;        // фиктивный байт

                            if (cnt != 32'h7f) begin
                                e   <= 1;        // держим EN активным
                                cnt <= cnt + 1;  // наращиваем задержку
                            end
                            else begin
                                next <= set0;    // возвращаемся к началу цикла
                                e    <= 0;       // EN сбрасываем
                                cnt  <= 0;
                            end
                        end

                default: begin
                            next = set0;         // защита по умолчанию
                         end
            endcase
        end
    end

endmodule
