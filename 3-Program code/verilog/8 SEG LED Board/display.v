module display(
    input nrst,       // Сигнал активного низкого сброса
    input clk,        // Тактовый сигнал
    output [3:0] sel, // Выбор активной цифры (мультиплексирование)
    output [6:0] seg  // Сегменты 7-сегментного индикатора
    );
    
    reg [31:0] count1;  // 32-битный счётчик для отсчёта времени
    reg [15:0] number;  // 16-битный регистр для хранения текущего числа
    
    // Счётчик времени и инкремент числа
    always@(posedge clk, negedge nrst) begin
        if(!nrst) begin
            number <= 0;  // Сброс числа на 0
            count1 <= 0;  // Сброс счётчика на 0
        end
        else if(count1 == 25000000) begin  // Каждые 25 млн тактов
            number <= number + 1;  // Увеличиваем число
            count1 <= 0;           // Сброс счётчика
        end
        else begin
            count1 <= count1 + 1;  // Иначе инкрементируем счётчик
        end
    end
    
    // Модуль для управления 4-значным 7-сегментным дисплеем
    sel_4 U1(
        .clk(clk),
        .nrst(nrst),
        .number(number),
        .sel(sel),
        .seg(seg)
    );

endmodule

