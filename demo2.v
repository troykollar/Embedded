`timescale 1ns / 1ps

module demo2(

    input                clk,
    input                resetn,
    input                transfer,
    
    input [7:0]          switches,
  
    output reg [7:0]     leds 
    );

reg [24:0]               count;
wire                     enable = count[21];

always @(posedge clk)    count <= count+1'b1;

always @(posedge enable)
   if (!resetn)          leds = 8'h01;
   else if (!transfer)   leds = switches;
	else                  leds = {leds[0],leds[7:1]};
	
endmodule

