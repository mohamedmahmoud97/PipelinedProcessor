module maindec(input logic [5:0] op, f,
	       output logic memtoreg, memwrite,
	       output logic branch,branchne, 
	       output logic [1:0] regdst,
	       output logic regwrite,
	       output logic jump,
	       output logic [1:0] aluop, 
	       output logic alusrc, byteM, jumpr,
	       output logic [1:0] srcaselectorD, wd3selectorD);
				
	logic [16:0] controls;
	//  1	    2,3	    4       5       6         7         8       9   10,11    12    13        14,15	   16,17
assign {regwrite, regdst, alusrc, branch,branchne, memwrite, memtoreg, jump, aluop, byteM, jumpr, srcaselectorD, wd3selectorD} 
		= controls;

	always_comb
	begin
		case(op)                         
			6'b000000: 
				begin
					case(f)				  //123456789abcdef++
						6'b010000: controls  <= 17'b10100000010001000; //MFHI/////////////
						6'b010010: controls  <= 17'b10100000010000100; //MFLO/////////////
						6'b001000: controls  <= 17'b00000000000010000; //JR///////////////
						  default: controls  <= 17'b10100000010000000; //Rtype
					endcase
				end 		 //123456789abcdef++
			6'b100011: controls <= 17'b10010001000000000; //LW
			6'b100000: controls <= 17'b10010001000000001; //LB////////////YET TO BE DONE CORRECTLY
			6'b101011: controls <= 17'b00010010000000000; //SW
			6'b101000: controls <= 17'b00010010000100000; //SB///////////////
			6'b000100: controls <= 17'b00001000001000000; //BEQ
			6'b000101: controls <= 17'b00000100001000000; //BNE
			6'b001000: controls <= 17'b10010000000000000; //ADDI
			6'b000010: controls <= 17'b00000000100000000; //J
			6'b000011: controls <= 17'b01000000000010010; //JAL//////////////
			6'b001010: controls <= 17'b10010000011000000; //STLI/////////////
			  default: controls <= 17'bxxxxxxxxxxxxxxxxx; //???
		endcase
	end
endmodule