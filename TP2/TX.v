module Tx
#(
    parameter D_BIT   = 8,   
    parameter SB_TICK  = 16  
)
(
    input  wire clk,
    input  wire tx_start,          
    input  wire s_tick,
    input  wire [D_BIT-1:0] din,  
    output reg  tx_done_tick,
    output wire tx
);

    
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [D_BIT-1:0] b_reg, b_next;  
    reg tx_reg, tx_next;           

    always @(posedge clk) begin
        state  <= next_state;
        s_reg  <= s_next;
        n_reg  <= n_next;
        b_reg  <= b_next;
        tx_reg <= tx_next;
    end

    always @(*) begin
        next_state   = state;
        tx_done_tick = 1'b0;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;
        tx_next      = tx_reg;

        case (state)
            IDLE: begin
                tx_next = 1'b1;              
                if (tx_start) begin
                    next_state = START;
                    s_next     = 0;
                    b_next     = din;       
                end
            end

            START: begin
                tx_next = 1'b0;              
                if (s_tick) begin
                    if (s_reg == 15) begin
                        next_state = DATA;
                        s_next     = 0;
                        n_next     = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0];          
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1;  
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
                tx_next = 1'b1;              
                if (s_tick) begin
                    if (s_reg == (SB_TICK-1)) begin
                        next_state   = IDLE;
                        tx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            default: next_state = IDLE;
        endcase
    end

    assign tx = tx_reg;

endmodule
