/*module datapath(input logic  clk, reset,
				input logic  memtoregE,memtoregM,memtoregW,
				input logic  pcsrcD, branchD,
				input logic  alusrcE, regdstE,
				input logic  regwriteE,regwriteM,regwriteW,
				input logic  jumpD,
				input logic  [2:0] alucontrolE,
				output logic equalD,
				output logic [31:0] pcF,
				input logic  [31:0] instrF,
				output logic [31:0] aluoutM,writedataM,
				input logic  [31:0] readdataM,
				output logic [5:0] opD, functD,
				output logic flushE);

  // Below are the internal signals of the datapath module.
  logic		   flushD;
  logic 	   forwardAD,forwardBD;
  logic [1:0]  forwardBE,forwardAE;
  logic [4:0]  rsD, rtD, rdD, rsE, rtE, rdE;
  logic [4:0]  writeregE, writeregM, writeregW;
  logic [31:0] pcnextF, pcplus4F, pcplus4D, pcbranchD;/////////////////////////////////////////////////
  logic [31:0] signimmD, signimmE, signimmshD;     // the sign-extended immediate
  logic [31:0] wd3D, rd1D, rd1E, srcAE,rd2D, rd2E, rd2muxout, srcBE;
  logic [31:0] instrD, cmpa, cmpb;
  logic [31:0] writedataE,readdataW;
  logic [31:0] aluresult, aluoutE, aluoutW, resultW;

  // op and funct fields to controller
  assign op     =  instrD[31:26];
  assign funct  =  instrD[5:0];
  assign rsD    =  instrD[25:21];
  assign rtD    =  instrD[20:16];
  assign rdD    =  instrD[15:11];
  assign flushD =  pcsrcD | jumpD;

  // datapath
	  
	  //FETCH STAGE lsa fadel n3mel signlas el control (stall)
	mux2       #(32)pcmuxf(pcplus4F,pcbranchD,pcsrcD,pcnextF); 
	flopenr    #(32)pcregf(clk, reset, ~stallf, pcnextF, pcF);
	adder      pcadderf(pcF,32'b100,pcplus4F);
	flopenclr  #(32)instrregf(clk,reset , flushD, ~stallD, readdataM, instrD);
	flopenclr  #(32)pcplus4reg(clk,reset , flushD, ~stallD, pcplus4F, pcplus4D);

	  //DECODE STAGE lsa fadel cmp module
	regfile regfile(clk,regwrite,rsD,rtD,writeregW,resultW,rd1D,rd2D);
	mux2     #(32)rd1mux(rd1D, aluoutM, forwardAD, cmpa);
	mux2     #(32)rd2mux(rd2D, aluoutM, forwardBD, cmpb); 
	signext  signe(instrD[15:0],signimmD);
	equate	 #(32)equality(cmpa,cmpb,EqualD);
	sl2      shift2(signimmD,signimmshD);
	adder    pcbranchDadder(signimmshD,pcplus4D,pcbranchD);
	flopclr  #(32)srcareg(clk, reset, flushE, rd1D, rd1E); 
	flopclr  #(32)srcbreg(clk, reset, flushE, rd2D, rd2E);
	flopclr  #(5)rsreg(clk, reset, flushE, rsD, rsE);
	flopclr  #(5)rtreg(clk, reset, flushE, rtD, rtE);
	flopclr  #(5)rdreg(clk, reset, flushE, rdD, rdE);
	flopclr  #(32)signimmreg(clk, reset, flushE, signimmD, signimmE);

	  //EXECUTE STAGE
	mux3	#(32)srcamux(rd1E, resultW, aluoutM, forwardAE, srcAE);
	mux3	#(32)srcbintermux(rd2E, resultW, aluoutM, forwardBE, rd2muxout);
	mux2	#(32)srcbmux(rd2muxout, signimmE, alusrcE, srcBE);
	mux2	#(5)regdstmux(rtE, rdE, regdstE, writeregE);
	alu     alu(srcAE, srcBE, alucontrolE, aluoutE);		//alu just one output and needs mmodification in the module		
	flopr   #(32)alureg(clk,reset,aluoutE,aluoutM);
	flopr   #(32)writedatareg(clk,reset,writedataE,writedataM);
	flopr   #(5)writeregister(clk,reset,writeregE,writeregM);

	  // MEMORY STAGE
	flopr   #(32)readdatareg(clk,reset,readdataM,readdataW);
	flopr   #(32)aluoutreg(clk,reset,aluoutM,aluoutW);

	  //WRITEBACK STAGE
	mux2	#(32)resultmux(aluoutW,readdataW, memtoregW,resultW);
endmodule
*/

