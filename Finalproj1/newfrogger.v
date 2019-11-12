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

module frogger (input clk, output reg [9:0] vert1 = 0);	//This module contains frogger logic

	//each vert register is a row that keeps track of cars
	reg [4:0] vert2;
	reg [4:0] vert3;
	reg [4:0] vert5;
	reg [4:0] vert6;

	reg [4:0] timeState = 0;	//Keep track of time which determines car locations
	reg [27:0] timeCounter = 0;	//Count the number of clock pulses to keep track of time

	//Increase timeState, depending on simulation vs. synthesis
	always @(posedge clk)
		if (timeCounter == 2) //Change to 100 million for synthesis
			begin
				timeCounter <= 0;
				timeState <= timeState + 1;
			end
		else	timeCounter <= timeCounter + 1;

	//Move vert1 cars based on timeState
	always @(timeState)
		if (vert1 == 640)		vert1 = 0;
		else 							vert1 = vert1 + 1;

endmodule	//End of frogger logic module

module VGAWrite(
    input clk,
	 input wire sw4,
	 input wire sw3,
	 input wire sw1,
	 input wire sw2,
	 input wire sw5,
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
	 
	 wire [9:0] vert1;
	 
	 frogger frogLogic(
		.clk(clk),
		.vert1(vert1)
	);
	
	always @(posedge clk_25)
		if (inDisplayArea)
			pixel <= CounterX[9:6];
		else 	pixel <= 3'b111;
	

endmodule



