module SRA
#(
    parameter WIDTH = 8
)
(
    input  wire signed [WIDTH-1:0] A,          // dato a desplazar
    input  wire [$clog2(WIDTH)-1:0] B, // shift amount (cantidad de bits a correr)
    output wire signed [WIDTH-1:0] y
);

assign y = A >>> B;

endmodule
