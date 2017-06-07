module datapath(input logic clk, reset,
		input logic memtoregE, memtoregM, memtoregW,
		input logic pcsrcD, branchD,
		input logic alusrcE,
		input logic regdstE,
		input logic regwriteE, regwriteM, regwriteW,
		input logic jumpD,
		input logic [3:0] alucontrolE,
		output logic equalD,
		output logic [31:0] pcF,
		input logic [31:0] instrF,
		output logic [31:0] aluoutM, writedataM,
		input logic [31:0] readdataM,
		output logic [5:0] opD, functD,
		output logic flushE, 
                input logic branchneD,
		input logic [1:0] hiloE,
		input logic  multdivE, lbW,jrD,jalD);

	logic forwardaD, forwardbD;
	logic [1:0] forwardaE, forwardbE;
	logic stallF;
	logic [4:0] rsD, rtD, rdD, rsE, rtE, rdE,shamtD,shamtE;//adding shift amount for both decode and executes stages
	logic [4:0] writeregE, writeregM, writeregW, writereg;
	logic flushD;
	logic [31:0] pcnextFD, pcnextFD2, pcnextbrFD, pcbranchD;
	logic [31:0] signimmD, signimmE, signimmshD;
	logic [31:0] selectedsrcaE, srcaD, srca2D, srcaE, srca2E;
	logic [31:0] srcbD, srcb2D, srcbE, srcb2E, srcb3E;
	logic [31:0] pcplus4F, pcplus4D, instrD;
	logic [31:0] aluoutE, aluoutW;
	logic [31:0] highE,lowE,high,low;
	logic [31:0] readdataW, readdata, resultW,result;
	logic [7:0]  lbselectedW;
	logic [31:0] lbselectedimmW;

	// hazard detection
	hazard h(rsD, rtD, rsE, rtE, writeregE, writeregM,
		writeregW,regwriteE, regwriteM, regwriteW,
		memtoregE, memtoregM, branchD, branchneD,
		forwardaD, forwardbD, forwardaE,forwardbE,
		stallF, stallD, flushE);
	
	// next PC logic (operates in fetch and decode)
	mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00}, jumpD, pcnextFD);//to choose from pcnextbrFD and pcjump
	mux2 #(32) pcmux2(pcnextFD, srca2D,jrD,pcnextFD2);//to choose the most recent address in [rs] in the case of jr
	
	// register file (operates in decode and writeback)
	regfile rf(clk, regwriteW, rsD, rtD, writereg, result, srcaD, srcbD);
	
	// Fetch stage logic
	flopenr #(32) pcreg(clk, reset, ~stallF, pcnextFD2, pcF);
	adder pcadd1(pcF, 32'b100, pcplus4F);
	
	// Decode stage
	flopenr   #(32) r1D(clk, reset, ~stallD, pcplus4F, pcplus4D);
	flopenclr #(32) r2D(clk, reset, ~stallD, flushD, instrF, instrD);
	signext16 seD(instrD[15:0], signimmD);
	sl2 immsh(signimmD, signimmshD);
	adder pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2   #(32) forwardadmux(srcaD, aluoutM, forwardaD, srca2D);
	mux2   #(32) forwardbdmux(srcbD, aluoutM, forwardbD, srcb2D);
	equate #(32) comp(srca2D, srcb2D, equalD);
	mux2   #(5) a3mux(writeregW,5'b11111,jalD,writereg);//to choose the destination to be $ra in case of jal
	mux2   #(32) wd3mux(resultW,pcplus4D,jalD,result);//to choose the data to be pcplus4 in case of jal

	assign opD    = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD    = instrD[25:21];
	assign rtD    = instrD[20:16];
	assign rdD    = instrD[15:11];
	assign shamtD = instrD[10:6];//we take the shift amount bits from the instruction
	assign flushD = pcsrcD | jumpD | jrD;// updated to handel jr hazards

	// Execute stage
	flopclr #(32) r1E(clk, reset, flushE, srcaD, srcaE);
	flopclr #(32) r2E(clk, reset, flushE, srcbD, srcbE);
	flopclr #(32) r3E(clk, reset, flushE, signimmD, signimmE);
	flopclr #(5)  r4E(clk, reset, flushE, rsD, rsE);
	flopclr #(5)  r5E(clk, reset, flushE, rtD, rtE);
	flopclr #(5)  r6E(clk, reset, flushE, rdD, rdE);
	flopclr #(5)  r7E(clk, reset, flushE, shamtD, shamtE);//adding register to hold the shift amount between D and E which is the input of the ALU 
	mux3    #(32) forwardaemux(selectedsrcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3    #(32) forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2    #(32) srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu alu(srca2E, srcb3E, shamtE, alucontrolE, aluoutE,high,low);//shamtE is added as input highE and lowE as outputs to the ALU
	mux2    #(5) wrmux(rtE, rdE, regdstE, writeregE); 
	mux3    #(32) hilomux(srcaE,lowE,highE,hiloE,selectedsrcaE);
	
	// Memory stage
	flopr   #(32) r1M(clk, reset, srcb2E, writedataM);
	flopr   #(32) r2M(clk, reset, aluoutE, aluoutM);
	flopr   #(5)  r3M(clk, reset, writeregE, writeregM);
 	flopenr #(32) r4M(clk, reset, multdivE, high, highE);//used for both mult and div
	flopenr #(32) r5M(clk, reset, multdivE, low, lowE);//used for both mult and div

	// Writeback stage
	flopr   #(32) r1W(clk, reset, aluoutM, aluoutW);
	flopr   #(32) r2W(clk, reset, readdataM, readdataW);
	flopr   #(5)  r3W(clk, reset, writeregM, writeregW);
	mux4    #(8)  lbmux(readdataW[7:0],readdataW[15:8],readdataW[23:16],readdataW[31:24],aluoutW[1:0],lbselectedW);
	signext8 seW(lbselectedW, lbselectedimmW);
	mux2    #(32) readdatamux(readdataW,lbselectedimmW,lbW,readdata);
	mux2    #(32) resmux(aluoutW, readdata, memtoregW,resultW);
       
endmodule
	

