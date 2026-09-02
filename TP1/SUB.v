module SUB
#(
    parameter WIDTH = 8
)
(
    input wire [WIDTH - 1 : 0] A,
    input wire [WIDTH - 1 : 0] B,
    output wire [WIDTH - 1 : 0] y,
    output wire ovf,
    output wire carry
);

wire [WIDTH : 0] result;

assign result = {1'b0, A} - {1'b0, B};
assign y     = result[WIDTH - 1 : 0];
assign carry = result[WIDTH];

assign ovf = (A[WIDTH-1] != B[WIDTH-1]) && (y[WIDTH-1] != A[WIDTH-1]);

endmodule
