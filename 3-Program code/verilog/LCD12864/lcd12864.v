module lcd12864(LCD_N,LCD_P,LCD_RST,PSB,clk, rs, rw, en,dat);
output reg  LCD_N;
output reg LCD_P;
output reg LCD_RST;
output reg PSB;
input clk;  
 output [7:0] dat; 
 output reg rs,rw,en; 
 //tri en; 
 reg e; 
 reg [7:0] dat; 
  
 reg  [31:0] counter; 
 reg [6:0] current,next; 
 reg clkr; 
 reg [31:0] cnt; 
 parameter  set0=6'h0; 
 parameter  set1=6'h1; 
 parameter  set2=6'h2; 
 parameter  set3=6'h3; 
 parameter  set4=6'h4; 
 parameter  set5=6'h5;
 parameter  set6=6'h6;  

 parameter  dat0=6'h7; 
 parameter  dat1=6'h8; 
 parameter  dat2=6'h9; 
 parameter  dat3=6'hA; 
 parameter  dat4=6'hB; 
 parameter  dat5=6'hC;
 parameter  dat6=6'hD; 
 parameter  dat7=6'hE; 
 parameter  dat8=6'hF; 
 parameter  dat9=6'h10;

 parameter  dat10=6'h12; 
 parameter  dat11=6'h13; 
 parameter  dat12=6'h14; 
 parameter  dat13=6'h15; 
 parameter  dat14=6'h16; 
 parameter  dat15=6'h17;
 parameter  dat16=6'h18; 
 parameter  dat17=6'h19; 
 parameter  dat18=6'h1A; 
 parameter  dat19=6'h1B; 
 parameter  dat20=6'h1C;
 parameter  dat21=6'h1D; 
 parameter  dat22=6'h1E; 
 parameter  dat23=6'h1F; 
 parameter  dat24=6'h20; 
 parameter  dat25=6'h21; 
 parameter  dat26=6'h22; 
 parameter  dat27=6'h23; 
 parameter  dat28=6'h24; 
 parameter  dat29=6'h25; 
 parameter  dat30=6'h26; 
 parameter  dat31=6'h27; 
 parameter  dat32=6'h28; 
 parameter  dat33=6'h29; 
 parameter  dat34=6'h2A; 
 parameter  dat35=6'h2B;
 parameter  dat36=6'h2C; 
 parameter  dat37=6'h2E; 
 parameter  dat38=6'h2F; 
 parameter  dat39=6'h30;
 parameter  dat40=6'h31; 
 parameter  dat41=6'h32; 
 parameter  dat42=6'h33; 
 parameter  dat43=6'h34; 
   
  
 parameter  nul=6'h35; 
