module imem_rom (
    input clk,
    input [15:0] pc,
    output reg [15:0] instr
);
    reg [15:0] mem [0:65535];
    always @(posedge clk) begin
        instr <= mem[pc];
    end
    initial begin
        $readmemh("program.mem", mem);
    end
endmodule