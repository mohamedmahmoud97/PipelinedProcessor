module controller(input  logic clk, reset,
		  input  logic [5:0] opD, functD,
		  input  logic flushE, equalD,
		  output logic memtoregE,memtoregM,
		  output logic memtoregW,memwriteM,
		  output logic pcsrcD,branchD, alusrcE,
		  output logic regdstE,
		  output logic regwriteE,regwriteM,regwriteW,
		  output logic jumpD,
		  output logic [3:0] alucontrolE,
		  output logic branchneD,
		  output logic [1:0] hiloE,
		  output logic multdivE,lbW,sbM,jrD,jalD);
				  
	logic [1:0] aluopD,hiloD;
	logic memtoregD, memwriteD, alusrcD, regwriteD, regdstD,multdivD,lbD,lbE,lbM,sbD,sbE;
	logic [3:0] alucontrolD;
	logic memwriteE;
	
	maindec md(opD, memtoregD, memwriteD, branchD,
	           alusrcD, regdstD, regwriteD, jumpD,
		   aluopD,branchneD, functD,hiloD,multdivD,lbD,sbD,jrD,jalD);
			   
	aludec ad(functD, aluopD, alucontrolD);
	
	assign pcsrcD = (branchD & equalD) | (branchneD & ~equalD);//this is updated to inform the hazard unit when bne occur to do the same as branch
	
	// registers needed
	flopclr #(14) regE(clk, reset, flushE,
		{memtoregD, memwriteD, alusrcD,regdstD, regwriteD, alucontrolD,hiloD,multdivD,lbD,sbD},
		{memtoregE, memwriteE, alusrcE,regdstE, regwriteE, alucontrolE,hiloE,multdivE,lbE,sbE});
					
	flopr #(5) regM(clk, reset,
			{memtoregE, memwriteE, regwriteE,lbE,sbE},
			{memtoregM, memwriteM, regwriteM,lbM,sbM});
					
	flopr #(3) regW(clk, reset,
			{memtoregM, regwriteM,lbM},
			{memtoregW, regwriteW,lbW});
endmodule


