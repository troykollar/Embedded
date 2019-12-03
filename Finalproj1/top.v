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

	reg dead = 0;
		
    wire rst = ~RST_BTN;    // reset is active low on Arty & Nexys Video
    //wire rst = RST_BTN;  // reset is active high on Basys3 (BTNC)

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

	//******Row 1 squares**************************//
    wire sq_a, sq_b, sq_c, sq_d;
    wire [11:0] sq_a_x1, sq_a_x2, sq_a_y1, sq_a_y2;  // 12-bit values: 0-4095 
    wire [11:0] sq_b_x1, sq_b_x2, sq_b_y1, sq_b_y2;
    wire [11:0] sq_c_x1, sq_c_x2, sq_c_y1, sq_c_y2;
	 wire [11:0] sq_d_x1, sq_d_x2, sq_d_y1, sq_d_y2;
	 
	 parameter rw1y = 72;
	 parameter rw1width = 40;
	 parameter rw1dir = 1;

    square #(.IX(0), .IY(rw1y), .H_WIDTH(rw1width), .IX_DIR(rw1dir)) sq_a_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_a_x1),
        .o_x2(sq_a_x2),
        .o_y1(sq_a_y1),
        .o_y2(sq_a_y2)
    );

    square #(.IX(160), .IY(rw1y), .IY_DIR(rw1dir), .H_WIDTH(rw1width), .IX_DIR(rw1dir)) sq_b_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_b_x1),
        .o_x2(sq_b_x2),
        .o_y1(sq_b_y1),
        .o_y2(sq_b_y2)
    );    

    square #(.IX(320), .IY(rw1y), .H_WIDTH(rw1width), .IX_DIR(rw1dir), .IY_DIR(rw1dir)) sq_c_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_c_x1),
        .o_x2(sq_c_x2),
        .o_y1(sq_c_y1),
        .o_y2(sq_c_y2)
    );
	 
    square #(.IX(480), .IY(rw1y), .H_WIDTH(rw1width), .IX_DIR(rw1dir), .IY_DIR(rw1dir)) sq_d_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_d_x1),
        .o_x2(sq_d_x2),
        .o_y1(sq_d_y1),
        .o_y2(sq_d_y2)
    );
	 
	 //***************Row 2 squares****************************
	 wire sq_2a, sq_2b, sq_2c;
    wire [11:0] sq_2a_x1, sq_2a_x2, sq_2a_y1, sq_2a_y2;  // 12-bit values: 0-4095 
    wire [11:0] sq_2b_x1, sq_2b_x2, sq_2b_y1, sq_2b_y2;
    wire [11:0] sq_2c_x1, sq_2c_x2, sq_2c_y1, sq_2c_y2;
	 
	 parameter rw2y = rw1y + 48;
	 parameter rw2width = 60;
	 parameter rw2dir = 0;

    square #(.IX(0), .IY(rw2y), .H_WIDTH(rw2width), .IX_DIR(rw2dir)) sq_2a_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_2a_x1), .o_x2(sq_2a_x2), .o_y1(sq_2a_y1), .o_y2(sq_2a_y2)
    );
	 
	 square #(.IX(250), .IY(rw2y), .H_WIDTH(rw2width), .IX_DIR(rw2dir)) sq_2b_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_2b_x1), .o_x2(sq_2b_x2), .o_y1(sq_2b_y1), .o_y2(sq_2b_y2)
    );
	 
	 square #(.IX(500), .IY(rw2y), .H_WIDTH(rw2width), .IX_DIR(rw2dir)) sq_2c_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_2c_x1), .o_x2(sq_2c_x2), .o_y1(sq_2c_y1), .o_y2(sq_2c_y2)
    );
	 
	 //****************Row 3 squares********************************
	 wire sq_3a, sq_3b, sq_3c, sq_3d, sq_3e, sq_3f;
    wire [11:0] sq_3a_x1, sq_3a_x2, sq_3a_y1, sq_3a_y2;  // 12-bit values: 0-4095 
    wire [11:0] sq_3b_x1, sq_3b_x2, sq_3b_y1, sq_3b_y2;
    wire [11:0] sq_3c_x1, sq_3c_x2, sq_3c_y1, sq_3c_y2;
	 wire [11:0] sq_3d_x1, sq_3d_x2, sq_3d_y1, sq_3d_y2;
	 wire [11:0] sq_3e_x1, sq_3e_x2, sq_3e_y1, sq_3e_y2;
	 wire [11:0] sq_3f_x1, sq_3f_x2, sq_3f_y1, sq_3f_y2;
	 
	 parameter rw3y = rw2y + 48;
	 parameter rw3width = 20;
	 parameter rw3dir = 1;

    square #(.IX(0), .IY(rw3y), .H_WIDTH(rw3width), .IX_DIR(rw3dir)) sq_3a_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_3a_x1), .o_x2(sq_3a_x2), .o_y1(sq_3a_y1), .o_y2(sq_3a_y2)
    );
	 
	 square #(.IX(100), .IY(rw3y), .H_WIDTH(rw3width), .IX_DIR(rw3dir)) sq_3b_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_3b_x1), .o_x2(sq_3b_x2), .o_y1(sq_3b_y1), .o_y2(sq_3b_y2)
    );
	 
	 square #(.IX(200), .IY(rw3y), .H_WIDTH(rw3width), .IX_DIR(rw3dir)) sq_3c_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_3c_x1), .o_x2(sq_3c_x2), .o_y1(sq_3c_y1), .o_y2(sq_3c_y2)
    );
	 
	 square #(.IX(300), .IY(rw3y), .H_WIDTH(rw3width), .IX_DIR(rw3dir)) sq_3d_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_3d_x1), .o_x2(sq_3d_x2), .o_y1(sq_3d_y1), .o_y2(sq_3d_y2)
    );
	 
	 square #(.IX(400), .IY(rw3y), .H_WIDTH(rw3width), .IX_DIR(rw3dir)) sq_3e_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_3e_x1), .o_x2(sq_3e_x2), .o_y1(sq_3e_y1), .o_y2(sq_3e_y2)
    );
	 
	 square #(.IX(500), .IY(rw3y), .H_WIDTH(rw3width), .IX_DIR(rw3dir)) sq_3f_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_3f_x1), .o_x2(sq_3f_x2), .o_y1(sq_3f_y1), .o_y2(sq_3f_y2)
    );
	 
	 //**************Row 4 squares*********************************
	 wire sq_4a, sq_4b, sq_4c;
	 wire [11:0] sq_4a_x1, sq_4a_x2, sq_4a_y1, sq_4a_y2;  // 12-bit values: 0-4095 
    wire [11:0] sq_4b_x1, sq_4b_x2, sq_4b_y1, sq_4b_y2;
    wire [11:0] sq_4c_x1, sq_4c_x2, sq_4c_y1, sq_4c_y2;
	 
	 parameter rw4y = rw3y + 96;
	 parameter rw4width = 60;
	 parameter rw4dir = 1;
	 
	 square #(.IX(0), .IY(rw4y), .H_WIDTH(rw2width), .IX_DIR(rw4dir)) sq_4a_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_4a_x1), .o_x2(sq_4a_x2), .o_y1(sq_4a_y1), .o_y2(sq_4a_y2)
    );
	 
	 square #(.IX(250), .IY(rw4y), .H_WIDTH(rw2width), .IX_DIR(rw4dir)) sq_4b_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_4b_x1), .o_x2(sq_4b_x2), .o_y1(sq_4b_y1), .o_y2(sq_4b_y2)
    );
	 
	 square #(.IX(500), .IY(rw4y), .H_WIDTH(rw2width), .IX_DIR(rw4dir)) sq_4c_anim (
        .i_clk(CLK), .i_ani_stb(pix_stb), .i_rst(rst), .i_animate(animate),
        .o_x1(sq_4c_x1), .o_x2(sq_4c_x2), .o_y1(sq_4c_y1), .o_y2(sq_4c_y2)
    );
	 
	 //*****************Row 5 squares*******************************
    wire sq_5a, sq_5b, sq_5c, sq_5d;
    wire [11:0] sq_5a_x1, sq_5a_x2, sq_5a_y1, sq_5a_y2;  // 12-bit values: 0-4095 
    wire [11:0] sq_5b_x1, sq_5b_x2, sq_5b_y1, sq_5b_y2;
    wire [11:0] sq_5c_x1, sq_5c_x2, sq_5c_y1, sq_5c_y2;
	 wire [11:0] sq_5d_x1, sq_5d_x2, sq_5d_y1, sq_5d_y2;
	 
	 parameter rw5y = rw4y + 48;
	 parameter rw5dir = 0;

    square #(.IX(0), .IY(rw5y), .H_WIDTH(rw1width), .IX_DIR(rw5dir)) sq_5a_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_5a_x1),
        .o_x2(sq_5a_x2),
        .o_y1(sq_5a_y1),
        .o_y2(sq_5a_y2)
    );

    square #(.IX(160), .IY(rw5y), .H_WIDTH(rw1width), .IX_DIR(rw5dir)) sq_5b_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_5b_x1),
        .o_x2(sq_5b_x2),
        .o_y1(sq_5b_y1),
        .o_y2(sq_5b_y2)
    );    

    square #(.IX(320), .IY(rw5y), .H_WIDTH(rw1width), .IX_DIR(rw5dir)) sq_5c_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_5c_x1),
        .o_x2(sq_5c_x2),
        .o_y1(sq_5c_y1),
        .o_y2(sq_5c_y2)
    );
	 
    square #(.IX(480), .IY(rw5y), .H_WIDTH(rw1width), .IX_DIR(rw5dir)) sq_5d_anim (
        .i_clk(CLK), 
        .i_ani_stb(pix_stb),
        .i_rst(rst),
        .i_animate(animate),
        .o_x1(sq_5d_x1),
        .o_x2(sq_5d_x2),
        .o_y1(sq_5d_y1),
        .o_y2(sq_5d_y2)
    );
	 //*****************Frog animation******************************
	 wire fr;
	 wire [11:0] frog_x1, frog_x2, frog_y1, frog_y2;
	 
	 frog #(.IX(320), .IY(rw3y)) frog_anim (
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
			.i_left_btn(left_btn),
			.i_dead(dead)
		);
	
	//rw1 squares
    assign sq_a = ((x > sq_a_x1) & (y > sq_a_y1) &
        (x < sq_a_x2) & (y < sq_a_y2)) ? 1 : 0;
    assign sq_b = ((x > sq_b_x1) & (y > sq_b_y1) &
        (x < sq_b_x2) & (y < sq_b_y2)) ? 1 : 0;
    assign sq_c = ((x > sq_c_x1) & (y > sq_c_y1) &
        (x < sq_c_x2) & (y < sq_c_y2)) ? 1 : 0;
	 assign sq_d = ((x > sq_d_x1) & (y > sq_d_y1) &
        (x < sq_d_x2) & (y < sq_d_y2)) ? 1 : 0;

	//rw2 squares
	 assign sq_2a = ((x > sq_2a_x1) & (y > sq_2a_y1) &
        (x < sq_2a_x2) & (y < sq_2a_y2)) ? 1 : 0;
	 assign sq_2b = ((x > sq_2b_x1) & (y > sq_2b_y1) &
        (x < sq_2b_x2) & (y < sq_2b_y2)) ? 1 : 0;
	 assign sq_2c = ((x > sq_2c_x1) & (y > sq_2c_y1) &
        (x < sq_2c_x2) & (y < sq_2c_y2)) ? 1 : 0;
		  
	//rw3 squares
	 assign sq_3a = ((x > sq_3a_x1) & (y > sq_3a_y1) &
        (x < sq_3a_x2) & (y < sq_3a_y2)) ? 1 : 0;
	 assign sq_3b = ((x > sq_3b_x1) & (y > sq_3b_y1) &
        (x < sq_3b_x2) & (y < sq_3b_y2)) ? 1 : 0;
	 assign sq_3c = ((x > sq_3c_x1) & (y > sq_3c_y1) &
        (x < sq_3c_x2) & (y < sq_3c_y2)) ? 1 : 0;
	 assign sq_3d = ((x > sq_3d_x1) & (y > sq_3d_y1) &
        (x < sq_3d_x2) & (y < sq_3d_y2)) ? 1 : 0;
	 assign sq_3e = ((x > sq_3e_x1) & (y > sq_3e_y1) &
        (x < sq_3e_x2) & (y < sq_3e_y2)) ? 1 : 0;
	 assign sq_3f = ((x > sq_3f_x1) & (y > sq_3f_y1) &
        (x < sq_3f_x2) & (y < sq_3f_y2)) ? 1 : 0;
		  
	 //rw4 squares
	 assign sq_4a = ((x > sq_4a_x1) & (y > sq_4a_y1) &
        (x < sq_4a_x2) & (y < sq_4a_y2)) ? 1 : 0;
	 assign sq_4b = ((x > sq_4b_x1) & (y > sq_4b_y1) &
        (x < sq_4b_x2) & (y < sq_4b_y2)) ? 1 : 0;
	 assign sq_4c = ((x > sq_4c_x1) & (y > sq_4c_y1) &
        (x < sq_4c_x2) & (y < sq_4c_y2)) ? 1 : 0;
		  
	//rw5 squares
    assign sq_5a = ((x > sq_5a_x1) & (y > sq_5a_y1) &
        (x < sq_5a_x2) & (y < sq_5a_y2)) ? 1 : 0;
    assign sq_5b = ((x > sq_5b_x1) & (y > sq_5b_y1) &
        (x < sq_5b_x2) & (y < sq_5b_y2)) ? 1 : 0;
    assign sq_5c = ((x > sq_5c_x1) & (y > sq_5c_y1) &
        (x < sq_5c_x2) & (y < sq_5c_y2)) ? 1 : 0;
	 assign sq_5d = ((x > sq_5d_x1) & (y > sq_5d_y1) &
        (x < sq_5d_x2) & (y < sq_5d_y2)) ? 1 : 0;
		  
		  
	 assign fr = ((x > frog_x1) & (y > frog_y1) &
		  (x < frog_x2) & (y < frog_y2)) ? 1 : 0;
		  
