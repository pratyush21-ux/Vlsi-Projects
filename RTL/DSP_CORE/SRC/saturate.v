// saturate.v
module saturate (
    input signed [31:0] data_in,
    input signed [31:0] sat_max,
    input signed [31:0] sat_min,
    output signed [31:0] data_out
);
    assign data_out = (data_in > sat_max) ? sat_max :
                      (data_in < sat_min) ? sat_min : data_in;
endmodule
// qformat.v
module qformat (
    input signed [15:0] a,
    input signed [15:0] b,
    input [3:0] q_shift,
    output signed [31:0] result
);
    wire signed [31:0] mult_result = a * b;
    assign result = mult_result >>> q_shift; // arithmetic shift for signed result
endmodule
