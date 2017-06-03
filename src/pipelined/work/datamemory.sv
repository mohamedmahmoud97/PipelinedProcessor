module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd,
	    input logic b);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
    if (we)
	if( b === 0)
      		RAM[a[31:2]] <= wd;
	else if ( b === 1)
		case(a[1:0])
			2'b00: RAM[a[31:0]] <= wd[7:0];
			2'b01: RAM[a[31:0]] <= wd[15:8];
			2'b10: RAM[a[31:0]] <= wd[23:16];
			2'b11: RAM[a[31:0]] <= wd[31:24];
		endcase

endmodule
