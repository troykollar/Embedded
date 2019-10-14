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

initial
  begin	
	sw4 <= 1;
	sw5 <= 1;
	#100	sw4 <= 0;
	#10	sw4 <= 1;
	#10000	sw5 <= 0;
	#10	sw5 <= 1;
	#2000   $finish;
  end

reflex reflex1 (
                 .reset(reset),
		 .ready_click(sw4),
		 .fire_click(sw5),
		 .clk(clk),
                 .outleds(outleds));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
