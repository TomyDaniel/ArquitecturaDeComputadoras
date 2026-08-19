module multi_compuerta
  (
    input wire A,
    input wire B,
    input wire C,
    input wire D,
    output wire x,
    output wire y
  );
  
  wire e;
  assign e = A & B;
  wire d;
  assign d = e | C;
  wire t;
  assign t = ~d;
  wire r;
  assign r = C & D;
  assign x = r | t;
  assign y = r & C & D;
  
endmodule