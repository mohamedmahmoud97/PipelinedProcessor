//setting the module for the ALU
module alu (input  logic [31:0] a,b,
	    input  logic [2:0]    f,
            output logic [31:0]   y);

	logic[31:0] s;
//block of statements 
	always_comb
		begin
			case(f)
				3'b000  : y = a & b;                       // a AND b
			        3'b100  : y = a & (~b+1);                  // a AND ~b
				3'b001  : y = a | b;                       // a OR b
				3'b101  : y = a | (~b+1);                  // a OR ~b
			        3'b010  : y = a + b;                       // a ADD b
			        3'b110  : y = a + (~b+1);                  // a SUB b
				3'b111  : begin s = a+~b+1;
                    				 if(s[31]) y=32'h0000_0001; else y=32'h0000_0000; 
                  			  end                              //STL 
       				default : y=0;
       			endcase	
		end
endmodule 