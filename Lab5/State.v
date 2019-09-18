`timescale 1ns / 1ps

module State(input wire sw1, input wire sw2, input wire button, input wire reset, output reg detected_signal);

reg [7:0] count;

always @(posedge clk)
begin
count <= count + 1;
end

endmodule
