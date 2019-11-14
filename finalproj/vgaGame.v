//Frogger Logic~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module frogger (input clk, input reset, input up, input down, input left, input right, 
					output reg [7:0] vert1 = 8'b1000_1000, output reg [7:0] vert2 = 8'b1000_1000,
					output reg [7:0] vert3 = 8'b1100_1100,output reg [7:0] vert5 = 8'b1000_0000,
					output reg [7:0] vert6 = 8'b1111_0000, output reg [7:0] froggerHorizState = 8'b0001_0000,
					output reg [2:0] froggerVerticalState = 7);	//This module contains frogger logic

	//each vert register is a row that keeps track of cars

	reg [2:0] timeState = 0;	//Keep track of time which determines car locations
	reg [27:0] timeCounter = 0;	//Count the number of clock pulses to keep track of time

	reg win = 0;	//Turns to 1 when reaching the top of the level


	parameter counterReset = 100000000;	//2 for simulation, 100,000,000 for synthesis
	wire oneSecond = (timeCounter == counterReset);
	//Increase timeState, depending on simulation vs. synthesis
	always @(posedge clk)
		if (timeCounter == counterReset)	timeCounter <= 0;
		else										timeCounter <= timeCounter + 1;

	//Move vert1 cars every second
	always @(posedge oneSecond)
		if (reset)	vert1 <= 8'b1000_1000;
		else			vert1 <= {vert1[0], vert1[7:1]};

	//Move vert2 cars every second
	always @(posedge oneSecond)
		if (reset)	vert2 <= 8'b1000_1000;
		else			vert2 <= {vert2[6:0], vert2[7]};

	//shift vert3 every second
	always @(posedge oneSecond)
		if (reset)	vert3 <= 8'b1100_1100;
		else 			vert3 <= {vert3[0], vert3[7:1]};

	//shift vert5 every second
	always @(posedge oneSecond)
		if (reset) 	vert5 <= 8'b1000_0000;
		else			vert5 <= {vert5[6:0], vert5[7]};

	//shift vert6 every second
	always @(posedge oneSecond)
		if (reset)	vert6 <= 8'b1111_0000;
		else 			vert6 <= {vert6[0], vert6[7:1]};

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
		 if (CounterXmaxed)	CounterX <= 0;
		 else	CounterX <= CounterX + 1;

    always @(posedge clk)
      if (CounterXmaxed)
        if(CounterYmaxed)	CounterY <= 0;
        else					CounterY <= CounterY + 1;

    always @(posedge clk)
      vga_HS <= (CounterX > (640 + 16) && (CounterX < (640 + 16 + 96)));   // active for 96 clocks
	
	always @(posedge clk)
      vga_VS <= (CounterY > (480 + 10) && (CounterY < (480 + 10 + 2)));   // active for 2 clocks

    always @(posedge clk)
        inDisplayArea <= (CounterX < 640) && (CounterY < 480);

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

	 wire clk_25 = clk_counter == 2'd3;		//clk_25 goes high every 4th clk pulse, creates a 25MHz clock
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
	 wire [7:0] HfrogPos;
	 wire [2:0] VfrogPos;
	 
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
		.vert6(vert6),
		.froggerHorizState(HfrogPos),
		.froggerVerticalState(VfrogPos)
	);
	
	reg [7:0] drawHorizPosition;		//Determine the position of the current pixel in the "grid"
	always @(posedge clk)
		if (CounterX < 80)			drawHorizPosition <= 8'b1000_0000;
		else if (CounterX < 160)	drawHorizPosition <= 8'b0100_0000;
		else if (CounterX < 240)	drawHorizPosition <= 8'b0010_0000;
		else if (CounterX < 320)	drawHorizPosition <= 8'b0001_0000;
		else if (CounterX < 400)	drawHorizPosition <= 8'b0000_1000;
		else if (CounterX < 480)	drawHorizPosition <= 8'b0000_0100;
		else if (CounterX < 560)	drawHorizPosition <= 8'b0000_0010;
		else if (CounterX < 640)	drawHorizPosition <= 8'b0000_0001;
		else								drawHorizPosition <= 8'b0000_0000;
	
   always @(posedge clk_25)
		if (inDisplayArea)
			if (CounterY < 60)		//If drawing level 0
				if (VfrogPos == 0)			//If frog is at level 0
					if ((drawHorizPosition & HfrogPos) !== 0)	pixel <= 3'b010;	//Check if frog is on currently drawn block
					else	pixel <= 3'b000;													//Draw black if not
				else	pixel <= 3'b000;		//Draw black if frog is not at level 0
			else if (CounterY < 120)	//If drawing level 1
				if (VfrogPos == 1)			//If frog is at level 1
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010; //Check if frog is currently drawn block
					else if ((drawHorizPosition & vert1) !== 0)	pixel <= 3'b100;	//Check if car is currently drawn block
					else	pixel <= 3'b000;	//Draw black if not
				else if ((drawHorizPosition & vert1) !== 0)	pixel <= 3'b100;
				else		pixel <= 3'b000;
			else if (CounterY < 180)
				if (VfrogPos == 2)
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010;
					else if ((drawHorizPosition & vert2) !== 0)	pixel <= 3'b001;
					else	pixel <= 3'b000;
				else if ((drawHorizPosition & vert2) !== 0)	pixel <= 3'b001;
				else		pixel <= 3'b000;
			else if (CounterY < 240)
				if (VfrogPos == 3)
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010;
					else if ((drawHorizPosition & vert3) !== 0)	pixel <= 3'b101;
					else	pixel <= 3'b000;
				else  if ((drawHorizPosition & vert3) !== 0)	pixel <= 3'b101;
				else		pixel <= 3'b000;
			else if (CounterY < 300)
				if (VfrogPos == 4)
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010;
					else	pixel <= 3'b000;
				else		pixel <= 3'b000;
			else if (CounterY < 360)
				if (VfrogPos == 5)
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010;
					else if ((drawHorizPosition & vert5) !== 0)	pixel <= 3'b101;
					else	pixel <= 3'b000;
				else if ((drawHorizPosition & vert5) !== 0)	pixel <= 3'b101;
				else		pixel <= 3'b000;
			else if (CounterY < 420)
				if (VfrogPos == 6)
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010;
					else if ((drawHorizPosition & vert6) !== 0)	pixel <= 3'b101;
					else	pixel <= 3'b000;
				else if ((drawHorizPosition & vert6) !== 0)	pixel <= 3'b101;
				else		pixel <= 3'b000;
			else if (CounterY < 480)
				if (VfrogPos == 7)
					if ((drawHorizPosition & HfrogPos) !== 0) 	pixel <= 3'b010;
					else	pixel <= 3'b000;
				else		pixel <= 3'b000;
			else	pixel <= 3'b000;	//Draw black if not between 0 < CounterY < 480 should be redundant with next line
		else		pixel <= 3'b000;	//Draw black if not inDisplayArea

endmodule

