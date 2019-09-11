module counter (clk, reset, BigSwitch, outleds);
input          clk;
input          reset;
input		BigSwitch;
output [7:0]   outleds;

reg [22:0]      delay_counter;                             // counts to roughly 8 million
wire            twenty_ms_enable = (delay_counter == 0);   // one cycle pulse every 8 millions cycles at 100MHz
reg  [7:0]      outleds;
reg  [2:0]      state;


always @(posedge clk)
  if (!reset)                  delay_counter <= 0;
  else                          delay_counter <= delay_counter + 1;
  
always @(posedge clk)
  if (!reset)			state <= 0;
  else if(twenty_ms_enable)     state <= state + 1;
  else                                 state <= state;


always @(state)
	if (BigSwitch == 0)
		case(state)
        		0:                      outleds <= 8'b1100_0000;
	        	1:                      outleds <= 8'b0110_0000;
	        	2:                      outleds <= 8'b0011_0000;
	        	3:                      outleds <= 8'b0001_1000;
	        	4:                      outleds <= 8'b0000_1100;
	       	 	5:                      outleds <= 8'b0000_0110;
	        	6:                      outleds <= 8'b0000_0011;
	        	7:                      outleds <= 8'b1000_0001;
     		endcase
	else
		case(state)
			0:                      outleds <= 8'b0000_0111;
                        1:                      outleds <= 8'b0000_1110;
                        2:                      outleds <= 8'b0001_1100;
                        3:                      outleds <= 8'b0011_1000;
                        4:                      outleds <= 8'b0111_0000;
                        5:                      outleds <= 8'b1110_0000;
                        6:                      outleds <= 8'b1100_0001;
                        7:                      outleds <= 8'b1000_0011;
		endcase	
endmodule
