`timescale 1ns / 1ps

module tb ();

reg clk;
reg reset;
reg up = 1;
reg down = 1;
reg left = 1;
reg right = 1;

initial clk = 0;
initial forever #5 clk = ~clk;

initial
  begin
         reset <= 0;
#1000    reset <= 1;
#100	 up <= 0;
#5	 up <= 1;
#25	 up <= 0;
#5	 up <= 1;
#25 	 down <= 0;
#5	 down <= 1;

#25	 left <= 0;
#5	 left <= 1;
#5	 left <= 0;
#5 	 left <= 1;
#5       left <= 0;
#5       left <= 1;
#5       left <= 0;
#5       left <= 1;
#15	 right <= 0;
#5	 right <= 1;

#6000    $display("made it to 6000 @ %t", $time);

#5000   $finish;
  end

VGAWrite frog1 (
                 .clk(clk),
                 .sw5(reset),
                 .sw4(up),
                 .sw3(down),
		 .sw1(left),
		 .sw2(right));


initial 
    $dumpfile("verilog.dmp");

initial
    $dumpvars;


endmodule
