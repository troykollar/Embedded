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

endmodule

module VGADemo(
    input clk,
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

    always @(posedge clk_25)
    begin
      if (inDisplayArea)
			if (CounterY < 60)	//Top of screen shown in white because it's safe
				pixel <= 3'b111;
			else
				pixel <= CounterX[9:6];
		else // if it's not to display, go dark
			pixel <= 3'b000;
    end

endmodule

