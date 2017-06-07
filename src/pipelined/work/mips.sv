// pipelined MIPS processor
module mips(input logic  clk, reset,
	    output logic [31:0] pcF,
       	    input logic  [31:0] instrF,
	    output logic memwriteM,
	    output logic [31:0] aluoutM, writedataM,
	    input logic  [31:0] readdataM,
	    input logic sbM);
			
	logic [5:0] opD, functD;
	logic regdstE;
	logic alusrcE,pcsrcD,memtoregE, memtoregM, memtoregW,regwriteE, regwriteM, regwriteW;
	logic [3:0] alucontrolE;
	logic flushE, equalD;
	logic [1:0] hiloE;
	
	controller c(clk, reset, opD, functD, flushE,
		     equalD,memtoregE, memtoregM,
		     memtoregW, memwriteM, pcsrcD,
		     branchD,alusrcE, regdstE, regwriteE,
		     regwriteM, regwriteW, jumpD,
		     alucontrolE, branchneD,hiloE,multdivE,lbW,sbM,jrD,jalD);
				 
	datapath dp(clk, reset, memtoregE, memtoregM,
		    memtoregW, pcsrcD, branchD,
         	    alusrcE, regdstE, regwriteE,
		    regwriteM, regwriteW, jumpD,
		    alucontrolE,equalD, pcF, instrF,
		    aluoutM, writedataM, readdataM,
		    opD, functD, flushE, branchneD,hiloE,multdivE,lbW,jrD,jalD);
				
endmodule