always @(posedge clk)         //da de shi zhong pinlv 
 begin 
  counter=counter+1; 
  if(counter==32'h15ffe)  begin
  counter<=0;
  end
  else if((counter==32'hAFFE)||(counter==32'h57FE)) begin
  clkr=~clkr; 
  end
en=clkr|e; 
rw=0; 
LCD_N=1'b0;
LCD_P=1'b1;
LCD_RST=1'b1;
PSB=1'b1;
end 
always @(posedge clk) 
begin 

 if(counter==32'haff0)begin 
		 current=next; 
		 case(current) 
			 set0:   begin  rs<=0; dat<=8'h30; next<=set1; end 
			 set1:   begin  rs<=0; dat<=8'h0c; next<=set2; end 
			 set2:   begin  rs<=0; dat<=8'h6; next<=dat0; end// 
			 set3:   begin  rs<=0; dat<=8'h1; next<=set3; end 
		
			 dat0:   begin  rs<=1; dat<="W"; next<=dat1; end //?????
			 dat1:   begin  rs<=1; dat<="a"; next<=dat2; end 
			 dat2:   begin  rs<=1; dat<="v"; next<=dat3; end 
			 dat3:   begin  rs<=1; dat<="e";next<=dat4; end 
			 dat4:   begin  rs<=1; dat<="s"; next<=dat5; end 
			 dat5:   begin  rs<=1; dat<="h"; next<=dat6; end 
			 dat6:   begin  rs<=1; dat<="a"; next<=dat7; end 
			 dat7:   begin  rs<=1; dat<="r";next<=dat8; end 
			 dat8:   begin  rs<=1; dat<="e"; next<=nul; end 
			 dat9:   begin  rs<=1; dat<=" ";next<= nul ; end 
			 
			 dat10:   begin  rs<=1; dat<=8'hB5; next<=dat11; end 
			 dat11:   begin  rs<=1; dat<=8'hE7; next<=dat12; end 
		 
			 dat12:   begin  rs<=1; dat<=8'hd7;next<=dat13; end 
			 dat13:   begin  rs<=1; dat<=8'hd3; next<=dat10; end 
			 
			 
		
			 set4:   begin  rs<=0; dat<=8'h90; next<=dat14; end //?????
		
			 dat14:   begin  rs<=1; dat<="w"; next<=dat15; end 
			 dat15:   begin  rs<=1; dat<="w"; next<=dat16; end 
			 dat16:   begin  rs<=1; dat<="w"; next<=dat17; end 
			 dat17:   begin  rs<=1; dat<="."; next<=dat18; end 
			 dat18:   begin  rs<=1; dat<="w"; next<=dat19; end 
			 dat19:   begin  rs<=1; dat<="a"; next<=dat20; end
			 dat20:   begin  rs<=1; dat<="v"; next<=dat21; end 
			 dat21:   begin  rs<=1; dat<="e"; next<=dat22; end 
			 dat22:   begin  rs<=1; dat<="s"; next<=dat23; end 
			 dat23:   begin  rs<=1; dat<="h"; next<=dat24 ; end
			 
			 dat24:   begin  rs<=1; dat<="a"; next<=dat25; end 
			 dat25:   begin  rs<=1; dat<="r"; next<=dat26; end  
			 
			 dat26:   begin  rs<=1; dat<="e"; next<=dat27; end 
			 dat27:   begin  rs<=1; dat<="."; next<=dat28; end 
			 
			 dat28:   begin  rs<=1; dat<="n"; next<=dat29; end 
			 dat29:   begin  rs<=1; dat<="e"; next<=set5 ; end 
		
			set5:   begin  rs<=0; dat<=8'h88; next<=dat30; end //?????
		
		
			 dat30:   begin  rs<=1; dat<="F"; next<=dat31; end 
			 dat31:   begin  rs<=1; dat<="P"; next<=dat32; end 
			 dat32:   begin  rs<=1; dat<="G"; next<=dat33; end 
			 dat33:   begin  rs<=1; dat<="A"; next<=dat34; end 
			 dat34:   begin  rs<=1; dat<="-"; next<=dat35;   end 
			 dat35:   begin  rs<=1; dat<="N"; next<=dat36;   end 
		
			 dat36:   begin  rs<=1; dat<="I"; next<=dat37;   end 
			 dat37:   begin  rs<=1; dat<="O"; next<=8'h50;   end 
		
			 8'h50:   begin  rs<=1; dat<="S"; next<=8'h51; end 
			 8'h51:   begin  rs<=1; dat<=" "; next<=8'h52; end 
			 8'h52:   begin  rs<=1; dat<="I"; next<=8'h53; end 
			 8'h53:   begin  rs<=1; dat<="I"; next<=8'h54; end 
			 8'h54:   begin  rs<=1; dat<=" "; next<=nul;   end 
			 8'h55:   begin  rs<=1; dat<=" "; next<=8'h56;   end 
		
			 8'h56:   begin  rs<=1; dat<="I"; next<=8'h57;   end 
			 8'h57:   begin  rs<=1; dat<="I"; next<=set6;   end 
			 
			 
			 set6:   begin  rs<=0; dat<=8'h98; next<=dat38; end //?????
		
			 dat38:   begin  rs<=1; dat<=8'hBF; next<=dat39; end 
			 dat39:   begin  rs<=1; dat<=8'haa; next<=dat40; end 
			 dat40:   begin  rs<=1; dat<=8'hb7; next<=dat41; end 
			 dat41:   begin  rs<=1; dat<=8'ha2; next<=dat42;   end 
			 dat42:   begin  rs<=1; dat<=8'hB0; next<=dat43;   end 
			 dat43:   begin  rs<=1; dat<=8'hE5; next<=8'h55;   end 
		
			  nul:   begin rs<=0;  dat<=8'h00;                    // ????E ? ?? 
							if(cnt!=32'h7f)  
								begin  
									  e<=1;cnt<=cnt+1;  
								end  
								 else  
									begin next<=set0; e<=0; cnt<=0; 
								  end    
						  end 
			default:   next=set0; 
			 endcase 
	end		 
	
end 

endmodule  
