`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
wire [7:0] counter_value;
wire [7:0] switch_value;


initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
#500 switch_value <= 0;
#10000 switch_value <= 1;
         reset <= 0;
#500    reset <= 1;
#50000    $display("made it to 6000 @ %t", $time);

#50000   $finish;
  end

always @(counter_value)
    $display("counter value is now %x at time %t",counter_value, $time);

counter count1 (
                 .clk(clk),
                 .reset(reset),
		 .DPSwitch(switch_value),
                 .outleds(counter_value));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
