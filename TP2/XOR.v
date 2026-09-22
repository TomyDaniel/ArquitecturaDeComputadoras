module XOR
#(
    parameter WIDTH = 8
)
(
    input wire [WIDTH - 1 : 0] A,
    input wire [WIDTH - 1 : 0] B,
    output wire [WIDTH - 1 : 0] y
);

wire [WIDTH - 1 : 0] r;
assign r = ~A & B;
wire [WIDTH - 1 : 0] t;
assign t = A & ~B;
assign y = r | t;

endmodule
