`timescale 1ns / 1ps

module state_machine(input clk, input sw1, input sw2, input button, input reset, output reg detected_signal, output reg [7:0] outleds = 8'b0000_0000);

//Debounce Button Code//
reg 			button_reg;
reg 			button_sync;
reg [31:0]	button_count;
reg [11:0]	answer;
parameter DEBOUNCE_DELAY = 32'd0_500_000;

always @(posedge clk) button_reg <= button;
always @(posedge clk) button_sync <= !button_reg;

assign		button_done = (button_count == DEBOUNCE_DELAY);
assign		button_click = (button_count == DEBOUNCE_DELAY - 1);

always @(posedge clk)
		if(!button_sync) 		button_count <= 0;
		else if(button_done) 	button_count <= button_count;
		else 							button_count <= button_count + 1;
		
always @(posedge clk)
		if (button_click)	answer <= answer + 1;
		else if (!reset)	answer <= 0;
		else					answer <= answer;


//Actual State Machine Code//
reg [3:0] state = 4'b0000;
always @(answer)
	case(state)
		0:
			if (!reset)		state <= 0;
			else if (sw1 && sw2)	state <= 1;
			else if (!sw1 && sw2)	state <= 3;
			else			state <= 0;
		1:
			if (!reset)		state <= 0;
			else if (sw1 && sw2)	state <= 2;
			else if (!sw1 && sw2)	state <= 3;
			else			state <= 0;
		2:
			if (!reset)		state <= 0;
			else if (sw1 && sw2)	state <= 7;
			else if (!sw1 && sw2)	state <= 3;
			else			state <= 0;
		3:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= 4;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		4:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= state;
			else if (sw1 && !sw2)	state <= 5;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		5:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= 6;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		6:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= 4;
			else if (sw1 && !sw2)	state <= 8;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		7:	state <= 0;
		8:	state <= 0;
		15:
			if (!reset)		state <= 0;
			else			state <= state;
	endcase

always @(state)
	outleds[3:0] <= state;

endmodule
