module level2_2(
    input wire a,
    input wire b,
    input wire c,
    input wire d,
    output wire y
);

wire e;
assign e = a & b;
wire f;
assign f = c & ~d;
assign y = e | f;

endmodule
