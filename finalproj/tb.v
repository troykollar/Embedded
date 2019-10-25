`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
reg up;
reg down;
reg left;
reg right;

initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
         reset <= 0;
#1000    reset <= 1;
#6000    $display("made it to 6000 @ %t", $time);

#5000   $finish;
  end

frogger frog1 (
                 .clk(clk),
                 .reset(reset),
                 .up(up),
                 .down(down),
		 .left(left),
		 .right(right));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
