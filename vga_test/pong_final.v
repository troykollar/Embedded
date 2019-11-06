`timescale 1ns / 1psmodule hvsync_generator(input clk, output vga_h_sync, output vga_v_sync, output inDisplayArea, output CounterX, output CounterY, output CounterXmaxed);

	reg [9:0] CounterX;
	reg [8:0] CounterY;
	wire CounterXmaxed = (CounterX == 767);

	always @(posedge clk)			//CounterXmax at 767, reset to zero when it reaches that
		if(CounterXmaxed)      CounterX <= 0;
		else                   CounterX <= CounterX + 1;
		
	always @(posedge clk)			//When CounterX reaches CounterxMax increment counterY
		if(CounterXmaxed)      CounterY <= CounterY + 1;

	reg	vga_HS, vga_VS;

	always @(posedge clk)			//vgaHsync <= 1 when CounterX[9:4] == 41
		vga_HS <= (CounterX[9:4]==41);
		
	always @(posedge clk)			//vgaVsync <= 1 when CounterY == 495
		vga_VS <= (CounterY==495);

	reg inDisplayArea;

	always @(posedge clk)
		if(inDisplayArea==0)   inDisplayArea <= (CounterXmaxed) && (CounterY<480);
		else	                 inDisplayArea <= !(CounterX==575);
		
	assign vga_h_sync = ~vga_HS;
	assign vga_v_sync = ~vga_VS;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Pong Module
module pong(input clk, output vga_h_sync, output vga_v_sync, output vga_R, output vga_G, output vga_B, input quadA, input quadB, input quadA2, input quadB2);

	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [8:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), 
	  .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	//Paddle Position Player 1//
	reg [8:0] PaddlePosition;
	reg [2:0] quadAr, quadBr;

	always @(posedge clk) quadAr <= {quadAr[1:0], quadA};

	always @(posedge clk) quadBr <= {quadBr[1:0], quadB};

	always @(posedge clk)
	if(quadAr[2] ^ quadAr[1] ^ quadBr[2] ^ quadBr[1])
		begin
			if(quadAr[2] ^ quadBr[1])
			begin
				if(~&PaddlePosition)        // make sure the value doesn't overflow
					PaddlePosition <= PaddlePosition + 10;
			end
			else
			begin
				if(|PaddlePosition)        // make sure the value doesn't underflow
					PaddlePosition <= PaddlePosition - 10;
			end
		end
	/////////////////////////////////////////////////////////////////////////////////////////////////////	//Paddle Position Player 2//
	reg [8:0] PaddlePosition2;
	reg [2:0] quadAr2, quadBr2;

	always @(posedge clk) quadAr2 <= {quadAr2[1:0], quadA2};

	always @(posedge clk) quadBr2 <= {quadBr2[1:0], quadB2};

	always @(posedge clk)
	if(quadAr2[2] ^ quadAr2[1] ^ quadBr2[2] ^ quadBr2[1])
	begin
		if(quadAr2[2] ^ quadBr2[1])
		begin
			if(~&PaddlePosition2)        // make sure the value doesn't overflow
				PaddlePosition2 <= PaddlePosition2 + 10;
		end
		else
		begin
			if(|PaddlePosition2)        // make sure the value doesn't underflow
				PaddlePosition2 <= PaddlePosition2 - 10;
		end
	end
	/////////////////////////////////////////////////////////////////////////////////////////////////////	//Ball//
	reg [9:0] ballX;
	reg [8:0] ballY;
	reg ball_inX, ball_inY;

	always @(posedge clk)
		if(ball_inX==0)    ball_inX <= (CounterX==ballX) & ball_inY; 
		else               ball_inX <= !(CounterX==ballX+16);

	always @(posedge clk)
		if(ball_inY==0)    ball_inY <= (CounterY==ballY); 
		else               ball_inY <= !(CounterY==ballY+16);

	wire ball = ball_inX & ball_inY;
	/////////////////////////////////////////////////////////////////
	wire border = (CounterX[9:3]==0) || (CounterX[9:3]==71) || (CounterY[8:3]==0) || (CounterY[8:3]==59);
	wire paddle = (CounterX>=PaddlePosition+8) && (CounterX<=PaddlePosition+120) && (CounterY[8:4]==27);	wire paddle2 = (CounterX>=PaddlePosition2+8) && (CounterX<=PaddlePosition2+120) && (CounterY[8:4]==2);
	wire BouncingObject = border | paddle | paddle2 ; // active if the border or paddle is redrawing itself

	reg ResetCollision;

	always @(posedge clk) 
	ResetCollision <= (CounterY==495) & (CounterX==0);  // active only once for every video frame

	reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;

	always @(posedge clk) 
		if(ResetCollision)                                                    CollisionX1<=0; 
		else if(BouncingObject & (CounterX==ballX   ) & (CounterY==ballY+ 8)) CollisionX1<=1;
		
	always @(posedge clk) 
	   if(ResetCollision)                                                    CollisionX2<=0; 
		else if(BouncingObject & (CounterX==ballX+16) & (CounterY==ballY+ 8)) CollisionX2<=1;
		
	always @(posedge clk) 
		if(ResetCollision)                                                    CollisionY1<=0; 
		else if(BouncingObject & (CounterX==ballX+ 8) & (CounterY==ballY   )) CollisionY1<=1;
		
	always @(posedge clk) 
		if(ResetCollision)                                                    CollisionY2<=0; 
		else if(BouncingObject & (CounterX==ballX+ 8) & (CounterY==ballY+16)) CollisionY2<=1;
	/////////////////////////////////////////////////////////////////
	wire UpdateBallPosition = ResetCollision;  // update the ball position at the same time that we reset the collision detectors

	reg ball_dirX, ball_dirY;

	always @(posedge clk)
	if(UpdateBallPosition)
	begin
		if(~(CollisionX1 & CollisionX2))        // if collision on both X-sides, don't move in the X direction
		begin
			ballX <= ballX + (ball_dirX ? -1 : 1);
			if(CollisionX2) ball_dirX <= 1; else if(CollisionX1) ball_dirX <= 0;
		end

		if(~(CollisionY1 & CollisionY2))        // if collision on both Y-sides, don't move in the Y direction
		begin
			ballY <= ballY + (ball_dirY ? -1 : 1);
			if(CollisionY2) ball_dirY <= 1; else if(CollisionY1) ball_dirY <= 0;
		end
	end 
	/////////////////////////////////////////////////////////////////	//Writing to VGA//
	wire R = BouncingObject | ball | (CounterX[3] ^ CounterY[3]);
	wire G = BouncingObject | ball;
	wire B = BouncingObject | ball;

	reg vga_R, vga_G, vga_B;

	always @(posedge clk)
		vga_R <= R & inDisplayArea;
		
	always @(posedge clk)
		vga_G <= G & inDisplayArea;
		
	always @(posedge clk)
		vga_B <= B & inDisplayArea;

endmodule