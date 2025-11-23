// ------------------------------------------------------------
// Module     : vga_red
// Project    : VGA Red Display
// Description: VGA Controller for generating the red component of an RGB signal.
//              This module handles horizontal and vertical synchronization signals (HSYNC, VSYNC),
//              and the red, green, and blue color components. It generates a VGA signal with a 640x480 resolution at 60Hz.
//              The PLL is used to generate the correct clock for the VGA timings.
// Board      : FPGA (e.g., EP4CE6)
// Created By : [Your Name]
// ------------------------------------------------------------

module vga_red(
    input clk,           // Основной тактовый сигнал
    input reset,         // Сигнал сброса (негативный уровень)
    output hys,          // Горизонтальная синхронизация (HSYNC)
    output vys,          // Вертикальная синхронизация (VSYNC)
    output rgb_r,        // Красный компонент RGB
    output rgb_g,        // Зеленый компонент RGB
    output rgb_b         // Синий компонент RGB
);

reg [9:0] h_cnt;         // Счетчик горизонтальной синхронизации
reg [9:0] v_cnt;         // Счетчик вертикальной синхронизации

reg clkout_flag;         // Флаг для генерации тактовой частоты для сканирования
reg clkout_r;            // Регистры для генерации тактовой частоты
reg clkout_r_r;

always@(posedge clk0 or negedge reset) begin
    if(!reset) begin
        h_cnt <= 10'd0;   // Сброс счетчика горизонтальной синхронизации
    end
    else if(h_cnt == 10'd800) begin
        h_cnt <= 10'd0;   // Перезапуск счетчика по достижении максимального значения
    end
    else begin
        h_cnt <= h_cnt + 1'b1; // Увеличение счетчика горизонтальной синхронизации
    end
end

always@(posedge clk0 or negedge reset) begin
    if(!reset) begin
        v_cnt <= 10'd0;   // Сброс счетчика вертикальной синхронизации
    end
    else if(v_cnt == 10'd525) begin
        v_cnt <= 10'd0;   // Перезапуск счетчика вертикальной синхронизации
    end
    else if(h_cnt == 10'd800) begin
        v_cnt <= v_cnt + 1; // Увеличение счетчика вертикальной синхронизации при завершении строки
    end
end

// Генерация горизонтальной синхронизации (HSYNC)
reg hys_r;
always@(posedge clk0 or negedge reset) begin
    if(!reset) hys_r <= 0;
    else if(h_cnt == 10'd0) hys_r <= 1'b0;
    else if(h_cnt == 10'd96) hys_r <= 1'b1;
end

assign hys = hys_r;  // Вывод сигнала горизонтальной синхронизации

// Генерация вертикальной синхронизации (VSYNC)
reg vys_r;
always@(posedge clk0 or negedge reset) begin
    if(!reset) vys_r <= 1'b0;
    else if(v_cnt == 10'd0) vys_r <= 1'b0;
    else if(v_cnt == 10'd34) vys_r <= 1'b1;
end

assign vys = vys_r;  // Вывод сигнала вертикальной синхронизации

// Условие действительности пикселя
wire valid;
assign valid = (v_cnt >= 10'd34) && (v_cnt < 514) && (h_cnt >= 10'd144) && (h_cnt < 784);

// Условие формирования формы (например, прямоугольник)
wire shape;
assign shape = (v_cnt >= 100) && (v_cnt < 400);

// Генерация RGB сигнала для красного цвета
assign rgb_r = valid ? 1 : 0;
assign rgb_g = valid ? (shape ? 1 : 0) : 0;
assign rgb_b = valid ? (shape ? 1 : 0) : 0;

// Инстанциация PLL для генерации тактовой частоты, соответствующей VGA
vga_pll vga_pll_inst (
    .inclk0(clk),   // Входной тактовый сигнал
    .c0(clk0)       // Выходной тактовый сигнал для VGA
);

endmodule
