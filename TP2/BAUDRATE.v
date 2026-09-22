module baud_rate_gen
#(
    parameter DVSR = 163   // divisor: Clock / (BaudRate * 16)
)
(
    input  wire clk,
    output reg  tick
);

    reg [$clog2(DVSR)-1:0] count;

    always @(posedge clk) begin
        if (count == DVSR-1) begin
            count <= 0;
            tick  <= 1'b1;
        end else begin
            count <= count + 1;
            tick  <= 1'b0;
        end
    end

endmodule
