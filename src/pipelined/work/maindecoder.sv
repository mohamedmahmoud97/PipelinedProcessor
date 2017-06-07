module maindec(input logic [5:0] op,
	       output logic memtoreg, memwrite,
	       output logic branch, alusrc,
	       output logic regdst, 
	       output logic regwrite,jump,
	       output logic [1:0] aluop,
	       output logic branchne,
	       input  logic [5:0] funct,
	       output logic [1:0] hilo,
	       output logic multdiv, lb,sb,jr,jal);
				
	logic [16:0] controls;
   //     1         2        3       4       5        6        7      89    10     1112   13    14 15 16  17
assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop,branchne,hilo,multdiv,lb,sb,jr,jal} = controls;
	always_comb
		case(op)                          
			6'b000000: begin//Rtype  
					case(funct)                      //123456789abcdef++
						6'b011000: controls <= 17'b01000001000010000; // mult
						6'b011010: controls <= 17'b01000001000010000; // div
						6'b010000: controls <= 17'b11000001001000000; // mfhi
						6'b010010: controls <= 17'b11000001000100000; // mflo
						6'b001000: controls <= 17'b00000000000000010; // jr
 						  default: controls <= 17'b11000001000000000; // other Rtype
					endcase
				   end
                                                 //123456789abcdef++
			6'b100011: controls <= 17'b10100100000000000; //LW
			6'b100000: controls <= 17'b10100100000001000; //LB
			6'b101011: controls <= 17'b00101000000000000; //SW
			6'b101000: controls <= 17'b00101000000000100; //SB
			6'b000100: controls <= 17'b00010000100000000; //BEQ
			6'b000101: controls <= 17'b00000000110000000; //BNE
			6'b001000: controls <= 17'b10100000000000000; //ADDI
			6'b000010: controls <= 17'b00000010000000000; //J
			6'b000011: controls <= 17'b10000010000000001; //JAL
			6'b001010: controls <= 17'b10100001100000000; //slti
			default:   controls <= 17'bxxxxxxxxxxxxxxxxx; //???
		endcase
endmodule
