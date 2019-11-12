//Frogger Logic~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module frogger (input clk, input reset, input up, input down, input left, input right, 
					output reg [7:0] vert1, output reg [7:0] vert2, output reg [7:0] vert3,
					output reg [7:0] vert5, output reg [7:0] vert6);	//This module contains frogger logic

	//each vert register is a row that keeps track of cars
	reg [7:0] vert0 = 8'b0000_0000;
	reg [7:0] vert4 = 8'b0000_0000;
	reg [7:0] vert7 = 8'b0000_0000;

	reg [2:0] timeState = 0;	//Keep track of time which determines car locations
	reg [27:0] timeCounter = 0;	//Count the number of clock pulses to keep track of time

	reg [2:0] froggerVerticalState = 7;	//Keep track of what vertical level frogger is on
	reg [7:0] froggerHorizState = 8'b0001_0000;	//Keep track of what horizontal level frogger is on
	reg win = 0;	//Turns to 1 when reaching the top of the level

	//Increase timeState, depending on simulation vs. synthesis
	always @(posedge clk)
		if (reset)
			timeState <= 0;
		else
			if (timeCounter == 100000000) //Change to 100 million for synthesis
				begin
					timeCounter <= 0;
					timeState <= timeState + 1;
				end
			else	timeCounter <= timeCounter + 1;

	//Move vert1 cars based on timeState
	always @(posedge clk)
		case (timeState)
			0: vert1 <= 8'b0111_0111;
			1: vert1 <= 8'b1011_1011;
			2: vert1 <= 8'b1101_1101;
			3: vert1 <= 8'b1110_1110;
			4: vert1 <= 8'b0111_0111;
			5: vert1 <= 8'b1011_1011;
			6: vert1 <= 8'b1101_1101;
			7: vert1 <= 8'b1110_1110;
		endcase

	//Move vert2 cars based on timeState
	always @(posedge clk)
		case (timeState)
					0: vert2 <= 8'b1000_1000;
					1: vert2 <= 8'b0001_0001;
					2: vert2 <= 8'b0010_0010;
					3: vert2 <= 8'b0100_0100;
					4: vert2 <= 8'b1000_1000;
					5: vert2 <= 8'b0001_0001;
					6: vert2 <= 8'b0010_0010;
					7: vert2 <= 8'b0100_0100;
			endcase

	//shift vert3 as timeState changes
	always @(posedge clk)
		case (timeState)
			0: vert3 <= 8'b1100_1100;
			1: vert3 <= 8'b0110_0110;
			2: vert3 <= 8'b0011_0011;
			3: vert3 <= 8'b1001_1001;
			4: vert3 <= 8'b1100_1100;
			5: vert3 <= 8'b0110_0110;
			6: vert3 <= 8'b0011_0011;
			7: vert3 <= 8'b1001_1001;
		endcase

	//shift vert5 as timeState changes
	always @(posedge clk)
		case (timeState)
			0: vert5 <= 8'b1001_1001;
					1: vert5 <= 8'b1100_1100;
					2: vert5 <= 8'b0110_0110;
					3: vert5 <= 8'b0011_0011;
					4: vert5 <= 8'b1001_1001;
					5: vert5 <= 8'b1100_1100;
					6: vert5 <= 8'b0110_0110;
					7: vert5 <= 8'b0011_0011;
		endcase

	//shift vert6 as timeState changes
	always @(posedge clk)
		case (timeState)
			0: vert6 <= 8'b1111_0000;
			1: vert6 <= 8'b0111_1000;
			2: vert6 <= 8'b0011_1100;
			3: vert6 <= 8'b0001_1110;
			4: vert6 <= 8'b0000_1111;
			5: vert6 <= 8'b1000_0111;
			6: vert6 <= 8'b1100_0011;
			7: vert6 <= 8'b1110_0001;
		endcase

	//Check for win state
	always @(posedge clk)
		if (froggerVerticalState == 0) 	win <= 1;
		else				win <= 0;

	//Control frogger vertical position
	always @(posedge clk)
		if (!up)	froggerVerticalState <= froggerVerticalState - 1;
		else if (!down) froggerVerticalState <= froggerVerticalState + 1;
		else	froggerVerticalState <= froggerVerticalState;
	//Control frogger horizontal position
	always @(posedge clk)
		if (froggerHorizState == 8'b1000_0000)
			if (!right)	froggerHorizState <= 8'b0100_0000;
			else		froggerHorizState <= froggerHorizState;
		else if (froggerHorizState == 8'b0000_0001)
			if (!left)	froggerHorizState <= 8'b0000_0010;
			else		froggerHorizState <= froggerHorizState;
		else
			if (!right)	froggerHorizState <= froggerHorizState >> 1;
			else if (!left)	froggerHorizState <= froggerHorizState << 1;
			else		froggerHorizState <= froggerHorizState;

	reg dead = 0;	//possibly remove, use for simulation
	always @(posedge clk)
		if (froggerVerticalState == 6)
			if ((vert6 & froggerHorizState) !== 0) 	dead <= 1;
			else					dead <= dead;
		else if (froggerVerticalState == 5)
			if ((vert6 & froggerHorizState) !== 0)	dead <= 1;
			else					dead <= dead;
		else if (froggerVerticalState == 3)
			if ((vert3 & froggerHorizState) !== 0)	dead <= 1;
			else					dead <= dead;
		else if (froggerVerticalState == 2)
			if ((vert2 & froggerHorizState) !== 0)	dead <= 1;
			else					dead <= dead;
		else if (froggerVerticalState == 1)
			if ((vert1 & froggerHorizState) !== 0)	dead <= 1;
			else					dead <= dead;
		else						dead <= dead;

	reg [7:0] andedReg;	//Remove when synthesizing
	always @(posedge clk)
		andedReg <= froggerHorizState & vert6;

endmodule

//VGA V/Hsync Generator *******************************************
module hvsync_generator(
	input clk,
	output vga_h_sync,
	output vga_v_sync,
	output reg inDisplayArea,
	output reg [9:0] CounterX,
	output reg [8:0] CounterY
  );
    reg vga_HS, vga_VS;

    wire CounterXmaxed = (CounterX == 800); // 16 + 48 + 96 + 640
    wire CounterYmaxed = (CounterY == 525); // 10 + 2 + 33 + 480

    always @(posedge clk)
    if (CounterXmaxed)
      CounterX <= 0;
    else
      CounterX <= CounterX + 1;

    always @(posedge clk)
    begin
      if (CounterXmaxed)
      begin
        if(CounterYmaxed)
          CounterY <= 0;
        else
          CounterY <= CounterY + 1;
      end
    end

    always @(posedge clk)
    begin
      vga_HS <= (CounterX > (640 + 16) && (CounterX < (640 + 16 + 96)));   // active for 96 clocks
      vga_VS <= (CounterY > (480 + 10) && (CounterY < (480 + 10 + 2)));   // active for 2 clocks
    end

    always @(posedge clk)
    begin
        inDisplayArea <= (CounterX < 640) && (CounterY < 480);
    end

    assign vga_h_sync = ~vga_HS;
    assign vga_v_sync = ~vga_VS;

endmodule	//************************************

//Writing to VGA==================================
module VGAWrite(
    input clk,
	 input sw4,
	 input sw3,
	 input sw1,
	 input sw2,
	 input sw5,
    output reg [2:0] pixel,
    output hsync_out,
    output vsync_out
);

	 wire clk_25 = clk_counter == 2'd3;
	 reg [1:0] clk_counter = 0;
	 always @(posedge clk)
		clk_counter = clk_counter + 1;
		
    wire inDisplayArea;
    wire [9:0] CounterX;
	wire [8:0] CounterY;

    hvsync_generator hvsync(
      .clk(clk_25),
      .vga_h_sync(hsync_out),
      .vga_v_sync(vsync_out),
      .CounterX(CounterX),
      .CounterY(CounterY),
      .inDisplayArea(inDisplayArea)
    );
	 
	 wire [7:0] vert1;
	 wire [7:0] vert2;
	 wire [7:0] vert3;
	 wire [7:0] vert5;
	 wire [7:0] vert6;
	 
	 frogger frogLogic(
		.clk(clk),
		.up(sw4),
		.down(sw3),
		.left(sw1),
		.right(sw2),
		.reset(sw5),
		.vert1(vert1),
		.vert2(vert2),
		.vert3(vert3),
		.vert5(vert5),
		.vert6(vert6)
	);
	
	reg [7:0] drawHorizPosition;
	always @(posedge clk)
		if (CounterX < 80)
			drawHorizPosition <= 8'b1000_0000;
		else if (CounterX < 160)
			drawHorizPosition <= 8'b0100_0000;
		else if (CounterX < 240)
			drawHorizPosition <= 8'b0010_0000;
		else if (CounterX < 320)
			drawHorizPosition <= 8'b0001_0000;
		else if (CounterX < 400)
			drawHorizPosition <= 8'b0000_1000;
		else if (CounterX < 480)
			drawHorizPosition <= 8'b0000_0100;
		else if (CounterX < 560)
			drawHorizPosition <= 8'b0000_0010;
		else if (CounterX < 640)
			drawHorizPosition <= 8'b0000_0001;
		else
			drawHorizPosition <= 8'b0000_0000;

   always @(posedge clk_25)
   begin
		if (inDisplayArea)
			if (CounterY < 60)	//Top of screen shown in black because no cars
				pixel <= 3'b000;
			else if (CounterY < 120)
				if ((drawHorizPosition & vert1) !== 0)
					pixel <= 3'b100;
				else
					pixel <= 3'b000;
			else if (CounterY < 180)
				if ((drawHorizPosition & vert2) !== 0)
					pixel <= 3'b100;
				else
					pixel <= 3'b000;
			else if (CounterY < 240)
				if ((drawHorizPosition & vert3) !== 0)
					pixel <= 3'b100;
				else
					pixel <= 3'b000;
			else if (CounterY < 300)
				pixel <= 3'b000;
			else if (CounterY < 360)
				if ((drawHorizPosition & vert5) !== 0)
					pixel <= 3'b100;
				else
					pixel <= 3'b000;
			else if (CounterY < 420)
				if ((drawHorizPosition & vert6) !== 0)
					pixel <= 3'b100;
				else
					pixel <= 3'b000;
			else if (CounterY < 480)
				pixel <= 3'b000;
			else
				pixel <= 3'b111;
		else // if it's not to display, go dark
			pixel <= 3'b000;
    end

endmodule

