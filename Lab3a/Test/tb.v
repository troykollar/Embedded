`timescale 1ns / 1ps

module tb ();

reg clk;
reg button;
wire button_out;


initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
#0	button = 0;
#700	button = 1;
#1000  	button = 0;
#1500 	button = 1;
#2000	button = 0;
#6000    $display("made it to 6000 @ %t", $time);

#6000   $finish;
  end


debounce_count button1 (
                 .button(button),
                 .clk(clk),
		 .button_count(button_out)
 );



initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
