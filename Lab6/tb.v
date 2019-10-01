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
  	reset <= 0;
	sw4 <= 1;
	sw5 <= 1;
#100	reset <= 1;
#100	sw4 <= 0;
#700	sw4 <= 1;	
#300	sw5 <= 0;

if ($time % 1000 == 0)	$display("made it to ", $time);

#8_000_000   $finish;
  end

always @(counter_value)
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
