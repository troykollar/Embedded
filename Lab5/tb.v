`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
reg [7:0] counter_value;
reg sw1;
reg sw2;
reg button;
wire detected_signal;
wire [7:0] outleds;

initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
#0	button <= 0;
#0	sw1 <= 0;
#0	sw2 <= 0;
#0	reset <= 1;
#100	reset <= 0;
#500	sw1 <= 1;
#500	sw2 <= 1;

#600	button <= 1;
#605	button <= 0;
#610	button <= 1;
#615	button <= 0;
#620	button <= 1;
#625	button <= 0;

#6000    $display("made it to 6000 @ %t", $time);

#5000   $finish;
  end

always @(counter_value)
    $display("counter value is now %x at time %t",counter_value, $time);

state_machine state1 (
                 .reset(reset),
		 .sw1(sw1),
		 .sw2(sw2),
		 .button(button),
		 .clk(clk),
                 .detected_signal(detected_signal),
	 	 .outleds(outleds));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
