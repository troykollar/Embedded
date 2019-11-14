// FPGA VGA Graphics Part 1: Top Module
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module top(
    input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire RST_BTN,         // reset button
	 input wire up_btn,			  // up button
	 input wire down_btn, 		  // down button
	 input wire right_btn,		  // right button
	 input wire left_btn, 		  // left button
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [1:0] VGA_R,    // 4-bit VGA red output
    output wire [2:0] VGA_G,    // 4-bit VGA green output
    output wire [2:0] VGA_B     // 4-bit VGA blue output
    );

    wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    // wire rst = RST_BTN;  // reset is active high on Basys3 (BTNC)

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511
    wire animate;  // high when we're ready to animate at end of drawing

    // generate a 25 MHz pixel strobe
    reg [15:0] cnt = 0;
    reg pix_stb = 0;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000

    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y),
        .o_animate(animate)
    );

    wire sq_a, sq_b, sq_c;
    wire [11:0] sq_a_x1, sq_a_x2, sq_a_y1, sq_a_y2;  // 12-bit values: 0-4095 
    wire [11:0] sq_b_x1, sq_b_x2, sq_b_y1, sq_b_y2;
    wire [11:0] sq_c_x1, sq_c_x2, sq_c_y1, sq_c_y2;

    square #(.IX(160), .IY(120), .H_WIDTH(60), .H_HEIGHT(15), .IX_DIR(1)) sq_a_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_a_x1),
        .o_x2(sq_a_x2),
        .o_y1(sq_a_y1),
        .o_y2(sq_a_y2)
    );

    square #(.IX(320), .IY(240), .IY_DIR(0), .H_WIDTH(20), .H_HEIGHT(15), .IX_DIR(0)) sq_b_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_b_x1),
        .o_x2(sq_b_x2),
        .o_y1(sq_b_y1),
        .o_y2(sq_b_y2)
    );    

    square #(.IX(480), .IY(360), .H_WIDTH(100), .H_HEIGHT(15)) sq_c_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_c_x1),
        .o_x2(sq_c_x2),
        .o_y1(sq_c_y1),
        .o_y2(sq_c_y2)
    );
	 
	 wire fr;
	 wire [11:0] frog_x1, frog_x2, frog_y1, frog_y2;
	 
	 frog #(.IX(320), .IY(200)) frog_anim (
			.i_clk(CLK),
			.i_ani_stb(pix_stb),
			.i_rst(rst),
			.i_animate(animate),
			.o_x1(frog_x1),
			.o_x2(frog_x2),
			.o_y1(frog_y1),
			.o_y2(frog_y2),
			.i_up_btn(up_btn),
			.i_down_btn(down_btn),
			.i_right_btn(right_btn),
			.i_left_btn(left_btn)
		);

    assign sq_a = ((x > sq_a_x1) & (y > sq_a_y1) &
        (x < sq_a_x2) & (y < sq_a_y2)) ? 1 : 0;
    assign sq_b = ((x > sq_b_x1) & (y > sq_b_y1) &
        (x < sq_b_x2) & (y < sq_b_y2)) ? 1 : 0;
    assign sq_c = ((x > sq_c_x1) & (y > sq_c_y1) &
        (x < sq_c_x2) & (y < sq_c_y2)) ? 1 : 0;
	 assign fr = ((x > frog_x1) & (y > frog_y1) &
		  (x < frog_x2) & (y < frog_y2)) ? 1 : 0;

    assign VGA_R[1:0] = {sq_a, sq_a};  // square a is red
    assign VGA_G[2:0] = {fr, fr, fr};  // square b is green
    assign VGA_B[2:0] = {sq_c | sq_b, sq_c | sq_b,sq_c | sq_b};  // square c is blue
endmodule