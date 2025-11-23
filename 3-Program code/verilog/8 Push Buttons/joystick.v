module joystick(
					clk,
					reset,
					key,
					led
               );
input clk,reset;
input [15:0]key;
output[3:0] led;

reg[3:0] led_reg;
reg[10:0] Count1;
reg  Count;
always@(posedge clk or negedge reset)
if(!reset)
Count1<=11'd0;
else if(Count1==11'd1999)
Count=~Count;
else 
Count1<=Count1+1'b1;


always@(posedge Count or negedge reset)
if(!reset)
led_reg<=4'b1111;
else if(key==16'b11111111_11111110)
led_reg<=4'b1110;
else if(key==16'b11111111_11111101)
led_reg<=4'b1101;
else if(key==16'b11111111_11111011)
led_reg<=4'b1100;
else if(key==16'b11111111_11110111)
led_reg<=4'b1011;

else if(key==16'b11111111_11101111)
led_reg<=4'b1010;
else if(key==16'b11111111_11011111)
led_reg<=4'b1001;
else if(key==16'b11111111_10111111)
led_reg<=4'b1000;
else if(key==16'b11111111_01111111)
led_reg<=4'b0111;
else if(key==16'b11111110_11111111)
led_reg<=4'b0110;
else if(key==16'b11111101_11111111)
led_reg<=4'b0101;
else if(key==16'b11111011_11111111)
led_reg<=4'b0100;
else if(key==16'b11110111_11111111)
led_reg<=4'b0011;
else if(key==16'b11101111_11111111)
led_reg<=4'b0010;
else if(key==16'b11011111_11111111)
led_reg<=4'b0001;
else if(key==16'b10111111_11111111)
led_reg<=4'b0000;
else if(key==16'b01111111_11111111)
led_reg<=4'b1111;
else
led_reg<=led_reg;

assign led=led_reg;

endmodule
