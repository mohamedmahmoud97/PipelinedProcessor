module controller(input  logic clk, reset,
		  input  logic [5:0] opD, functD,
		  input  logic flushE, equalD,
		  output logic memtoregE,memtoregM,
		  output logic memtoregW,memwriteM,
		  output logic pcsrcD,branchD, branchneD, 
		  output logic [1:0]regdstE,
		  output logic regwriteE,
		  output logic regwriteM,regwriteW,
		  output logic jumpD,byteM,
		  output logic alusrcE,
		  output logic [3:0] alucontrolE,
		  output logic operation64E,jumprW,
		  output logic [1:0] srcaselectorE, wd3selectorW);
				  
		logic [1:0] aluopD, regdstD;
		logic memtoregD, memwriteD, regwriteD,byteD,byteE;
		logic alusrcD;
		logic [3:0] alucontrolD;
		logic operation64D,jumprD,jumprE,jumprM;
		logic memwriteE;
		logic [1:0] srcaselectorD, wd3selectorD, wd3selectorE, wd3selectorM;
		
		maindec md(opD, functD, memtoregD, memwriteD, branchD,branchneD,
			   regdstD, regwriteD, jumpD,
			   aluopD, alusrcD, byteD, jumprD, srcaselectorD, wd3selectorD);
				   
		aludec ad(functD, aluopD, alucontrolD,operation64D);
		
		assign pcsrcD = (branchD & equalD) | (branchneD & ~(equalD));

		// registers needed
		flopclr #(17) regE(clk, reset, flushE,
		{memtoregD, memwriteD, alusrcD,regdstD, regwriteD, alucontrolD, operation64D, byteD, jumprD, srcaselectorD, wd3selectorD},
		{memtoregE, memwriteE, alusrcE,regdstE, regwriteE, alucontrolE, operation64E, byteE, jumprE, srcaselectorE, wd3selectorE});
						
		flopr #(7) regM(clk, reset,
				{memtoregE, memwriteE, regwriteE, byteE, jumprE, wd3selectorE},
				{memtoregM, memwriteM, regwriteM, byteM, jumprM, wd3selectorM});
						
		flopr #(5) regW(clk, reset,
				{memtoregM, regwriteM, jumprM, wd3selectorM},
				{memtoregW, regwriteW, jumprW, wd3selectorW});
endmodule
