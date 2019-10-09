module reflex(input clk, input ready_click, input fire_click, input reset, output reg [2:0] anodes, output reg [7:0] cathodes, output reg [7:0] outleds);

//********************************Ready click and delay********************************************
reg [28:0] 	delay_status;
reg [63:0]	reflex_time;
reg [28:0]	time_delay = 0;
reg [26:0]	time_delay_multiplier = 29'd100000000;	//Change for synthesis
reg [2:0]	state = 0;
reg [11:0]	time_display = 0;

//Decides what the delay will be
reg [2:0] rand_delay_num = 0;
always @(posedge clk)
	case(rand_delay_num)
		3'd0: rand_delay_num <= 1;
		3'd1: rand_delay_num <= 2;
		3'd2: rand_delay_num <= 3;
		3'd3: rand_delay_num <= 4;
		3'd4: rand_delay_num <= 1;
	endcase

always @(posedge clk)
	case(state)
		0:			//Before ready_click
			begin
				outleds <= 8'b0000_0000;
				delay_status <= 0;
				if (ready_click && fire_click)	state <= state;
				else if (!ready_click && fire_click)	state <= 1;
				else if (!reset)	state <= 0;
				else if (!fire_click)	state <= 5;
				else			state <= state;
			end
		1:			//Delay is selected
			begin
				outleds <= 8'b0001_1000;
				delay_status <= 0;
				time_delay <= rand_delay_num * time_delay_multiplier;
				if (!reset)			state <= 0;
				else if (!fire_click)			state <= 5;
				else					state <= 2;
			end
		2:			//Waiting for time to reach delay
			begin
				case (time_delay)
					100000000:	outleds <= 8'b0000_0001;
					200000000:	outleds <= 8'b0000_0011;
					300000000:	outleds <= 8'b0000_0111;
					400000000:	outleds <= 8'b0000_1111;
				endcase
				delay_status <= delay_status + 1;
				if (delay_status == time_delay)		state <= 3;
				else if (!reset)			state <= 0;
				else if (!fire_click)			state <= 5;
				else if (!ready_click)			state <= 1;
				else					state <= state;
			end
		3:			//Delay has been reached, fire light and begin counting for reflex time
			begin
				outleds <= 8'b1111_1111;
				delay_status <= 0;
				if (!fire_click)	state <= 4;
				else if(!ready_click)	state <= 1;	
				else if (!reset)	state <= 0;
				else			state <= state;
			end	
		4:			//Fire button has been clicked. Stop reflex timer and behave similar to state 0
			begin
				outleds <= 8'b0000_0000;
				delay_status <= 0;
				if (!ready_click)		state <= 1;
				else if(!reset)		state <= 0;
				else				state <= state;
			end
		5:
			begin
				outleds <= 8'b1010_0101;
				if (!reset)			state <= 0;
				else					state <= state;
			end
	endcase			
//**********************End of state machine logic*******************************

//*********************Count the number of ms passed************************
reg [16:0] nsTimer = 0;
reg [3:0] msCounted = 0;
reg [3:0] tenMsCounted = 0;
reg [3:0] hundredMsCounted = 0;
	
always @(posedge clk)
	case(state)
	0:
		begin
			nsTimer <= 0;
			msCounted <= 0;
			tenMsCounted <= 0;
			hundredMsCounted <= 0;
		end
	3:
		begin
			if (nsTimer == 100000)
				begin
					nsTimer <= 0;
					msCounted <= msCounted + 1;
				end
			else			
				begin
					nsTimer <= nsTimer + 1;
					msCounted <= msCounted;
				end
			
			if (msCounted == 10)
				begin
					msCounted <= 0;
					tenMsCounted <= tenMsCounted + 1;
				end
			else	tenMsCounted <= tenMsCounted;
			
			if (tenMsCounted == 10)
				begin
					tenMsCounted <= 0;
					hundredMsCounted <= hundredMsCounted + 1;
				end
			else	hundredMsCounted <= hundredMsCounted;
			
			if (hundredMsCounted == 10)	hundredMsCounted <= 0;
			else									hundredMsCounted <= hundredMsCounted + 1;
		end
	endcase
	


//**********************Seven seg logic****************************************** 
reg [39:0]	counter;
always @(posedge clk)             
	if(!reset)	counter <= 0;
	else		counter <= counter + 1;
                                  
wire anode_clk = (counter[15:0] == 16'h8000);

always @(posedge clk)
        if(!reset)		     anodes <= 3'b110;	
	     else if(anode_clk)   anodes <= {anodes[0],anodes[2:1]}; // rotate
	     else                 anodes <=  anodes;  

reg [3:0] cathod_S;

always @(cathod_S)
	if (state !== 5)
       case({anodes})
			3'b011:  cathod_S = hundredMsCounted[3:0]; 
	      3'b101:  cathod_S = tenMsCounted[3:0]; 
	      3'b110:  cathod_S = msCounted[3:0];
	      default:  cathod_S = 4'h0; 
      endcase
	else
		case({anodes})
			3'b011:  cathod_S = 4'hd; 
	      3'b101:  cathod_S = 4'he; 
	      3'b110:  cathod_S = 4'hd; 
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
