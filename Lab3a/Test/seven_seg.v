module counter(clk,Switch4,Switch5, reset, anodes, cathodes, outleds);
input Switch4;
input Switch5;
input clk;
input reset;

output [2:0]anodes;
output [7:0]cathodes;
output [7:0]	outleds;

reg [2:0]anodes;
reg [7:0]cathodes;
reg [7:0]outleds;
reg button_reg;
reg button_reg2;
reg button_sync;
reg button_sync2;
reg [31:0]	button_count;
reg [31:0]  button_count2;
reg   [11:0]   answer;   
parameter DEBOUNCE_DELAY = 32'd0_500_000;   /// 10nS * 1M = 10mS
parameter DEBOUNCE_DELAY2 = 32'd0_500_000;   /// 10nS * 1M = 10mS

always @(posedge clk)   button_reg   <= Switch4;
always @(posedge clk)   button_sync  <= !button_reg;

always @(posedge clk)   button_reg2   <= Switch5;
always @(posedge clk)   button_sync2  <= !button_reg2;

assign                  button_done  = (button_count == DEBOUNCE_DELAY); 
assign                  button_click = (button_count == DEBOUNCE_DELAY - 1); 

assign                  button_done2  = (button_count2 == DEBOUNCE_DELAY2); 
assign                  button_click2 = (button_count2 == DEBOUNCE_DELAY2 - 1); 

always@(posedge clk)
		if(!button_sync)  button_count <= 0;
		else if (button_done) button_count <= button_count;
		else 					button_count <= button_count + 1;

always@(posedge clk)
		if(!button_sync2)  button_count2 <= 0;
		else if (button_done2) button_count2 <= button_count2;
		else 					button_count2 <= button_count2 + 1;
			
always @(posedge clk)
		if(button_click) answer <= answer + 1;
		else if(button_click2) answer <= answer- 1;
		else if(!reset) answer <= 0;
		else			answer <= answer;
always @(posedge clk)
		outleds = answer[7:0];
		

 
reg   [39:0]                      counter;
always @(posedge clk)             
	if(!reset)      			  counter     <= 0;
	else                      counter     <= counter + 1;
                                  
wire                              anode_clk    =  (counter[15:0] == 16'h8000);

always @(posedge clk)
        if(!reset)		        anodes <= 3'b110;	
	     else if(anode_clk)   anodes <= {anodes[0],anodes[2:1]}; // rotate
	     else                 anodes <=  anodes;  

reg [3:0] cathode_select;

always @(cathode_select or answer)
       case({anodes})
	      3'b011:  cathode_select = answer[11:8]; 
	      3'b101:  cathode_select = answer[7:4]; 
	      3'b110:  cathode_select = answer[3:0]; 
	      default:  cathode_select = 4'h0; 
      endcase

//wire dp = 1; //!(anodes == 4'b1011); 

always @(cathode_select)
		case(cathode_select)
	       4'h0:  cathodes = {8'b11000000};
			 4'h1:  cathodes = {8'b11111001};
			 4'h2:  cathodes = {8'b10100100};
			 4'h3:  cathodes = {8'b10110000};
			 4'h4:  cathodes = {8'b10011001};
			 4'h5:  cathodes = {8'b10010010};
			 4'h6:  cathodes = {8'b10000010};
			 4'h7:  cathodes = {8'b11111000};
			 4'h8:  cathodes = {8'b10000000};
			 4'h9:  cathodes = {8'b10011000};
			 4'ha:  cathodes = {8'b10001000};
			 4'hb:  cathodes = {8'b10000011};
			 4'hc:  cathodes = {8'b11000110};
			 4'hd:  cathodes = {8'b10100001};
			 4'he:  cathodes = {8'b10000110};
			 4'hf:  cathodes = {8'b10001110};
     endcase
       
endmodule 
