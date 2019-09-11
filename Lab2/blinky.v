module counter (clk, reset, outleds);
input          clk;
input          reset;
output [7:0]   outleds;

reg [22:0]      delay_counter;                             // counts to roughly 8 million
wire            twenty_ms_enable = (delay_counter == 0);   // one cycle pulse every 8 millions cycles at 100MHz
reg  [7:0]      outleds;
reg  [2:0]      state;  


always @(posedge clk)
  if (!reset)                   delay_counter <= 0 ;
  else                          delay_counter <= delay_counter + 1;
  
always @(posedge clk)
  if (!reset)                   state <= 0;
  else if(twenty_ms_enable)     state <= state + 1;            
  else                                 state <= state;

always @(state)
    case(state)
        0:                      outleds <= 8'b1000_0000;
        1:                      outleds <= 8'b0100_0000;
        2:                      outleds <= 8'b0010_0000;
        3:                      outleds <= 8'b0001_0000;
        4:                      outleds <= 8'b0000_1000;
        5:                      outleds <= 8'b0000_0100;
        6:                      outleds <= 8'b0000_0010;
        7:                      outleds <= 8'b0000_0001;
     endcase

endmodule
