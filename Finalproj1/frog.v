// FPGA VGA Graphics Part 1: Square Animation
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module frog #(
    H_WIDTH=11,      // half obstacle width (for ease of co-ordinate calculations)
	 H_HEIGHT = 11,		// half obstacle height
    IX=320,         // initial horizontal position of square centre
    IY=469,         // initial vertical position of square centre
    IX_DIR=1,       // initial horizontal direction: 1 is right, 0 is left
    IY_DIR=1,       // initial vertical direction: 1 is down, 0 is up
    D_WIDTH=640,    // width of display
    D_HEIGHT=480    // height of display
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
    output wire [11:0] o_y2   // square bottom edge
    );

    reg [11:0] x = IX;   // horizontal position of square centre
    reg [11:0] y = IY;   // vertical position of square centre
    reg x_dir = IX_DIR;  // horizontal animation direction
    reg y_dir = IY_DIR;  // vertical animation direction

    assign o_x1 = x - H_WIDTH;  // left: centre minus half horizontal size
    assign o_x2 = x + H_WIDTH;  // right
    assign o_y1 = y - H_HEIGHT;  // top
    assign o_y2 = y + H_HEIGHT;  // bottom
	 
	 wire up = i_up_btn ? 0: 1;
	 wire down = i_down_btn ? 0: 1;
	 wire left = i_left_btn ? 0: 1;
	 wire right = i_right_btn ? 0: 1;
	 
	 
/*	 always @ (posedge i_clk)
		if (!i_up_btn)		up <= 1;
		else					up <= 0;
		
	 always @ (posedge i_clk)
		if (!i_down_btn)	down <= 1;
		else					down <= 0;
		
	 always @ (posedge i_clk)
		if (!i_right_btn) right <= 1;
		else					right <= 0;
		
	 always @ (posedge i_clk)
		if (!i_left_btn)  left <= 1;
		else					left <= 0;*/
		
	reg up_inProg = 0;
	reg down_inProg = 0;
	reg right_inProg = 0;
	reg left_inProg = 0;
	reg [5:0] distance = 0;
	parameter HOP_DIS =12;
	parameter HOP_DIS_4 = 4;
	
	//TODO Add reset/dead logic to stop movement when dying
	always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (!up_inProg && !down_inProg && !right_inProg && !left_inProg)
				if (up)	up_inProg <= 1;
				else		up_inProg <= 0;
			else if (i_dead)	up_inProg <= 0;
			else if (distance == HOP_DIS) up_inProg <= 0;
			else	up_inProg <= up_inProg;
		else	up_inProg <= up_inProg;
		
	always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (!up_inProg && !down_inProg && !right_inProg && !left_inProg)
				if (down)	down_inProg <= 1;
				else		down_inProg <= 0;
			else if (i_dead)		down_inProg <= 0;
			else if (distance == HOP_DIS) down_inProg <= 0;
			else	down_inProg <= down_inProg;
		else	down_inProg <= down_inProg;
		
	always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (!up_inProg && !down_inProg && !right_inProg && !left_inProg)
				if (right)	right_inProg <= 1;
				else		right_inProg <= 0;
			else if (i_dead)	right_inProg <= 0;
			else if (distance == HOP_DIS) right_inProg <= 0;
			else	right_inProg <= right_inProg;
		else	right_inProg <= right_inProg;
		
	always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (!up_inProg && !down_inProg && !right_inProg && !left_inProg)
				if (left)	left_inProg <= 1;
				else		left_inProg <= 0;
			else if (i_dead) left_inProg <= 0;
			else if (distance == HOP_DIS) left_inProg <= 0;
			else	left_inProg <= left_inProg;
		else	left_inProg <= left_inProg;
		
	always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (!up_inProg && !down_inProg && !right_inProg && !left_inProg)
				distance <= 0;
			else if (up_inProg) distance <= distance + HOP_DIS_4;
			else if (down_inProg) distance <= distance + HOP_DIS_4;
			else if (right_inProg) distance <= distance + HOP_DIS_4;
			else if (left_inProg) distance <= distance + HOP_DIS_4;
			else if (distance == HOP_DIS)	distance <= 0;
			else distance <= distance;
			
	 always @(posedge i_clk)
		if (i_rst)			 y <= IY;
		else if (i_animate && i_ani_stb)
			if (i_dead)	 y <= IY;
			else if (up_inProg)	y <= y - HOP_DIS_4;
			else if (down_inProg) y <= y + HOP_DIS_4;
			else	y <= y;
		else y <= y;
		
	 always @(posedge i_clk)
		if (i_rst)			x <= IX;
		else if (i_animate && i_ani_stb)
			if (i_dead)	x <= IX;
			else if (right_inProg) x <= x + HOP_DIS_4;
			else if (left_inProg) x <= x - HOP_DIS_4;
			else x <= x;
		else x <= x;
		
	 
	 //constant movement
/*	 always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (i_rst)	y <= IY;
			else if (i_dead) y <= IY;
			else if (up)	y <= y - 2;
			else if (down)	y <= y + 2;
			else	y <= y;
	 
	 always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (i_rst)	x <= IX;
			else if (i_dead) x <= IX;
			else if (left) x <= x-2;
			else if (right) x <= x + 2;
			else x <= x;*/
		
endmodule