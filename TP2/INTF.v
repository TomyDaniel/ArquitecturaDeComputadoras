module interface_circuit
#(
    parameter D_BIT = 8
)
(
    input  wire clk,
    input  wire reset,

    // Lado Rx
    input  wire [D_BIT-1:0] rx_data,     // d_out del módulo Rx
    input  wire rx_done_tick,            // "llegó un byte nuevo"
    input  wire rd,                      // la ALU pide leer
    output reg  rx_empty,                // no hay dato nuevo para leer
    output reg  [D_BIT-1:0] r_data,      // el byte que la ALU va a leer

    // Lado Tx
    input  wire wr,                      // la ALU pide escribir/transmitir
    input  wire [D_BIT-1:0] w_data,      // el byte que la ALU quiere mandar
    input  wire tx_done_tick,            // el Tx terminó de mandar el byte
    output reg  tx_full,                 // el Tx está ocupado, no acepta otro byte
    output reg  [D_BIT-1:0] tx_data,     // d_in del módulo Tx
    output reg  tx_start                 // pulso: arrancá a transmitir
);

    // Lado recepción
    always @(posedge clk) begin
        if (reset) begin
            rx_empty <= 1'b1;
            r_data   <= {D_BIT{1'b0}};
        end else if (rx_done_tick) begin
            // llegó un byte nuevo del Rx: lo guardo y aviso que hay dato
            r_data   <= rx_data;
            rx_empty <= 1'b0;
        end else if (rd && ~rx_empty) begin
            // la ALU leyó el dato: lo marco como consumido
            rx_empty <= 1'b1;
        end
    end

    // Lado transmisión
    always @(posedge clk) begin
        tx_start <= 1'b0;   // por defecto, sin pulso

        if (reset) begin
            tx_full  <= 1'b0;
        end else if (wr && ~tx_full) begin
            // la ALU quiere transmitir y el Tx está libre: cargo el byte
            tx_data  <= w_data;
            tx_full  <= 1'b1;
            tx_start <= 1'b1;   // le aviso al Tx que arranque
        end else if (tx_done_tick) begin
            // el Tx terminó: vuelvo a estar libre
            tx_full  <= 1'b0;
        end
    end

endmodule