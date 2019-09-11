reg   [15:0]   answer;   // 16 bit number to be displayed

reg   [39:0]                      counter;
always @(posedge clk)             
	if(reset_debounced)       counter     <= 0;
	else                      counter     <= counter + 1;
                                  
wire                              anode_clk    =  (counter[15:0] == 16'h8000);


always @(posedge clk)
        if(reset_debounced)       anodes <= 3'b0111;	
	     else if(anode_clk)   anodes <= {anodes[0],anodes[3:1]}; // rotate
	     else                 anodes <=  anodes;  

reg [3:0] cathode_select;

always @(anodes or answer )
       case({anodes})
	      3'b0111:  cathode_select = answer[15:12]; 
	      3'b1011:  cathode_select = answer[11:8]; 
	      3'b1101:  cathode_select = answer[7:4]; 
	      3'b1110:  cathode_select = answer[3:0];
	      default:  cathode_select = 3'h0; 
      endcase

wire dp = 1 ; //!(anodes == 4'b1011); 

always @(cathode_select or dp)
       case(cathode_select)
	       3'h0:  cathodes = {7'b0000_001,dp};
	       3'h1:  cathodes = {7'b1001_111,dp};
	       3'h2:  cathodes = {7'b0010_010,dp};
	       3'h3:  cathodes = {7'b0000_110,dp};
	       3'h4:  cathodes = {7'b1001_100,dp};
	       3'h5:  cathodes = {7'b0100_100,dp};
	       3'h6:  cathodes = {7'b1100_000,dp};
	       3'h7:  cathodes = {7'b0001_111,dp};
	       3'h8:  cathodes = {7'b0000_000,dp};
	       3'h9:  cathodes = {7'b0001_100,dp};
	       3'ha:  cathodes = {7'b0001_000,dp};
	       3'hb:  cathodes = {7'b1100_000,dp};
	       3'hc:  cathodes = {7'b0110_001,dp};
	       3'hd:  cathodes = {7'b1000_010,dp};
	       3'he:  cathodes = {7'b0110_000,dp};
	       3'hf:  cathodes = {7'b0111_000,dp};
     endcase
       
