module Instruction_Memory(
    input [31:0]address,
    input [31:0]data
);
reg [31:0]mem[0:255];
initial
begin
end 
assign data=mem[address[31:2]];
endmodule