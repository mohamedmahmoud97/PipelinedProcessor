module operations64(input logic  [31:0] a,b,
		    input logic f,
		    output logic [31:0] high,low);
	always_comb
		begin
			case(f)
				1'b1: {high,low} = a*b;
				1'b0: begin
				      	 	low  = a/b;
						high = a%b;
				      end
				default: {high,low} = 64'bx;
			endcase
		end

endmodule
