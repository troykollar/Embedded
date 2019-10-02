module reflex(input clk, input Switch4, input Switch5, input reset, output reg [2:0] anodes, output reg [7:0] cathodes, output reg [7:0] outleds);

//******************Debounce Button Logic***********************************************
reg button1_reg;
reg button2_reg;
reg button1_sync;
reg button2_sync;
reg [31:0]	button1_count;
reg [31:0]  button2_count;  

//parameter DEBOUNCE_DELAY1 = 32'd0_000_050;	//Use for simulation
//parameter DEBOUNCE_DELAY2 = 32'd0_000_050;	//Use for simulation
parameter DEBOUNCE_DELAY1 = 32'd0_500_000;   /// 10nS * 1M = 10mS -- Use for synthesis
parameter DEBOUNCE_DELAY2 = 32'd0_500_500;   /// 10nS * 1M = 10mS -- Use for synthesis

//Switch4 = ready_switch
//Switch5 = fire_switch

always @(posedge clk)   button1_reg   <= Switch4;
always @(posedge clk)   button1_sync  <= !button1_reg;

always @(posedge clk)   button2_reg   <= Switch5;
always @(posedge clk)   button2_sync  <= !button2_reg;

assign                  button_done  = (button1_count == DEBOUNCE_DELAY1);	
assign                  ready_click = (button1_count == DEBOUNCE_DELAY1 - 1);

assign                  button_done2  = (button2_count == DEBOUNCE_DELAY2); 
assign                  fire_click = (button2_count == DEBOUNCE_DELAY2 - 1); 

always@(posedge clk)
		if(!button1_sync)  button1_count <= 0;
		else if (button_done) button1_count <= button1_count;
		else 					button1_count <= button1_count + 1;
		
always@(posedge clk)
	if(!button2_sync)  		button2_count <= 0;
	else if (button_done2) 	button2_count <= button2_count;
	else 					button2_count <= button2_count + 1;
//***********************End of Debounce Logic*****************************************************

//********************************Ready click and delay********************************************
reg [31:0] 	delay_status;
reg [63:0]	reflex_time;
reg [31:0]	time_delay = 0;
reg [31:0]	time_delay_multiplier = 16'd1000000000;	//Change for synthesis
reg led = 0;
reg [2:0]	state = 0;
reg [11:0]	time_display = 0;

//Decides what the delay will be
reg [2:0] rand_delay_num = 0;
always @(posedge clk)
	begin
   		case(rand_delay_num)
			3'd0: rand_delay_num <= 1;
			3'd1: rand_delay_num <= 2;
			3'd2: rand_delay_num <= 3;
			3'd3: rand_delay_num <= 4;
			3'd4: rand_delay_num <= 1;
		endcase
end

always @(posedge clk)
	case(state)
		0:			//Before ready_click
			begin
				delay_status <= 0;
				reflex_time <= 0;
				if (ready_click)	state <= 1;
				else if (!reset)	state <= 0;
				else					state <= state;
			end
		1:			//Delay is selected
			begin
				time_delay <= rand_delay_num * time_delay_multiplier;
				if (time_delay == 0)		state <= state;
				else if (!reset)			state <= 0;
				else							state <= 2;
			end
		2:			//Waiting for time to reach delay
			begin
				delay_status <= delay_status + 1;
				if (delay_status == time_delay)	state <= 3;
				else if (!reset)						state <= 0;
				else										state <= state;
			end
		3:			//Delay has been reached, fire light and begin counting for reflex time
			begin
				led <= 1;
				delay_status <= 0;
				reflex_time <= reflex_time + 1;
				time_display <= reflex_time / 100000;	//reflex_time increments every 10 ns, divide by 10^5 for ms
				if (fire_click)		state <= 4;
				else if (!reset)		state <= 0;
				else						state <= state;
			end	
		4:			//Fire button has been clicked. Stop reflex timer and behave similar to state 0
			begin
				led <= 0;
				time_display <= time_display;
				reflex_time <= 0;
				if (ready_click)		state <= 1;
				else						state <= state;
			end
	endcase			
//**********************End of state machine logic*******************************


//**********************Turn on outleds when led == 1****************************
always @(posedge clk)
	if (led == 1)	outleds <= 8'b1111_1111;
	else				outleds <= 8'b0000_0000;

//**********************Seven seg logic****************************************** 
reg [39:0]	counter;
always @(posedge clk)             
	if(!reset)	counter <= 0;
	else			counter <= counter + 1;
                                  
wire anode_clk = (counter[15:0] == 16'h8000);

always @(posedge clk)
        if(!reset)		     anodes <= 3'b110;	
	     else if(anode_clk)   anodes <= {anodes[0],anodes[2:1]}; // rotate
	     else                 anodes <=  anodes;  

reg [3:0] cathod_S;

always @(cathod_S)
       case({anodes})
	      3'b011:  cathod_S = time_display[11:8]; 
	      3'b101:  cathod_S = time_display[7:4]; 
	      3'b110:  cathod_S = time_display[3:0]; 
	      default:  cathod_S = 4'h0; 
      endcase

//wire dp = 1; //!(anodes == 4'b1011); 

always @(cathod_S)
		case(cathod_S)
	       4'h0:  cathodes = {8'b11000000};
			 4'h1:  cathodes = {8'b11111001};
			 4'h2:  cathodes = {8'b10100100};
			 4'h3:  cathodes = {8'b10110000};
			 4'h4:  cathodes = {8'b10011001};
			 4'h5:  cathodes = {8'b10010010};
			 4'h6:  cathodes = {8'b10000010};
			 4'h7:  cathodes = {8'b11111000};
			 4'h8:  cathodes = {8'b10000000};
			 4'h9:  cathodes = {8'b10011000};
			 4'ha:  cathodes = {8'b10001000};
			 4'hb:  cathodes = {8'b10000011};
			 4'hc:  cathodes = {8'b11000110};
			 4'hd:  cathodes = {8'b10100001};
			 4'he:  cathodes = {8'b10000110};
			 4'hf:  cathodes = {8'b10001110};
     endcase
endmodule 
