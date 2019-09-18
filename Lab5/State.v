`timescale 1ns / 1ps

module state_machine(input wire clk, input wire sw1, input wire sw2, input wire button, input wire reset, output reg detected_signal, output reg [7:0] outleds = 8'b0000_0000);

reg [3:0] state = 4'b0000;

always @(posedge button)
	case(state)
		0:
			if (reset)		state <= 0;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		1:
			if (reset)		state <= 0;
			else if (sw1 && sw2)	state <= 2;
			else			state <= 0;
		2:
			if (reset)		state <= 0;
			else if (sw1 && sw2)	state <= 15;
			else			state <= 0;
		15:
			if (reset)		state <= 0;
			else			state <= state;
	endcase

always @(state)
	outleds[3:0] <= state;

endmodule
