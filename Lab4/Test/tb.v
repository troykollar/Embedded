`timescale 1ns / 1ps

module tb ();

reg clk;
reg button;
wire [7:0] button_out;
reg reset;


initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
#0	button = 0;
#0 	reset = 0;
#100	button = 1;
#500	 button = 0;
#800 	button = 1;
#1000	button = 0;

#6000   $finish;
  end


debounce_count button1 (
                 .button(button),
                 .clk(clk),
		 .answer(button_out),
		 .reset(reset)
 );



initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
