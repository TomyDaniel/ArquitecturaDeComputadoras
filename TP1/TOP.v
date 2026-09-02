module top_basys3
(
    input  wire clk,
    input  wire [15:0] SW,
    input  wire btnC,      // cargar valor
    input  wire btnU,      // cargar A
    input  wire btnL,      // cargar B
    input  wire btnR,      // cargar en opcode
    output wire [15:0] LED
);
    localparam WIDTH = 8;

    wire [WIDTH-1:0] data_in = SW[7:0];

    reg [WIDTH-1:0] A_reg, B_reg;
    reg [5:0] opcode_reg;

    reg btnC_prev;
    wire btnC_edge = btnC & ~btnC_prev;

    always @(posedge clk) begin
        btnC_prev <= btnC;
        if (btnC_edge) begin
            if (btnU) A_reg      <= data_in;
            if (btnL) B_reg      <= data_in;
            if (btnR) opcode_reg <= data_in[5:0];
        end
    end

    wire [WIDTH-1:0] y;
    wire carry_flag, ovf_flag;

    ALU #(.WIDTH(WIDTH)) alu_inst (
        .A(A_reg),
        .B(B_reg),
        .opcode(opcode_reg),
        .y(y),
        .carry_flag(carry_flag),
        .ovf_flag(ovf_flag)
    );

    assign LED[7:0]   = y;
    assign LED[8]     = carry_flag;
    assign LED[9]     = ovf_flag;
    assign LED[15:10] = 6'b0;

endmodule