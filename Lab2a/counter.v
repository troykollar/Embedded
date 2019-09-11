module counter (clk, reset, outleds);
input          clk;
input          reset;
output [7:0]   outleds;

reg   [63:0]    leds;  
wire  [7:0]     outleds = leds[31:24];  

always @(posedge clk)
  if (!reset)            leds <= 1 ;
  else                  leds  <= leds + 1;
endmodule
