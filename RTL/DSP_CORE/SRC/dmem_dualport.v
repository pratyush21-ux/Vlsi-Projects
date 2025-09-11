// dmem_dualport.v
module dmem_dualport (
    input clk,

    // Port A
    input  [9:0] addr_a,
    input  [31:0] wdata_a,
    input  we_a,
    output [31:0] rdata_a,

    // Port B
    input  [9:0] addr_b,
    input  [31:0] wdata_b,
    input  we_b,
    output [31:0] rdata_b
);
    reg [31:0] mem [0:1023];

    // synchronous write
    always @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= wdata_a;
        if (we_b)
            mem[addr_b] <= wdata_b;
    end

    // combinational read
    assign rdata_a = mem[addr_a];
    assign rdata_b = mem[addr_b];

    initial begin
        $readmemh("dmem_init.mem", mem);
    end
endmodule
