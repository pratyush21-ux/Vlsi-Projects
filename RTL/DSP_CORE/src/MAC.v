module MAC(
    input clk,
    input signed [31:0] a,
    input signed [31:0] b,
    input signed [63:0] prev_input,
    output reg signed [63:0] Mac_out
);
    always @(posedge clk) begin
        Mac_out <= (a * b) + prev_input;
    end
endmodule
