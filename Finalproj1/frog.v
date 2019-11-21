// FPGA VGA Graphics Part 1: Square Animation
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module frog #(
    H_WIDTH=11,      // half obstacle width (for ease of co-ordinate calculations)
	 H_HEIGHT = 11,		// half obstacle height
    IX=320,         // initial horizontal position of square centre
    IY=460,         // initial vertical position of square centre
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
			

    always @ (posedge i_clk)
    begin
        if (i_rst)  // on reset return to starting position
            y <= IY;
        if (i_animate && i_ani_stb)
		  begin
				if (up)	y <= y - 2;
				else if (down)	y <= y + 2;
				else if (i_rst) y <= IY;
				else		y <= y;
		  end
    end
	 
	 always @(posedge i_clk)
		if (i_animate && i_ani_stb)
			if (i_rst)	x <= IX;
			else if (left) x <= x-2;
			else if (right) x <= x + 2;
			else x <= x;
		
endmodule