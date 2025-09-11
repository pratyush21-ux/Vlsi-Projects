// MAC.v
module MAC (
    input clk,
    input rst,
    input signed [15:0] a,
    input signed [15:0] b,
    input signed [31:0] acc_in,
    input en,
    output reg signed [31:0] acc_out
);
    wire signed [31:0] mult_result = a * b;
    wire signed [31:0] add_result = acc_in + mult_result;

    always @(posedge clk or posedge rst) begin
        if (rst)
            acc_out <= 32'b0;
        else if (en)
            acc_out <= add_result;
        // hold value when en==0
    end
endmodule
