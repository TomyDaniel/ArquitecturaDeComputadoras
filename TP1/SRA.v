module SRA
#(
    parameter WIDTH = 8
)
(
    input  wire signed [WIDTH-1:0] A,          
    input  wire [$clog2(WIDTH)-1:0] B, 
    output wire signed [WIDTH-1:0] y
);

assign y = A >>> B;

endmodule
