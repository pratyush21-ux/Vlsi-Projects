module dmem_dualport #(
    parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=10,
    parameter DEPTH=1<<ADDR_WIDTH
)
(
    input wire clk,
    //port A
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire we_a,
    input wire [DATA_WIDTH-1:0]wdata_a,
    output wire [DATA_WIDTH-1:0]rdata_a,
    //port B
    input wire [ADDR_WIDTH-1:0]addr_b,
    input wire we_b,
    input wire [DATA_WIDTH-1:0]wdata_b,
    output reg [DATA_WIDTH-1:0]rdata_b
);
reg [DATA_WIDTH-1:0]mem[0:DEPTH-1];
always @(posedge clk)
begin
    if(we_a)
    begin
        mem[addr_a]<=wdata_a;
    end
    rdata_a<=mem[add_a];
end
always @(posedge clk)
begin
    if(we_b)
    begin
        mem[addr_b]<=wdata_b;
    end 
    rdata_b<=mem[addr_b];
end 
endmodule
