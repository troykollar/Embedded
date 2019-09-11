module counter (clk, reset, switch3, outleds);
input          clk;
input          reset;
input 		switch3;
output [7:0]   outleds;

reg   [63:0]    leds;  
wire  [7:0]     outleds = leds[63:55];  

always @(posedge clk)
  if (!reset)            leds <= 1;
  else if (switch3)                 leds  <= leds + 1;
  else		leds <= leds;
endmodule
