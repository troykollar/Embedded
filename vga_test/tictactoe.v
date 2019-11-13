`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:19:10 12/07/2014 
// Design Name: 
// Module Name:    tictactoe 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tictactoe (input clk, input reset, input [2:0] sw_r, input [2:0] sw_c, input submit_button, output [7:0] leds, output [9:0] sector, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B, input Mode);

reg 				 submit_button_click;
reg 				 submit_reg;
reg 	 [9:0]	 sector;
reg             which_player;

wire Player1_Turn =which_player;
wire Player2_Turn =~which_player;

wire   [2:0]     row1_blue;  
wire   [2:0]     row1_orange;  
wire   [2:0]     row2_blue;  
wire   [2:0]     row2_orange;  
wire   [2:0]     row3_blue;  
wire   [2:0]     row3_orange;  




//
///////////////////////////////////////////////////////////////////////////////////////////////////////
////Pong Module

output vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B;
wire inDisplayArea;
wire [9:0] CounterX;
wire [8:0] CounterY;

//

//  
// 
//
//
hvsync_generator syncgen(.clk(clk), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), 
 .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
//// determine where dot is.
//
//// dots
//
wire O_1_1 = (CounterX[9:3] < 24)&(CounterX[9:3] > 0) & (CounterY[8:3] < 59)&(CounterY[8:3] > 40);
wire B_1_1 = (CounterX[9:3] < 24)&(CounterX[9:3] > 0) & (CounterY[8:3] < 59)&(CounterY[8:3] > 40);
wire O_1_2 = (CounterX[9:3] < 48)&(CounterX[9:3] > 24) & (CounterY[8:3] < 59)&(CounterY[8:3] > 40);
wire B_1_2 = (CounterX[9:3] < 48)&(CounterX[9:3] > 24) & (CounterY[8:3] < 59)&(CounterY[8:3] > 40);
wire O_1_3 = (CounterX[9:3] < 71)&(CounterX[9:3] > 48) & (CounterY[8:3] < 59)&(CounterY[8:3] > 40);
wire B_1_3 = (CounterX[9:3] < 71)&(CounterX[9:3] > 48) & (CounterY[8:3] < 59)&(CounterY[8:3] > 40);
wire O_2_1 = (CounterX[9:3] < 24)&(CounterX[9:3] > 0) & (CounterY[8:3] < 40)&(CounterY[8:3] > 20);
wire B_2_1 = (CounterX[9:3] < 24)&(CounterX[9:3] > 0) & (CounterY[8:3] < 40)&(CounterY[8:3] > 20);
wire O_2_2 = (CounterX[9:3] < 48)&(CounterX[9:3] > 24) & (CounterY[8:3] < 40)&(CounterY[8:3] > 20);
wire B_2_2 = (CounterX[9:3] < 48)&(CounterX[9:3] > 24) & (CounterY[8:3] < 40)&(CounterY[8:3] > 20);
wire O_2_3 = (CounterX[9:3] < 71)&(CounterX[9:3] > 48) & (CounterY[8:3] < 40)&(CounterY[8:3] > 20);
wire B_2_3 = (CounterX[9:3] < 71)&(CounterX[9:3] > 48) & (CounterY[8:3] < 40)&(CounterY[8:3] > 20);
wire O_3_1 = (CounterX[9:3] < 24)&(CounterX[9:3] > 0) & (CounterY[8:3] < 20)&(CounterY[8:3] > 0);
wire B_3_1 = (CounterX[9:3] < 24)&(CounterX[9:3] > 0) & (CounterY[8:3] < 20)&(CounterY[8:3] > 0);
wire O_3_2 = (CounterX[9:3] < 48)&(CounterX[9:3] > 24) & (CounterY[8:3] < 20)&(CounterY[8:3] > 0);
wire B_3_2 = (CounterX[9:3] < 48)&(CounterX[9:3] > 24) & (CounterY[8:3] < 20)&(CounterY[8:3] > 0);
wire O_3_3 = (CounterX[9:3] < 71)&(CounterX[9:3] > 48) & (CounterY[8:3] < 20)&(CounterY[8:3] > 0);
wire B_3_3 = (CounterX[9:3] < 71)&(CounterX[9:3] > 48) & (CounterY[8:3] < 20)&(CounterY[8:3] > 0);



wire Orange_Win = (O_1_1 && O_1_2 && O_1_3)|
						(O_2_1 && O_2_2 && O_2_3)|
						(O_3_1 && O_3_2 && O_3_3)|
						(O_1_1 && O_2_1 && O_3_1)|
						(O_1_2 && O_2_2 && O_3_2)|
						(O_1_3 && O_2_3 && O_3_3)|
						(O_1_1 && O_2_2 && O_3_3)|
						(O_1_3 && O_2_2 && O_3_1);
						
						
wire Blue_Win =	(B_1_1 && B_1_2 && B_1_3)|
						(B_2_1 && B_2_2 && B_2_3)|
						(B_3_1 && B_3_2 && B_3_3)|
						(B_1_1 && B_2_1 && B_3_1)|
						(B_1_2 && B_2_2 && B_3_2)|
						(B_1_3 && B_2_3 && B_3_3)|
						(B_1_1 && B_2_2 && B_3_3)|
						(B_1_3 && B_2_2 && B_3_1);
						
wire  [7:0]     leds = Mode? {Player1_Turn, Player2_Turn, Orange_Win, Blue_Win, 4'b0000}: {6'b000000, sw_r, sw_c};


wire border = (CounterX[9:3]==0) || (CounterX[9:3]==24) ||(CounterX[9:3]==48) || (CounterX[9:3]==71) || (CounterY[8:3]==0) || (CounterY[8:3]==20) || (CounterY[8:3]==40) || (CounterY[8:3]==59); //move s
//
////Writing to VGA//
wire R = (O_1_1 & row1_orange[0]) |
         (O_1_2 & row1_orange[1]) |
         (O_1_3 & row1_orange[2]) |
         (O_2_1 & row2_orange[0]) |
         (O_2_2 & row2_orange[1]) |
         (O_2_3 & row2_orange[2]) |
         (O_3_1 & row3_orange[0]) |
         (O_3_2 & row3_orange[1]) |
         (O_3_3 & row3_orange[2]);
         
			
wire G = (O_1_1 & row1_orange[0]) |
         (O_1_2 & row1_orange[1]) |
         (O_1_3 & row1_orange[2]) |
         (O_2_1 & row2_orange[0]) |
         (O_2_2 & row2_orange[1]) |
         (O_2_3 & row2_orange[2]) |
         (O_3_1 & row3_orange[0]) |
         (O_3_2 & row3_orange[1]) |
         (O_3_3 & row3_orange[1]) | border;
			
wire B = (B_1_1 & row1_blue[0]) |
         (B_1_2 & row1_blue[1]) |
         (B_1_3 & row1_blue[2]) |
         (B_2_1 & row2_blue[0]) |
         (B_2_2 & row2_blue[1]) |
         (B_2_3 & row2_blue[2]) |
         (B_3_1 & row3_blue[0]) |
         (B_3_2 & row3_blue[1]) |
         (B_3_3 & row3_blue[2]) | border; 
	

reg vga_R, vga_G, vga_B;

always @(posedge clk)
	vga_R <= R & inDisplayArea;
	
always @(posedge clk)
	vga_G <= G & inDisplayArea;
	
always @(posedge clk)
	vga_B <= B & inDisplayArea;


reg   [17:0]    debounce_counter;
always @(posedge clk)
  if (reset)                    debounce_counter <= 0;
  else                          debounce_counter <= debounce_counter+1;
wire  button_check = debounce_counter == -1;
	
always @(posedge debounce_counter[17])	submit_reg		<= submit_button;
always @(posedge debounce_counter[17]) submit_button_click <= !submit_reg & submit_button;
//always @(posedge clk)  submit_reg          <= submit_button;
//always @(posedge clk)  submit_button_click <= !submit_reg & submit_button;

//player 0 is orange - player 1 is blue
always @(posedge clk)
  if (reset)                    which_player = 0;
  else if (submit_button_click) which_player = ~which_player;
  else                          which_player = which_player;
  


always @(posedge clk)
	if(reset)							sector = 0;
	else if(submit_button_click && sw_r[2] && sw_c[2])		sector = 1;
	else if(submit_button_click && sw_r[2] && sw_c[1])		sector = 2;
	else if(submit_button_click && sw_r[2] && sw_c[0])		sector = 3;
	else if(submit_button_click && sw_r[1] && sw_c[2])		sector = 4;
	else if(submit_button_click && sw_r[1] && sw_c[1])		sector = 5;
	else if(submit_button_click && sw_r[1] && sw_c[0])		sector = 6;
	else if(submit_button_click && sw_r[0] && sw_c[2])		sector = 7;
	else if(submit_button_click && sw_r[0] && sw_c[1])		sector = 8;
	else if(submit_button_click && sw_r[0] && sw_c[0])		sector = 9;
	else									sector = sector;
	
	
assign row1_orange[0] = which_player  && submit_button_click && (sector == 1);
assign row1_orange[1] = which_player  && submit_button_click && (sector == 2);
assign row1_orange[2] = which_player  && submit_button_click && (sector == 3);
assign row2_orange[0] = which_player  && submit_button_click && (sector == 4);
assign row2_orange[1] = which_player  && submit_button_click && (sector == 5);
assign row2_orange[2] = which_player  && submit_button_click && (sector == 6);
assign row3_orange[0] = which_player  && submit_button_click && (sector == 7);
assign row3_orange[1] = which_player  && submit_button_click && (sector == 8);
assign row3_orange[2] = which_player  && submit_button_click && (sector == 9);
assign row1_blue[0] = !which_player  && submit_button_click && (sector == 1);
assign row1_blue[1] = !which_player  && submit_button_click && (sector == 2);
assign row1_blue[2] = !which_player  && submit_button_click && (sector == 3);
assign row2_blue[0] = !which_player  && submit_button_click && (sector == 4);
assign row2_blue[1] = !which_player  && submit_button_click && (sector == 5);
assign row2_blue[2] = !which_player  && submit_button_click && (sector == 6);
assign row3_blue[0] = !which_player  && submit_button_click && (sector == 7);
assign row3_blue[1] = !which_player  && submit_button_click && (sector == 8);
assign row3_blue[2] = !which_player  && submit_button_click && (sector == 9);
	
endmodule

module hvsync_generator(clk, vga_h_sync, vga_v_sync, inDisplayArea, CounterX, CounterY,CounterXmaxed);
input clk;
output vga_h_sync, vga_v_sync;
output inDisplayArea;
output [9:0] CounterX;
output [8:0] CounterY;
output CounterXmaxed;

reg [9:0] CounterX;
reg [8:0] CounterY;
wire CounterXmaxed = (CounterX == 767); //767

always @(posedge clk)
	if(CounterXmaxed)      CounterX <= 0;
	else                   CounterX <= CounterX + 1;
	
always @(posedge clk)
	if(CounterXmaxed)      CounterY <= CounterY + 1;

reg	vga_HS, vga_VS;

always @(posedge clk)
	vga_HS <= (CounterX[9:4]==41); //[9:4] 41
	
always @(posedge clk)	
	vga_VS <= (CounterY==495); //495

reg inDisplayArea;

always @(posedge clk)
	if(inDisplayArea==0)   inDisplayArea <= (CounterXmaxed) && (CounterY<480); //480
	else	                 inDisplayArea <= !(CounterX==575); //575
	
assign vga_h_sync = ~vga_HS;
assign vga_v_sync = ~vga_VS;

endmodule

