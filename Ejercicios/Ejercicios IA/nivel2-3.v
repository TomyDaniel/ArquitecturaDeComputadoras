module level2_3(
    input wire a,
    input wire b,
    input wire c,
    input wire d,
    output wire x,
    output wire y
);

wire e;
assign e = a & b;
wire f;
assign f = c & ~d;
assign y = e | f;
assign x = ~y;

endmodule
