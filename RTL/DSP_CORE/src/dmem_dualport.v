module dmem_dualport (
    input clk,
    input [9:0] addr_a,
    input [31:0] wdata_a,
    input we_a,
    input [9:0] addr_b,
    input [31:0] wdata_b,
    input we_b,
    output reg [31:0] rdata_b,
    output reg [31:0] rdata_a
);
    reg [31:0] mem [0:1023];
    always @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= wdata_a;
        rdata_a <= mem[addr_a];
    end
    always @(posedge clk) begin
        if (we_b)
            mem[addr_b] <= wdata_b;
        rdata_b <= mem[addr_b];
    end
    initial begin
        $readmemh("dmem_init.mem", mem);
    end
endmodule