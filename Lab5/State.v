`timescale 1ns / 1ps

module state_machine(input wire clk, input wire sw1, input wire sw2, input wire button, input wire reset, output reg detected_signal);

reg [3:0] state = 4'b0000;


always @(button)
	case(state)
		0:
			if (sw1 && sw2)		state <= 1;
			else			state <= 0;
		1:
			if (sw1 && sw2)		state <= 2;
			else			state <= 0;
		2:
			if (sw1 && sw2)		state <= 15;
			else			state <= 0;
	endcase

endmodule
