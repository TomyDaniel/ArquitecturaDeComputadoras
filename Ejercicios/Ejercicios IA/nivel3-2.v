module level3_2(
    input wire [1:0] a, b,
    output wire aeqb
);

wire e_l;
assign e_l = ~a[0] & ~b[0];
wire e_h;
assign e_h = a[1] & b[1];