module level2_1(
    input wire a,
    input wire b,
    input wire c,
    output wire y
);

wire e;
assign e = a & b;
wire d;
assign d = e & c;
wire t;
assign t = ~a & ~b;
wire r;
assign r = t & ~c;
assign y = d | r;

endmodule
