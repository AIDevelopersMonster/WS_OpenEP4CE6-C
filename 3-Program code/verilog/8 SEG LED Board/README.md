
# 8 SEG LED Board Project

## Project Overview
This project demonstrates the control of a 4-digit 7-segment display using Verilog. The 8 SEG LED board will display a 16-bit number (split into 4 digits) on the display. Each digit is displayed one at a time using multiplexing, with a 10ms delay between switching digits.

## Modules in the Project

### 1. `display` Module
This module is responsible for counting and displaying numbers on the 4-digit 7-segment LED display. The counter increments every time the counter reaches 25 million ticks, and it updates the display after each increment.

#### Inputs:
- `clk`: Clock signal
- `nrst`: Active-low reset signal
- `key`: 16-bit input representing the number to be displayed

#### Outputs:
- `sel`: 4-bit signal for selecting the active digit
- `seg`: 7-bit signal controlling the segments of the 7-segment display

### 2. `seg_7` Module
This module converts the 4-bit data into the appropriate signals for the 7-segment display. It takes a 4-bit input and outputs a 7-bit signal controlling the display segments.

#### Inputs:
- `data`: 4-bit input value for the digit to be displayed

#### Outputs:
- `seg`: 7-bit output to control the segments of the 7-segment display

### 3. `sel_4` Module
This module is responsible for multiplexing the 4-digit display. It handles the switching between the 4 digits, selecting which one is currently active, and outputs the appropriate segment data for each digit.

#### Inputs:
- `clk`: Clock signal
- `nrst`: Active-low reset signal
- `number`: 16-bit number to be displayed

#### Outputs:
- `sel`: 4-bit signal to select the active digit
- `seg`: 7-bit output controlling the display segments

## Functionality
The display shows a 16-bit number on a 4-digit 7-segment display. Each of the four digits is updated in sequence every 10ms. The number is split into 4 digits, each represented by 4 bits, and the corresponding digit is shown on the 7-segment display.

### Timing
The timing of digit updates is controlled by a 10ms delay, which is implemented using a counter. When the counter reaches 50,000 ticks (assuming a 5 MHz clock), the display switches to the next digit.

### Multiplexing
Each of the 4 digits is displayed in sequence, with only one digit being active at any given time. The `sel` signal is used to select which digit is active, and the `seg` signal controls which segments are lit up to display the appropriate digit.

## Project Files
- `display.v`: Main module to drive the display and update the number.
- `seg_7.v`: Module to convert the 4-bit data into the corresponding 7-segment display signals.
- `sel_4.v`: Module to handle digit multiplexing and control the 7-segment display.

## Usage
To use the 8 SEG LED board:
1. Compile the Verilog files in your FPGA development environment.
2. Connect the 7-segment LED display to the FPGA I/O pins as per your board configuration.
3. Run the program to see the 16-bit number displayed on the 4-digit 7-segment display.

## License
This project is open-source and free to use for educational and non-commercial purposes.
