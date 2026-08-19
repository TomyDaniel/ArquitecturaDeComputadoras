module multi_compuerta
  (
    input wire A,
    input wire B,
    input wire C,
    input wire D,
    input wire clk,
    output reg x,
    output reg y
  );

  reg q1, q2, q3, q4;
  
  wire e;
  assign e = q1 & q2;
  wire d;
  assign d = e | q3;
  wire t;
  assign t = ~d;
  wire r;
  assign r = q3 & q4;
  wire x_out;
  assign x_out = r | t;
  wire y_out;
  assign y_out = r & q3 & q4;
  
  always @(posedge clk) begin
    
    q1 <= A;
    q2 <= B;
    q3 <= C;
    q4 <= D;

    x <= x_out;
    y <= y_out;

  end
endmodule

