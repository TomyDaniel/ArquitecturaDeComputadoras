module top_basys3_uart
#(
    parameter WIDTH = 8,
    parameter DVSR  = 326
)
(
    input  wire clk,
    input  wire reset,
    input  wire RsRx,
    output wire RsTx
);

    // ===== Baud Rate Generator =====
    wire tick;
    baud_rate_gen #(.DVSR(DVSR)) u_baud (
        .clk(clk),
        .tick(tick)
    );

    // ===== Receptor y Transmisor =====
    wire [WIDTH-1:0] rx_data_raw;
    wire rx_done_tick;
    wire [WIDTH-1:0] tx_data_raw;
    wire tx_start_raw;
    wire tx_done_tick;
    wire tx_line;

    Rx #(.D_BIT(WIDTH), .SB_TICK(16)) u_rx (
        .clk(clk),
        .rx(RsRx),
        .s_tick(tick),
        .rx_done_tick(rx_done_tick),
        .dout(rx_data_raw)
    );

    Tx #(.D_BIT(WIDTH), .SB_TICK(16)) u_tx (
        .clk(clk),
        .tx_start(tx_start_raw),
        .s_tick(tick),
        .din(tx_data_raw),
        .tx_done_tick(tx_done_tick),
        .tx(tx_line)
    );

    assign RsTx = tx_line;

    // ===== Interfaz (buffer con banderas) =====
    wire rd, wr;
    wire rx_empty, tx_full;
    wire [WIDTH-1:0] r_data;
    reg  [WIDTH-1:0] w_data;

    interface_circuit #(.D_BIT(WIDTH)) u_intf (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data_raw),
        .rx_done_tick(rx_done_tick),
        .rd(rd),
        .rx_empty(rx_empty),
        .r_data(r_data),
        .wr(wr),
        .w_data(w_data),
        .tx_done_tick(tx_done_tick),
        .tx_full(tx_full),
        .tx_data(tx_data_raw),
        .tx_start(tx_start_raw)
    );

    // ===== ALU =====
    reg [WIDTH-1:0] A_reg, B_reg;
    reg [5:0] opcode_reg;
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

    // ===== Controlador del protocolo =====
    localparam [2:0]
        WAIT_A   = 3'b000,
        WAIT_B   = 3'b001,
        WAIT_OP  = 3'b010,
        SEND_Y   = 3'b011,
        WAIT_TXY = 3'b100,
        SEND_FL  = 3'b101,
        WAIT_TXF = 3'b110;

    reg [2:0] pstate, pnext;
    reg rd_reg, wr_reg;

    assign rd = rd_reg;
    assign wr = wr_reg;

    always @(posedge clk) begin
        if (reset) pstate <= WAIT_A;
        else       pstate <= pnext;
    end

    always @(*) begin
        pnext  = pstate;
        rd_reg = 1'b0;
        wr_reg = 1'b0;
        w_data = {WIDTH{1'b0}};

        case (pstate)
            // Pide leer si hay un byte disponible; se queda esperando si no
            WAIT_A: if (~rx_empty) begin
                rd_reg = 1'b1;
                pnext  = WAIT_B;
            end

            WAIT_B: if (~rx_empty) begin
                rd_reg = 1'b1;
                pnext  = WAIT_OP;
            end

            WAIT_OP: if (~rx_empty) begin
                rd_reg = 1'b1;
                pnext  = SEND_Y;
            end

            // Pide escribir el resultado, si el Tx no está ocupado
            SEND_Y: if (~tx_full) begin
                wr_reg = 1'b1;
                w_data = y;
                pnext  = WAIT_TXY;
            end

            // Espera a que INTF libere tx_full (Tx terminó de mandar el byte)
            WAIT_TXY: if (tx_full == 1'b0) pnext = SEND_FL;

            SEND_FL: if (~tx_full) begin
                wr_reg = 1'b1;
                w_data = {6'b0, ovf_flag, carry_flag};
                pnext  = WAIT_TXF;
            end

            WAIT_TXF: if (tx_full == 1'b0) pnext = WAIT_A;

            default: pnext = WAIT_A;
        endcase
    end

    // Registros de datos: capturan r_data en el mismo ciclo en que se pide "rd"
    always @(posedge clk) begin
        if (reset) begin
            A_reg      <= 0;
            B_reg      <= 0;
            opcode_reg <= 0;
        end else if (rd_reg) begin
            case (pstate)
                WAIT_A:  A_reg      <= r_data;
                WAIT_B:  B_reg      <= r_data;
                WAIT_OP: opcode_reg <= r_data[5:0];
            endcase
        end
    end

endmodule