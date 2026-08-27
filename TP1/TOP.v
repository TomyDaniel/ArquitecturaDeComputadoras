module top_basys3
(
    input  wire clk,
    input  wire [15:0] SW,
    input  wire btnC,      // botón central: "cargar valor"
    input  wire btnU,      // selector: cargar en A
    input  wire btnL,      // selector: cargar en B
    input  wire btnR,      // selector: cargar en opcode
    output wire [15:0] LED
);

    localparam WIDTH = 8;

    // Valor "a cargar", tomado de los primeros 8 switches
    wire [WIDTH-1:0] data_in = SW[7:0];

    // Registros internos que retienen A, B y opcode
    reg [WIDTH-1:0] A_reg, B_reg;
    reg [5:0] opcode_reg;

    // Detección de flanco en btnC, para no cargar en loop mientras esté apretado
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

    ALU #(.WIDTH(WIDTH)) alu_inst (
        .A(A_reg),
        .B(B_reg),
        .opcode(opcode_reg),
        .y(y)
    );

    assign LED[7:0]  = y;
    assign LED[15:8] = 8'b0;

endmodule
