
module Data_mem(
    input  wire clk,
    input  wire  WE,        
    input  wire [31:0] A,         
    input  wire [31:0] WD,        
    output reg  [31:0] RD         
);
    reg [31:0] mem [0:63];        
    always @(posedge clk) begin
        if (WE)
            mem[A[31:2]] <= WD;   
        RD <= mem[A[31:2]];     
    end
    // initial begin
    //     $readmemh("data.mem", mem);
    // end
endmodule
