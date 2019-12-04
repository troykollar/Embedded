// FPGA VGA Graphics Part 1: Square Animation
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module frog #(
    H_WIDTH=11,      // half obstacle width (for ease of co-ordinate calculations)
	 H_HEIGHT = 11,		// half obstacle height
    IX=320,         // initial horizontal position of square centre
    IX_DIR=1,       // initial horizontal direction: 1 is right, 0 is left
    IY_DIR=1,       // initial vertical direction: 1 is down, 0 is up
    D_WIDTH=640,    // width of display
    D_HEIGHT=480,    // height of display
	 RW1_Y=72
    )
    (
    input wire i_clk,         // base clock
    input wire i_ani_stb,     // animation clock: pixel clock is 1 pix/frame
    input wire i_rst,         // reset: returns animation to starting position
    input wire i_animate,     // animate when input is high
	 input wire i_up_btn,		// high when the user presses "up"
	 input wire i_down_btn,		// hight when the user presses "down"
	 input wire i_right_btn,	// high when user presses "right"
	 input wire i_left_btn,		// high when user presses "left"
	 input wire i_dead,
    output wire [11:0] o_x1,  // square left edge: 12-bit value: 0-4095
    output wire [11:0] o_x2,  // square right edge
    output wire [11:0] o_y1,  // square top edge
    output wire [11:0] o_y2,   // square bottom edge
	 output wire win				// at top of level
    );
	 
	 parameter RW0_Y = RW1_Y - 48;	//24
	 parameter RW2_Y = RW1_Y + 48;	//120
	 parameter RW3_Y = RW2_Y + 48;	//168
	 parameter RW4_Y = RW3_Y + 48;	//216
	 parameter RW5_Y = RW4_Y + 48;	//264
	 parameter RW6_Y = RW5_Y + 48;	//312
	 parameter RW7_Y = RW6_Y + 48;	//360
	 parameter RW8_Y = RW7_Y + 48;	//408
	 parameter RW9_Y = RW8_Y + 48;	//456
	 parameter IY = RW9_Y;

    reg [11:0] x = IX;   // horizontal position of square centre
    reg [11:0] y = IY;   // vertical position of square centre
    reg x_dir = IX_DIR;  // horizontal animation direction
    reg y_dir = IY_DIR;  // vertical animation direction

    assign o_x1 = x - H_WIDTH;  // left: centre minus half horizontal size
    assign o_x2 = x + H_WIDTH;  // right
    assign o_y1 = y - H_HEIGHT;  // top
    assign o_y2 = y + H_HEIGHT;  // bottom
	 assign win = (y == RW0_Y);
	 
	 wire up = i_up_btn ? 0: 1;
	 wire down = i_down_btn ? 0: 1;
	 wire left = i_left_btn ? 0: 1;
	 wire right = i_right_btn ? 0: 1;
	 
	reg [11:0] nextX;	
	reg [11:0] nextY;
	
	always @(posedge i_clk)
		if (i_rst) nextY <= IY;
		else if (i_dead) nextY <= IY;
		else if (win)	nextY <= IY;
		else if (up)
			case (y)
			RW0_Y:	nextY <= y;
			RW1_Y:	nextY <= RW0_Y;
			RW2_Y:	nextY <= RW1_Y;
			RW3_Y:	nextY <=	RW2_Y;
			RW4_Y:	nextY <=	RW3_Y;
			RW5_Y:	nextY <=	RW4_Y;
			RW6_Y:	nextY <=	RW5_Y;
			RW7_Y:	nextY <=	RW6_Y;
			RW8_Y:	nextY <=	RW7_Y;
			RW9_Y:	nextY <=	RW8_Y;
			endcase
		else if (down)
			case (y)
			RW0_Y:	nextY <= RW1_Y;
			RW1_Y:	nextY <= RW2_Y;
			RW2_Y:	nextY <= RW3_Y;
			RW3_Y:	nextY <=	RW4_Y;
			RW4_Y:	nextY <=	RW5_Y;
			RW5_Y:	nextY <=	RW6_Y;
			RW6_Y:	nextY <=	RW7_Y;
			RW7_Y:	nextY <=	RW8_Y;
			RW8_Y:	nextY <=	RW9_Y;
			RW9_Y:	nextY <=	y;
			endcase
		else	nextY <= nextY;
		
	always @(posedge i_clk)
		if (i_rst) nextX <= IX;
		else if (i_dead) nextX <= IX;
		else if (win) nextX <= IX;
		else if (right)
			if (x == 620)	nextX <= x;
			else nextX <= x + 20;
		else if (left)
			if (x == 20) nextX <= x;
			else nextX <= x - 20;
		else nextX <= nextX;
		
	always @(posedge i_clk)
		if (i_rst) y <= IY;
		else if (i_dead) y <= IY;
		else if (win)	  y <= IY;
		else if (i_animate && i_ani_stb)
			if (y < nextY) y <= y + 4;
			else if (y > nextY) y <= y - 4;
			else	y <= y;
		else y <= y;
		
	always @(posedge i_clk)
		if (i_rst) x <= IX;
		else if (i_dead) x <= IX;
		else if (win)	x <= IX;
		else if (i_animate && i_ani_stb)
			if (x < nextX) x <= x + 4;
			else if (x > nextX) x <= x - 4;
			else	x <= x;
		else x <= x;
		
endmodule