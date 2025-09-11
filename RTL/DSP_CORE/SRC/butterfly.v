// butterfly.v
module butterfly (
    input signed [15:0] ar, ai, br, bi,
    input signed [15:0] wr, wi,
    output signed [31:0] out0r, out0i, out1r, out1i
);
    // Complex multiply: b * W = (br + j*bi) * (wr + j*wi)
    wire signed [31:0] bwr = br * wr;
    wire signed [31:0] bwi = bi * wi;
    wire signed [31:0] bri = br * wi;
    wire signed [31:0] biw = bi * wr;

    wire signed [31:0] b_mult_w_real = bwr - bwi;
    wire signed [31:0] b_mult_w_imag = bri + biw;

    // Butterfly outputs (wider to hold sums)
    assign out0r = ar + b_mult_w_real;
    assign out0i = ai + b_mult_w_imag;
    assign out1r = ar - b_mult_w_real;
    assign out1i = ai - b_mult_w_imag;
endmodule
