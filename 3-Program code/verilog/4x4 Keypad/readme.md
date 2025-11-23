# 4x4 Keypad Interface Module

This Verilog module implements a 4x4 keypad scanner for FPGA or embedded systems. The module scans the keypad rows and columns, detects key presses, and outputs a 4-bit value representing the key that was pressed.

## Features

- Scans the 4x4 keypad using a clock signal.
- Outputs the corresponding key number (0-15) when a key is pressed.
- Simple and efficient Verilog code for easy integration into FPGA projects.

## Inputs and Outputs

### Inputs:
- `clk` (1 bit): The clock signal used for scanning the keypad.
- `reset` (1 bit): Active low reset signal to initialize the module.
- `row` (4 bits): The input signals from the 4 rows of the keypad.

### Outputs:
- `col` (4 bits): The output signals for driving the columns of the keypad.
- `key` (4 bits): The output indicating which key (0-15) has been pressed.

## Keypad Wiring

- **Rows**: The 4 rows of the keypad are connected to the `row` input.
- **Columns**: The 4 columns of the keypad are connected to the `col` output.

## Example

The module can be used in any project where a 4x4 keypad is required for user input. The `key` output can be connected to an LED display or an embedded system for further processing.

## Usage

To use the keypad module in your project, instantiate it as follows:

```verilog
keypad u_keypad (
    .clk(clk),
    .reset(reset),
    .row(row),
    .col(col),
    .key(key)
);
