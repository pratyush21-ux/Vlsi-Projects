// reg_file.v
module reg_file (
    input clk,
    input we,
    input [3:0] ra,
    input [3:0] rb,
    input [3:0] rw,
    input [31:0] wdata,
    output [31:0] rdata_a,
    output [31:0] rdata_b
);
    reg [31:0] regs [0:15];
    integer i;

    assign rdata_a = (ra == 4'b0) ? 32'b0 : regs[ra];
    assign rdata_b = (rb == 4'b0) ? 32'b0 : regs[rb];

    always @(posedge clk) begin
        if (we && rw != 4'b0)
            regs[rw] <= wdata;
    end

    initial begin
        for (i = 0; i < 16; i = i + 1)
            regs[i] = 32'b0;
    end
endmodule
