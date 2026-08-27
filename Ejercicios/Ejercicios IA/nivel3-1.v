module level3_1(
    input wire [1:0] a, b,
    output wire aeqb
);

wire e_l;
assign e_l = ~a[0] & ~b[0];
wire e_h;
assign e_h = a[0] & b[0];
wire r_h;
assign r_h = a[1] & b[1];
wire r_l;
assign r_l = ~a[1] & ~b[1];

wire bit0_ok;
assign bit0_ok = e_l | e_h;
wire bit1_ok;
assign bit1_ok = r_l | r_h;
assign aeqb = bit0_ok & bit1_ok;

endmodule
