// FPGA VGA Graphics Part 1: Square Animation
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module hop #(
    HOP_DIS=48,      // travel distance for each hop
	 HOP_DIS_4 = 12	// 1/4 of the travel distance
    D_WIDTH=640,    // width of display
    D_HEIGHT=480    // height of display
    )
    (
    input wire i_clk,         // base clock
    input wire i_ani_stb,     // animation clock: pixel clock is 1 pix/frame
    input wire i_rst,         // reset: returns animation to starting position
    input wire i_animate,     // animate when input is high
	 input wire i_up,
	 input wire i_down,
	 input wire i_right,
	 input wire i_left,
	 input wire	[11:0] x_coord			//input x coord
	 input wire [11:0] y_coord			//input y coord
    output wire [11:0] o_x,   //output x coordinate
    output wire [11:0] o_y  	//output y coordinate
    );

	 reg [11:0] x = x_coord;
	 reg [11:0] y = y_coord;
	 
    assign o_x = x;  // left: centre minus half horizontal size
    assign o_y = y;  // right

    always @ (posedge i_clk)
    begin
        if (i_rst)  // on reset return to starting position
        begin
            x <= IX;
            y <= IY;
            x_dir <= IX_DIR;
            y_dir <= IY_DIR;
        end
        if (i_animate && i_ani_stb)
        begin
            x <= (x_dir) ? x + 1 : x - 1;  // move right if positive x_dir
            //y <= (y_dir) ? y + 1 : y - 1;  // move down if positive y_dir

            if (x <= 0)  // square goes off left of screen
                x <= D_WIDTH + H_WIDTH - 1;  // reset location to right of screen
            if (x >= (D_WIDTH + H_WIDTH))  // edge of square goes off right of screen
                x <= 1;  // reset to left of screen        
            if (y <= H_HEIGHT + 1)  // edge of square at top of screen
                y_dir <= 1;  // change direction to down
            if (y >= (D_HEIGHT - H_HEIGHT - 1))  // edge of square at bottom
                y_dir <= 0;  // change direction to up              
        end
    end
endmodule