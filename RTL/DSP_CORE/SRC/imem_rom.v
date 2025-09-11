// imem_rom.v
module imem_rom #(
    parameter AW = 16,
    parameter DW = 16,
    parameter MEMFILE = "program.mem"
)(
    input  wire [AW-1:0] addr,
    output reg  [DW-1:0] dout
);

    reg [DW-1:0] mem [0:(1<<AW)-1];

    initial begin
        $readmemh(MEMFILE, mem);
    end

    always @(*) begin
        dout = mem[addr];
    end

endmodule
