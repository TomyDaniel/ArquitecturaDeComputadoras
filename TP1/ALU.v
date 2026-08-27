module ALU
#(
    parameter WIDTH = 8
)
(
    input wire [WIDTH - 1 : 0] A,
    input wire [WIDTH - 1 : 0] B,
    input wire [5 : 0] opcode,
    output reg [WIDTH - 1 : 0] y
);

    localparam OP_AND = 6'b100100;
    localparam OP_OR = 6'b100101;
    localparam OP_NOR = 6'b100111;
    localparam OP_XOR = 6'b100110;
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_SRA = 6'b000011;
    localparam OP_SRL = 6'b000010;

    wire [WIDTH-1:0] and_out, or_out, nor_out, xor_out, add_out, sub_out, sra_out, srl_out;

    AND #(.WIDTH(WIDTH)) u_and (.A(A), .B(B), .y(and_out));
    OR  #(.WIDTH(WIDTH)) u_or  (.A(A), .B(B), .y(or_out));
    NOR #(.WIDTH(WIDTH)) u_nor (.A(A), .B(B), .y(nor_out));
    XOR #(.WIDTH(WIDTH)) u_xor (.A(A), .B(B), .y(xor_out));
    SUM #(.WIDTH(WIDTH)) u_sum (.A(A), .B(B), .y(add_out));
    SUB #(.WIDTH(WIDTH)) u_sub (.A(A), .B(B), .y(sub_out));
    SRA #(.WIDTH(WIDTH)) u_sra (.A(A), .B(B[$clog2(WIDTH)-1:0]), .y(sra_out));
    SRL #(.WIDTH(WIDTH)) u_srl (.A(A), .B(B[$clog2(WIDTH)-1:0]), .y(srl_out));

    always @(*) begin
        case(opcode)
            OP_AND: y = and_out;
            OP_OR: y = or_out;
            OP_NOR: y = nor_out;
            OP_XOR: y = xor_out;
            OP_ADD: y = add_out;
            OP_SUB: y = sub_out;
            OP_SRA: y = sra_out;
            OP_SRL: y = srl_out;
        endcase
    end

endmodule