module datapath(input logic clk, reset,
		input logic memtoregE, memtoregM, memtoregW,
		input logic pcsrcD, branchD,
		input logic alusrcE, regdstE,
		input logic regwriteE, regwriteM, regwriteW,
		input logic jumpD,
		input logic [2:0] alucontrolE,
		output logic equalD,
		output logic [31:0] pcF,
		input logic [31:0] instrF,
		output logic [31:0] aluoutM, writedataM,
		input logic [31:0] readdataM,
		output logic [5:0] opD, functD,
		output logic flushE);

	logic forwardaD, forwardbD;
	logic [1:0] forwardaE, forwardbE;
	logic stallF;
	logic [4:0] rsD, rtD, rdD, rsE, rtE, rdE;
	logic [4:0] writeregE, writeregM, writeregW;
	logic flushD;
	logic [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD;
	logic [31:0] signimmD, signimmE, signimmshD;
	logic [31:0] srcaD, srca2D, srcaE, srca2E;
	logic [31:0] srcbD, srcb2D, srcbE, srcb2E, srcb3E;
	logic [31:0] pcplus4D, instrD;
	logic [31:0] aluoutE, aluoutW;
	logic [31:0] readdataW, resultW;

	// hazard detection
	hazard h(rsD, rtD, rsE, rtE, writeregE, writeregM,
	writeregW,regwriteE, regwriteM, regwriteW,
	memtoregE, memtoregM, branchD,
	forwardaD, forwardbD, forwardaE,
	forwardbE,
	stallF, stallD, flushE);
	
	// next PC logic (operates in fetch and decode)
	mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD,
	pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],
	instrD[25:0], 2'b00},
	jumpD, pcnextFD);
	
	// register file (operates in decode and writeback)
	regfile rf(clk, regwriteW, rsD, rtD, writeregW, resultW, srcaD, srcbD);
	
	// Fetch stage logic
	flopenr #(32) pcreg(clk, reset, ~stallF, pcnextFD, pcF);
	adder pcadd1(pcF, 32'b100, pcplus4F);
	
	// Decode stage
	flopenr #(32) r1D(clk, reset, ~stallD, pcplus4F, pcplus4D);
	flopenclr #(32) r2D(clk, reset, ~stallD, flushD, instrF, instrD);
	signext se(instrD[15:0], signimmD);
	sl2 immsh(signimmD, signimmshD);
	adder pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2 #(32) forwardadmux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 #(32) forwardbdmux(srcbD, aluoutM, forwardbD, srcb2D);
	equate #(32)comp(srca2D, srcb2D, equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign flushD = pcsrcD | jumpD;

	// Execute stage
	flopclr #(32) r1E(clk, reset, flushE, srcaD, srcaE);
	flopclr #(32) r2E(clk, reset, flushE, srcbD, srcbE);
	flopclr #(32) r3E(clk, reset, flushE, signimmD, signimmE);
	flopclr #(5) r4E(clk, reset, flushE, rsD, rsE);
	flopclr #(5) r5E(clk, reset, flushE, rtD, rtE);
	flopclr #(5) r6E(clk, reset, flushE, rdD, rdE);
	mux3 #(32) forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3 #(32) forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2 #(32) srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
	alu alu(srca2E, srcb3E, alucontrolE, aluoutE);
	mux2 #(5) wrmux(rtE, rdE, regdstE, writeregE);
	
	// Memory stage
	flopr #(32) r1M(clk, reset, srcb2E, writedataM);
	flopr #(32) r2M(clk, reset, aluoutE, aluoutM);
	flopr #(5) r3M(clk, reset, writeregE, writeregM);
	
	// Writeback stage
	flopr #(32) r1W(clk, reset, aluoutM, aluoutW);
	flopr #(32) r2W(clk, reset, readdataM, readdataW);
	flopr #(5) r3W(clk, reset, writeregM, writeregW);
	mux2 #(32) resmux(aluoutW, readdataW, memtoregW,
	resultW); 

endmodule
	
module hazard(input logic [4:0] rsD, rtD, rsE, rtE,
	      input logic [4:0] writeregE, writeregM, writeregW,
	      input logic regwriteE, regwriteM, regwriteW,
	      input logic memtoregE, memtoregM, branchD,
	      output logic forwardaD, forwardbD,
	      output logic [1:0] forwardaE, forwardbE,
	      output logic stallF, stallD, flushE);
	
	logic lwstallD, branchstallD;

	// forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD !=0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD !=0 & rtD == writeregM & regwriteM);
	
	// forwarding sources to E stage (ALU)
	always_comb
	begin
		forwardaE = 2'b00; forwardbE = 2'b00;
		if (rsE != 0)
		if (rsE == writeregM & regwriteM)
			forwardaE = 2'b10;
		else if (rsE == writeregW & regwriteW)
			forwardaE = 2'b01;
		if (rtE != 0)
		if (rtE == writeregM & regwriteM)
			forwardbE = 2'b10;
		else if (rtE == writeregW & regwriteW)
			forwardbE = 2'b01;
	end

	// stalls
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD = branchD & (regwriteE & (writeregE == rsD | writeregE == rtD) | memtoregM & (writeregM == rsD | writeregM == rtD));
	assign #1 stallD = lwstallD | branchstallD;
	assign #1 stallF = stallD;
	
	// stalling D stalls all previous stages
	assign #1 flushE = stallD;
	
	// stalling D flushes next stage
	// Note: not necessary to stall D stage on store
	// if source comes from load;
	// instead, another bypass network could
	// be added from W to M
	
endmodule

