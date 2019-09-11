module buttoncounter(clk, reset, outleds, button);
input clk;
input reset;
input button;
output [7:0] outleds;

reg [11:0] button_count;
reg [11:0] button_reg;
reg [11:0] button_sync;

parameter DEBOUNCE_DELAY = 32'd0_500_000;   /// 10nS * 1M = 10mS

always @(posedge clk)   button_reg   <= button;
always @(posedge clk)   button_sync  <= button_reg;

assign                  button_done  = (button_count == DEBOUNCE_DELAY); 
assign                  button_click = (button_count == DEBOUNCE_DELAY - 1); 


always @(posedge clk) 
          if (!button_sync)      button_count <= 0;
          else if (button_done)  button_count <= button_count;
          else                   button_count <= button_count + 1;

wire [7:0] outleds = button_count[7:0];
	  
endmodule
