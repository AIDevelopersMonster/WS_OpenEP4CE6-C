// ------------------------------------------------------------
// Module     : LCD1602
// Project    : LCD1602 Display Controller
// Description: This module controls an LCD1602 display by sending the required 
//              commands and data to initialize the display and show the 
//              string "KONTAKTS" on the screen.
//              It uses an 8-bit parallel interface for data transmission and
//              control signals for Register Select (RS), Read/Write (RW), 
//              and Enable (EN).
// Board      : FPGA or CPLD with appropriate clock source
// Created By : kontakts.ru
// ------------------------------------------------------------

module LCD1602(clk, rs, rw, en, dat, LCD_N, LCD_P);  

input clk;         // Clock input signal
output [7:0] dat; // Data lines to the LCD (8-bit data)
output rs, rw, en; // Control signals: Register Select, Read/Write, Enable
output LCD_N, LCD_P; // Power control signals: Negative and Positive

reg e;             // Enable signal for LCD
reg [7:0] dat;     // Data register for sending 8-bit data to LCD
reg rs;            // Register Select signal (0 for command, 1 for data)
reg [15:0] counter; // Counter to control timing
reg [4:0] current, next; // State machine for LCD control
reg clkr;          // Clock divider for controlling LCD timing
reg [1:0] cnt;     // Counter to handle delays during reset

// Parameters for the state machine
parameter set0 = 4'h0, set1 = 4'h1, set2 = 4'h2, set3 = 4'h3;
parameter dat0 = 4'h4, dat1 = 4'h5, dat2 = 4'h6, dat3 = 4'h7;
parameter dat4 = 4'h8, dat5 = 4'h9, dat6 = 4'hA, dat7 = 4'hB;
parameter dat8 = 4'hC, dat9 = 4'hD, dat10 = 4'hE, dat11 = 5'h10;
parameter nul = 4'hF; 

// Power control signals for LCD
assign LCD_N = 0;  // LCD Negative pin connected to ground
assign LCD_P = 1;  // LCD Positive pin connected to VCC

// Clock divider logic to generate clkr signal for timing control
always @(posedge clk) begin
  counter = counter + 1; 
  if (counter == 16'h000f)  // Toggle clkr every 16 clock cycles
    clkr = ~clkr; 
end 

// State machine to control the LCD operations and data output
always @(posedge clkr) begin 
  current = next; 
  case(current) 
    // Initialization sequence for LCD
    set0: begin
      rs <= 0;       // Command mode
      dat <= 8'h31;  // Command: Function Set (8-bit mode)
      next <= set1;
    end
    set1: begin
      rs <= 0;
      dat <= 8'h0C;  // Command: Display On/Off Control (Display on, Cursor off)
      next <= set2;
    end
    set2: begin
      rs <= 0;
      dat <= 8'h06;  // Command: Entry Mode Set (Increment, No shift)
      next <= set3;
    end
    set3: begin
      rs <= 0;
      dat <= 8'h1;   // Command: Clear Display
      next <= dat0;
    end

    // Sending data "KONTAKTS" to the LCD
    dat0: begin
      rs <= 1;       // Data mode
      dat <= "K";    // Character "K"
      next <= dat1;
    end
    dat1: begin
      rs <= 1;
      dat <= "O";    // Character "O"
      next <= dat2;
    end
    dat2: begin
      rs <= 1;
      dat <= "N";    // Character "N"
      next <= dat3;
    end
    dat3: begin
      rs <= 1;
      dat <= "T";    // Character "T"
      next <= dat4;
    end
    dat4: begin
      rs <= 1;
      dat <= "A";    // Character "A"
      next <= dat5;
    end
    dat5: begin
      rs <= 1;
      dat <= "K";    // Character "K"
      next <= dat6;
    end
    dat6: begin
      rs <= 1;
      dat <= "T";    // Character "T"
      next <= dat7;
    end
    dat7: begin
      rs <= 1;
      dat <= "S";    // Character "S"
      next <= dat8;
    end
    dat8: begin
      rs <= 1;
      dat <= " ";    // Space
      next <= dat9;
    end
    dat9: begin
      rs <= 1;
      dat <= " ";    // Space
      next <= dat10;
    end
    dat10: begin
      rs <= 1;
      dat <= " ";    // Space
      next <= dat11;
    end
    dat11: begin
      rs <= 1;
      dat <= " ";    // Space
      next <= nul;
    end 

    // End of string "KONTAKTS", loop back or stop
    nul: begin
      rs <= 0;
      dat <= 8'h00;  // Command: No Operation (NOP)
      if(cnt != 2'h2) begin  
        e <= 0;        // Reset enable
        next <= set0;  // Go back to initialization
        cnt <= cnt + 1;
      end else begin
        next <= nul;   // Stay in NOP state
        e <= 1;        // Enable LCD for the next cycle
      end    
    end 

    default: begin
      next = set0;    // Default state is set0 (initialization)
    end
  endcase 
end 

// Control signal assignments
assign en = clkr | e;   // Enable signal is active based on clock or enable
assign rw = 0;          // Write mode (not read mode)
endmodule
