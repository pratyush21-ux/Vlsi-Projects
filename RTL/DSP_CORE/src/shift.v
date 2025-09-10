module shift(
    input [31:0]A,
    input con,
    input [4:0]unit,
    output reg [31:0]result
);
always @(*)
begin
    case(con)
    1'b0:result=A<<unit;
    1'b1:result=A>>unit;
    defult:result=A;
endcase
end
endmodule

