// ------------------------------------------------------------
//  Module     : keypad.v
//  Project    : 4x4 Keypad Interface
//  Description: 
//    This module implements a 4x4 keypad scanner for FPGA/Embedded systems.
//    It reads the rows and columns of the keypad and identifies which key
//    has been pressed based on the combination of row and column signals.
//    
//  Inputs:
//    - clk   : Clock signal
//    - reset : Active low reset signal
//    - row   : 4-bit input representing the rows of the keypad
//  
//  Outputs:
//    - col   : 4-bit output for driving the columns of the keypad
//    - key   : 4-bit output indicating which key has been pressed (0-15)
//
//  Example Usage:
//    The module can be instantiated in a larger design where the `key`
//    output is used to trigger actions or be displayed on an LED or LCD screen.
//
// ----------------------------------------------------------------------
//  GitHub Repository: https://github.com/AIDevelopersMonster/WS_OpenEP4CE6-C/
//  YouTube Playlist: https://www.youtube.com/playlist?list=PLVoFIRfTAAI7-d_Yk6bNVnj4atUdMxvT5
// ------------------------------------------------------------


module keyscan(
    input clk,            // Clock signal
    input reset,          // Active low reset signal
    input [3:0] row,      // Row signals
    output reg [3:0] col, // Column signals
    output reg [3:0] key  // Key output (which key is pressed)
);

    reg [3:0] row_scan;  // Row scan register
    reg [3:0] col_scan;  // Column scan register

    // Row scanning logic
    always @(posedge clk or negedge reset) begin
        if (!reset)
            row_scan <= 4'b1111;  // Reset row scan to default state
        else
            row_scan <= row_scan << 1; // Shift the row scan
    end

    // Column scanning logic
    always @(posedge clk or negedge reset) begin
        if (!reset)
            col_scan <= 4'b1111;  // Reset column scan to default state
        else
            col_scan <= col_scan << 1; // Shift the column scan
    end

    // Detect the key pressed by checking row and column values
    always @(posedge clk or negedge reset) begin
        if (!reset)
            key <= 4'b0000;  // No key pressed on reset
        else begin
            case ({row_scan, col_scan})
                8'b1110_1110: key <= 4'b0001; // Key 1
                8'b1110_1101: key <= 4'b0010; // Key 2
                8'b1110_1011: key <= 4'b0011; // Key 3
                8'b1110_0111: key <= 4'b0100; // Key 4
                8'b1101_1110: key <= 4'b0101; // Key 5
                8'b1101_1101: key <= 4'b0110; // Key 6
                8'b1101_1011: key <= 4'b0111; // Key 7
                8'b1101_0111: key <= 4'b1000; // Key 8
                8'b1011_1110: key <= 4'b1001; // Key 9
                8'b1011_1101: key <= 4'b1010; // Key A
                8'b1011_1011: key <= 4'b1011; // Key B
                8'b1011_0111: key <= 4'b1100; // Key C
                8'b0111_1110: key <= 4'b1101; // Key D
                8'b0111_1101: key <= 4'b1110; // Key E
                8'b0111_1011: key <= 4'b1111; // Key F
                default: key <= 4'b0000;  // No key pressed
            endcase
        end
    end

    // Output the row and column signals to the respective pins
    always @(posedge clk) begin
        col <= col_scan;
    end

endmodule
