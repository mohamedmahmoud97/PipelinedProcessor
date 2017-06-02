// pipelined MIPS processor
module mips(input logic  clk, reset,
            output logic [31:0] pcF,
	    input logic  [31:0] instrF,
	    output logic memwriteM,
	    output logic [31:0] aluoutM, writedataM,
	    input logic  [31:0] readdataM);
			
	logic [5:0] opD, functD;
	logic pcsrcD,memtoregE, memtoregM, memtoregW,regwriteE, regwriteM, regwriteW;
	logic [3:0] alucontrolE;
	logic operation64E, alusrcE;
	logic [1:0] regdstE;
	logic flushE, equalD;
	wire [1:0] srcaselectorE, wd3selectorW;
	
	controller c(clk, reset, opD, functD, flushE,
		 equalD,memtoregE, memtoregM,
		 memtoregW, memwriteM, pcsrcD,
		 branchD,branchneD, regdstE, regwriteE,
		 regwriteM, regwriteW, jumpD,byteM,
		 alusrcE, alucontrolE, operation64E,jumprW, srcaselectorE, wd3selectorW);
				 
	datapath dp(clk, reset, memtoregE, memtoregM,
		memtoregW, pcsrcD, branchD,branchneD,
	        regdstE, regwriteE,
		regwriteM, regwriteW, byteM, jumpD, jumprW,
		alucontrolE, alusrcE, operation64E,
		equalD, pcF, instrF,
		aluoutM, writedataM, readdataM,
		opD, functD, flushE, srcaselectorE, wd3selectorW);
				
endmodule