/*	 parameter rw1top = rw1y - 15;
	 parameter rw1bot = rw1y + 15;
	  always @(posedge CLK)
		if (((frog_y1 > rw1top) && (frog_y1 < rw1bot)) || ((frog_y2 > rw1top) && (frog_y2 < rw1bot)))	//Collisions with square 1
			if (((frog_x1 > sq_a_x1) && (frog_x1 < sq_a_x2)) || ((frog_x2 > sq_a_x1) && (frog_x2 < sq_a_x2)))
				dead <= 1;
			else if (((frog_x1 > sq_b_x1) && (frog_x1 < sq_b_x2)) || ((frog_x2 > sq_b_x1) && (frog_x2 < sq_b_x2)))
				dead <= 1;
			else if (((frog_x1 > sq_c_x1) && (frog_x1 < sq_c_x2)) || ((frog_x2 > sq_c_x1) && (frog_x2 < sq_c_x2)))
				dead <= 1;
			else if (((frog_x1 > sq_d_x1) && (frog_x1 < sq_d_x2)) || ((frog_x2 > sq_d_x1) && (frog_x2 < sq_d_x2)))
				dead <= 1;
			else	dead <= 0;
		else	dead <= 0;*/
		
		wire any_square;
		assign any_square = sq_a | sq_b | sq_c;
		always @(posedge CLK)
			if (fr & any_square)	dead <= 1;
			else dead <= 0;

    assign VGA_R[1:0] = {2{sq_2a | sq_2b | sq_2c | sq_4a | sq_4b | sq_4c}};  // blue squares
    assign VGA_G[2:0] = {fr, fr, fr};  // frog is green
    assign VGA_B[2:0] = {3{sq_a | sq_b | sq_c | sq_d | sq_3a | sq_3b | sq_3c | sq_3d | sq_3e | sq_3f | sq_5a | sq_5b | sq_5c}};  // red squares
endmodule