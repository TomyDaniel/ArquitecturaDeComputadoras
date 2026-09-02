module ALU
#(
    parameter WIDTH = 8
)
(
    input wire [WIDTH - 1 : 0] A,
    input wire [WIDTH - 1 : 0] B,
    input wire [5 : 0] opcode,
    output reg [WIDTH - 1 : 0] y,
    output reg  carry_flag,
    output reg  ovf_flag
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
    wire add_carry, add_ovf, sub_carry, sub_ovf;
    
    AND #(.WIDTH(WIDTH)) u_and (.A(A), .B(B), .y(and_out));
    OR  #(.WIDTH(WIDTH)) u_or  (.A(A), .B(B), .y(or_out));
    NOR #(.WIDTH(WIDTH)) u_nor (.A(A), .B(B), .y(nor_out));
    XOR #(.WIDTH(WIDTH)) u_xor (.A(A), .B(B), .y(xor_out));
    SUM #(.WIDTH(WIDTH)) u_sum (.A(A), .B(B), .y(add_out), .carry(add_carry), .ovf(add_ovf));
    SUB #(.WIDTH(WIDTH)) u_sub (.A(A), .B(B), .y(sub_out), .carry(sub_carry), .ovf(sub_ovf));
    SRA #(.WIDTH(WIDTH)) u_sra (.A(A), .B(B[$clog2(WIDTH)-1:0]), .y(sra_out));
    SRL #(.WIDTH(WIDTH)) u_srl (.A(A), .B(B[$clog2(WIDTH)-1:0]), .y(srl_out));

    always @(*) begin
        case(opcode)
            OP_AND: begin y = and_out; carry_flag = 1'b0;      ovf_flag = 1'b0;     end
            OP_OR:  begin y = or_out;  carry_flag = 1'b0;      ovf_flag = 1'b0;     end
            OP_NOR: begin y = nor_out; carry_flag = 1'b0;      ovf_flag = 1'b0;     end
            OP_XOR: begin y = xor_out; carry_flag = 1'b0;      ovf_flag = 1'b0;     end
            OP_ADD: begin y = add_out; carry_flag = add_carry; ovf_flag = add_ovf;  end
            OP_SUB: begin y = sub_out; carry_flag = sub_carry; ovf_flag = sub_ovf;  end
            OP_SRA: begin y = sra_out; carry_flag = 1'b0;      ovf_flag = 1'b0;     end
            OP_SRL: begin y = srl_out; carry_flag = 1'b0;      ovf_flag = 1'b0;     end
            default: begin y = {WIDTH{1'b0}}; carry_flag = 1'b0; ovf_flag = 1'b0;   end
        endcase
    end

endmodule
