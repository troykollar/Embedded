module counter(input clk, input Switch4, input Switch5, input reset, output reg [2:0] anodes, output reg [7:0] cathodes, output reg [7:0] outleds);

reg button1_reg;
reg button2_reg;
reg button1_sync;
reg button2_sync;
reg [31:0]	button1_count;
reg [31:0]  button2_count;
reg   [11:0]   answer;   
parameter DEBOUNCE_DELAY1 = 32'd0_500_000;   /// 10nS * 1M = 10mS
parameter DEBOUNCE_DELAY2 = 32'd0_500_000;   /// 10nS * 1M = 10mS

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

reg [63:0] 	sythesis_delay_multiplier = 64'd1_000_000_000;
reg [63:0]	simulation_delay_multiplier = 64'd100;

reg delay_started = 0;
reg light_fired = 0;
reg [64:0] delay_status = 0;

//Used for debounce button Switch4 logic
always@(posedge clk)
		if(!button1_sync)  button1_count <= 0;
		else if (button_done) button1_count <= button1_count;
		else 					button1_count <= button1_count + 1;

//Used for debounce button Switch5 logic
always@(posedge clk)
	if(!button2_sync)  		button2_count <= 0;
	else if (button_done2) 	button2_count <= button2_count;
	else 					button2_count <= button2_count + 1;
			

 //Decides what the delay will be. For simulation vs. synthesis purposes will be multiplied by different factors
reg [2:0] rand_delay_num = 0;
always @(posedge clk)
   case(rand_delay_num)
		3'd0: rand_delay_num <= 1;
		3'd1: rand_delay_num <= 2;
		3'd2: rand_delay_num <= 3;
		3'd3: rand_delay_num <= 4;
		3'd4: rand_delay_num <= 1;
	endcase
	
//assign	time_delay = rand_delay_num * sythesis_delay_multiplier;	//For synthesis	
assign	time_delay = rand_delay_num * simulation_delay_multiplier;	//For simulation
	
always @(posedge clk)
	if(ready_click) 		delay_started <= 1;
	else if(light_fired) 	delay_started <= 0;
	else if(!reset) 		delay_started <= 0;
	else					delay_started <= delay_started;
		
always @(posedge clk)
	if (delay_started)	delay_status <= delay_status + 1
	else if(delay_status == time_delay)
		begin
			delay_status <= 0;
			light_fired <= 1;
		end
	else				delay_status <= delay_status;
			
	
	
 
reg   [39:0]                      counter;
always @(posedge clk)             
	if(!reset)      			  counter     <= 0;
	else                      counter     <= counter + 1;
                                  
wire                              anode_clk    =  (counter[15:0] == 16'h8000);

always @(posedge clk)
        if(!reset)		        anodes <= 3'b110;	
	     else if(anode_clk)   anodes <= {anodes[0],anodes[2:1]}; // rotate
	     else                 anodes <=  anodes;  

reg [3:0] cathod_S;

always @(cathod_S or answer)
       case({anodes})
	      3'b011:  cathod_S = answer[11:8]; 
	      3'b101:  cathod_S = answer[7:4]; 
	      3'b110:  cathod_S = answer[3:0]; 
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
