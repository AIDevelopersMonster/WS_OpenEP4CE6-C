module vga_red(
					clk,
					reset,
					hys,
					vys,
					rgb_r,
					rgb_g,
					rgb_b
               );
					
input clk;
input reset;

output hys;
output vys;

output rgb_r;
output rgb_g;
output rgb_b;

reg[9:0] h_cnt;
reg[9:0] v_cnt;

reg clkout_flag;// clkdiv scan
reg clkout_r;
reg clkout_r_r;


always@(posedge clk0 or negedge reset)
	if(!reset)begin
	h_cnt<=10'd0;
	end
	else if(h_cnt==10'd800) h_cnt<=10'd0;
	else
	h_cnt<=h_cnt+1'b1;

always@(posedge clk0 or negedge reset)
	if(!reset) begin
	v_cnt<=10'd0;
	end
	else if(v_cnt==10'd525)  v_cnt<=10'd0; 
	else if(h_cnt==10'd800)  v_cnt<=v_cnt+1;
	
//generate hys
reg hys_r;
always@(posedge clk0 or negedge reset)
	if(!reset) hys_r<=0;
	else if(h_cnt==10'd0) hys_r<=1'b0;
	else if(h_cnt==10'd96) hys_r<=1'b1;
	
assign hys=hys_r;

//generate vys
reg vys_r;
always@(posedge clk0 or negedge reset)
	if(!reset) vys_r<=1'b0;
	else if(v_cnt==10'd0) vys_r<=1'b0;
   else if(v_cnt==10'd34) vys_r<=1'b1;	
	
assign vys=vys_r;



wire valid;

assign valid=(v_cnt>=10'd34)&&(v_cnt<514)&&(h_cnt>=10'd144)&&(h_cnt<784);	

wire shape;
assign shape=(v_cnt>=100)&&(v_cnt<400);

	
assign rgb_r=valid?1:0;
assign rgb_g=valid?(shape?1:0):0;
assign rgb_b=valid?(shape?1:0):0;

vga_pll	vga_pll_inst (
	.inclk0(clk),
	.c0(clk0)
	);

endmodule
