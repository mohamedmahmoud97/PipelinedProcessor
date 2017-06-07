 module testbench();
  logic        clk;
  logic        reset;
  logic [31:0] writedata, dataadr;
  logic        memwrite;
  
  int	count = 0;

  // instantiate device to be tested
  top dut(clk, reset, writedata, dataadr, memwrite);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 10; clk <= 0; # 10;
    end

  // check that 7 gets written to address 84
  always@(negedge clk)
    begin
      if(memwrite) begin
	if(count === 0) begin
        if(dataadr === 84 & writedata === 7654) begin
          $display("Simulation succeeded");
          //$stop;
        end end else if(count === 1) begin
			if(dataadr === 40 & writedata === 36) begin
				$display("Simulation succeeded");
	end end else if(count === 2) begin
			if(dataadr === 60 & writedata === 36) begin
				$display("Simulation succeeded");
	end end
	else if (dataadr !== 80) begin
          $display("Simulation failed");
          //$stop;
        end
	count++;
	if(count === 3)
		$stop;
      end
    end
endmodule



