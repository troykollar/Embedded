`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
reg [7:0] counter_value;
reg sw4;
reg sw5;
wire [7:0] outleds;

initial clk = 0;
initial forever #5 clk = ~clk;
initial forever #5 counter_value = counter_value + 1;

initial
  begin	
	sw4 <= 1;
	sw5 <= 1;
	#100	sw4 <= 0;
	#800	sw4 <= 1;
	#10000	sw5 <= 0;
	#800	sw5 <= 1;
	#8_000_000   $finish;
  end

always @(counter_value)
	if (counter_value%1000 == 0)
		$display("counter value is now %x at time %t",counter_value, $time);

reflex reflex1 (
                 .reset(reset),
		 .Switch4(sw4),
		 .Switch5(sw5),
		 .clk(clk),
                 .outleds(outleds));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
