`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
reg [7:0] counter_value;
reg sw1;
reg sw2;
reg button;
reg detected_signal;

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

State state1 (
                 .reset(reset),
		 .sw1(sw1),
		 .sw2(sw2),
		 .button(button),
                 .detected_signal(detected_signal));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
