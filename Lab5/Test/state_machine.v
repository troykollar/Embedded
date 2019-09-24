module counter(input clk, input Switch4, input reset, input sw1, input sw2, output reg [2:0] anodes, output reg [7:0] cathodes, output reg [7:0] outleds);

reg button1_reg;
reg button1_sync;
reg [31:0]	button1_count;
reg   [11:0]   answer;   
parameter DEBOUNCE_DELAY1 = 32'd0_500_000;   /// 10nS * 1M = 10mS
reg [11:0] state = 8'b00000000;

always @(posedge clk)   button1_reg   <= Switch4;
always @(posedge clk)   button1_sync  <= !button1_reg;

assign                  button_done  = (button1_count == DEBOUNCE_DELAY1); 
assign                  button_click = (button1_count == DEBOUNCE_DELAY1 - 1); 

always@(posedge clk)
		if(!button1_sync)  button1_count <= 0;
		else if (button_done) button1_count <= button1_count;
		else 					button1_count <= button1_count + 1;
			
always @(posedge clk)
		if(button_click) answer <= answer + 1;
		else if(!reset) answer <= 0;
		else			answer <= answer;
 
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
	      3'b011:  cathod_S = state[11:8]; 
	      3'b101:  cathod_S = state[7:4]; 
	      3'b110:  cathod_S = state[3:0]; 
	      default:  cathod_S = 4'h0; 
      endcase
	
	
always @(answer or cathod_S)
	case(state)
		0:	state <= 1;
		1:	state <= 2;
		2:	state <= 3;
		3: state <= 4;
		4:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= state;
			else if (sw1 && !sw2)	state <= 5;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		5:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= 6;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		6:
			if (!reset)		state <= 0;
			else if (!sw1 && sw2)	state <= 4;
			else if (sw1 && !sw2)	state <= 8;
			else if (sw1 && sw2)	state <= 1;
			else			state <= 0;
		7:	state <= 0;
		8:	state <= 0;
		15:
			if (!reset)		state <= 0;
			else			state <= state;
	endcase
	
always @(answer)
	outleds <= state[7:0];

//wire dp = 1; //!(anodes == 4'b1011); 

always @(answer)
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
			 //4'h9:  cathodes = {8'b10011000};
			 //4'ha:  cathodes = {8'b10001000};
			 //4'hb:  cathodes = {8'b10000011};
			 //4'hc:  cathodes = {8'b11000110};
			 //4'hd:  cathodes = {8'b10100001};
			 //4'he:  cathodes = {8'b10000110};
			 //4'hf:  cathodes = {8'b10001110};
     endcase
       
endmodule 
