module SRL
#(
    parameter WIDTH = 8
)
(
    input  wire [WIDTH-1:0] A,           
    input  wire [$clog2(WIDTH)-1:0] B,
    output wire [WIDTH-1:0] y
);

assign y = A >> B;

endmodule
