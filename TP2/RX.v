module Rx
#(
    parameter D_BIT   = 8,   // cantidad de bits de datos
    parameter SB_TICK  = 16  // cantidad de ticks del bit de stop (16 = 1 bit de stop)
)
(
    input  wire clk,
    input  wire rx,
    input  wire s_tick,
    output reg  rx_done_tick,
    output wire [D_BIT-1:0] dout
);

    // Estados de la FSM
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] s_reg, s_next;          // contador de ticks (0 a 15)
    reg [2:0] n_reg, n_next;          // contador de bits recibidos (0 a 7)
    reg [D_BIT-1:0] b_reg, b_next;    // shift register donde se arma el byte

    // Registro de estado
    always @(posedge clk) begin
        state <= next_state;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
    end

    // Lógica de próximo estado
    always @(*) begin
        next_state   = state;
        rx_done_tick = 1'b0;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;

        case (state)
            IDLE: begin
                if (~rx) begin          // rx cae a 0: arrancó el start bit
                    next_state = START;
                    s_next     = 0;
                end
            end

            START: begin
                if (s_tick) begin
                    if (s_reg == 7) begin    // llegó a la mitad del start bit
                        next_state = DATA;
                        s_next     = 0;
                        n_next     = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                if (s_tick) begin
                    if (s_reg == 15) begin        // llegó a la mitad del bit de dato
                        s_next = 0;
                        b_next = {rx, b_reg[D_BIT-1:1]};  // entra por la izquierda, corre a la derecha
                        if (n_reg == (D_BIT-1))
                            next_state = STOP;
                        else
                            n_next = n_reg + 1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            STOP: begin
                if (s_tick) begin
                    if (s_reg == (SB_TICK-1)) begin
                        next_state   = IDLE;
                        rx_done_tick = 1'b1;      // avisa: ¡byte listo!
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            default: next_state = IDLE;
        endcase
    end

    assign dout = b_reg;

endmodule
