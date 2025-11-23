module clkdiv(clk,
              clkout,
				  reset
				  );
reg clkout_r;
always@(posedge clk or negedge reset)
	if(!reset) begin
	clkout_r<=1'b0;
	end
	else
	clkout_r<=!clkout+r;
	
assign clkout=clkout_r;
			  
endmodule
