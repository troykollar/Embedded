`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
wire [3:0] counter_value;


initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
         reset <= 0;
#1000    reset <= 1;
#6000    $display("made it to 6000 @ %t", $time);

#5000   $finish;
  end

always @(counter_value)
    $display("counter value is now %x at time %t",counter_value, $time);

counter count1 (
                 .clk(clk),
                 .reset(reset),
                 .top(),
                 .outleds(counter_value));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
