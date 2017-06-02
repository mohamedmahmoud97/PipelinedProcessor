module datapath(input logic clk, reset, 
		input logic memtoregE, memtoregM, memtoregW,
		input logic pcsrcD, branchD,branchneD,
		input logic [1:0] regdstE,
		input logic regwriteE, regwriteM, regwriteW,byteM,
		input logic jumpD, jumprW,
		input logic [3:0] alucontrolE,
		input logic alusrcE,
		input logic operation64E,
		output logic equalD,
		output logic [31:0] pcF,
		input logic [31:0] instrF,
		output logic [31:0] aluoutM, writedataoutM,
		input logic [31:0] readdataM,
		output logic [5:0] opD, functD,
		output logic flushE,
		input logic [1:0] srcaselectorE, wd3selectorW);

	logic forwardaD, forwardbD;
	logic [1:0] forwardaE, forwardbE;
	logic stallF;
	logic [4:0] rsD, rtD, rdD, rsE, rtE, rdE, shamtD, shamtE;
	logic [4:0] writeregE, writeregM, writeregW;
	logic flushD;
	logic [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD,pcjnextFD;
	logic [31:0] signimmD, signimmE, signimmshD;
	logic [31:0] srcaD, srca2D, srcaE, srca2E, srca3E;
	logic [31:0] srcbD, srcb2D, srcbE, srcb2E, srcb3E;
	logic [31:0] pcplus4D, instrD;
	logic [31:0] aluoutE, aluoutW;
	logic [31:0] readdataW, resultW, lboutimmW;
	logic [7:0]  lboutW;
	logic [31:0] highE,highM,lowE,lowM, writedatamuxoutD, writedataM;
	logic [7:0] selectedbyte;

	// hazard detection
	hazard h(rsD, rtD, rsE, rtE, writeregE, writeregM,
		 writeregW,regwriteE, regwriteM, regwriteW,
 		 memtoregE, memtoregM, branchD,branchneD,
		 forwardaD, forwardbD, forwardaE,
		 forwardbE, stallF, stallD, flushE);
	
	// next PC logic (operates in fetch and decode)
	mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD,pcnextbrFD);
	mux2 #(32) pcjmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0], 2'b00},jumpD, pcjnextFD);
	mux2 #(32) pcmux(pcjnextFD,resultW,jumprW,pcnextFD);
	
	// register file (operates in decode and writeback)
	regfile rf(clk, regwriteW, rsD, rtD, writeregW, writedatamuxoutD, srcaD, srcbD);
	
	// Fetch stage logic
	flopenr #(32) pcreg(clk, reset, ~stallF, pcnextFD, pcF);
	adder pcadd1(pcF, 32'b100, pcplus4F);
	
	// Decode stage
	flopenr   #(32) r1D(clk, reset, ~stallD, pcplus4F, pcplus4D);
	flopenclr #(32) r2D(clk, reset, ~stallD, flushD, instrF, instrD);
	signext   #(16)se(instrD[15:0], signimmD);
	sl2 immsh(signimmD, signimmshD);
	adder pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2      #(32) forwardadmux(srcaD, aluoutM, forwardaD, srca2D);
	mux2      #(32) forwardbdmux(srcbD, aluoutM, forwardbD, srcb2D);
	equate    #(32)comp(srca2D, srcb2D, equalD);
	mux3      #(32)writeDataMuxD(resultW, lboutimmW, pcplus4D, wd3selectorW, writedatamuxoutD);	//lb is yet to be done

	assign opD    = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD    = instrD[25:21];
	assign rtD    = instrD[20:16];
	assign rdD    = instrD[15:11];
	assign shamtD = instrD[10:6];
	assign flushD = pcsrcD | jumpD | jumprW | wd3selectorW[1];

	// Execute stage
	flopclr #(32) r1E(clk, reset, flushE, srcaD, srcaE);
	flopclr #(32) r2E(clk, reset, flushE, srcbD, srcbE);
	flopclr #(32) r3E(clk, reset, flushE, signimmD, signimmE);
	flopclr #(5)  r4E(clk, reset, flushE, rsD, rsE);
	flopclr #(5)  r5E(clk, reset, flushE, rtD, rtE);
	flopclr #(5)  r6E(clk, reset, flushE, rdD, rdE);
	flopclr #(5)  r7E(clk, reset, flushE, shamtD, shamtE);//for the shift instructions
	mux3    #(32) forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3    #(32) forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2    #(32) srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	mux3	#(32) srcamux(srca2E, lowM, highM, srcaselectorE, srca3E);
	alu alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE);
	mux3    #(5) regdesmuxE(rtE, rdE, 5'b11111, regdstE, writeregE);
	operations64 op64(srca2E, srcb2E, operation64E, highE, lowE);
	
	// Memory stage
	flopr  #(32) hi(clk, reset, highE, highM);
	flopr  #(32) lo(clk, reset, lowE, lowM);
	flopr  #(32) r1M(clk, reset, srcb2E, writedataM);
	flopr  #(32) r2M(clk, reset, aluoutE, aluoutM);
	flopr  #(5) r3M(clk, reset, writeregE, writeregM);
	mux4   #(8) sbmux(writedataM[7:0], writedataM[15:8], writedataM[23:16], writedataM[31:24], aluoutM[1:0],  selectedbyte);
	mux2   #(32)wdmux(writedataM, {24'bx,selectedbyte} ,byteM, writedataoutM);
	
	// Writeback stage
	flopr   #(32) r1W(clk, reset, aluoutM, aluoutW);
	flopr   #(32) r2W(clk, reset, readdataM, readdataW);
	flopr   #(5) r3W(clk, reset, writeregM, writeregW);
	mux2    #(32) resmux(aluoutW, readdataW, memtoregW,resultW); 
	mux4    #(8)lbmux(readdataW[7:0],readdataW[15:8],readdataW[23:16],readdataW[31:24],aluoutW[1:0],lboutW);
	signext #(8)lbse(lboutW, lboutimmW);
endmodule

