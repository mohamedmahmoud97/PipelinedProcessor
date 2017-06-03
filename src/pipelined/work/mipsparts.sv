module adder(input  logic [31:0] a, b,
             output logic [31:0] y);

  assign y = a + b;
endmodule

module sl2(input  logic [31:0] a,
           output logic [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext16(input  logic [15:0] a,
                 output logic [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module signext8(input  logic [7:0] a,
                output logic [31:0] y);
              
  assign y = {{24{a[7]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic  clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input  logic  clk, reset,
                 input  logic  en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);
 
  always_ff @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (en)    q <= d;
endmodule


//REGISTER WITH CLEAR ADDED 
module flopclr #(parameter WIDTH = 8)
                (input  logic clk, reset,
                 input  logic clear,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);
 
  always_ff @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (clear) q <= 0;
    else    q <= d;
endmodule


//REGISTER WITH CLEAR AND ENABLE
module flopenclr #(parameter WIDTH = 8)
                 (input  logic clk, reset,
                  input  logic en,clear,
                  input  logic [WIDTH-1:0] d, 
                  output logic [WIDTH-1:0] q);
 
  always_ff @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (clear) q <= 0;
    else if (en)    q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module equate #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              output logic  y);

  assign #1 y = (d0 === d1) ? 1 : 0;
endmodule

module mux4 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2, d3,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

   always_comb
      case(s)
         2'b00: y <= d0;
         2'b01: y <= d1;
         2'b10: y <= d2;
         2'b11: y <= d3;
      endcase
endmodule
