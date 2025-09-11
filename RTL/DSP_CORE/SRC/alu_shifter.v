// alu_shifter.v
module alu_shifter (
    input  [3:0] opcode,
    input  signed [31:0] op1,
    input  signed [31:0] op2,
    input  [4:0] sh_amount,
    output reg signed [31:0] result,
    output reg zero,
    output reg negative,
    output reg overflow,
    output reg carry
);
    localparam ADD = 4'h0, SUB = 4'h1, AND = 4'h2, OR = 4'h3,
               XOR = 4'h4, ROL = 4'h5, ROR = 4'h6, SHL = 4'h7, SHR = 4'h8;

    // Unsigned copy for shifts/rotates
    wire [31:0] uop1 = op1;

    // TEMPORARY variables must be declared here
    reg [31:0] rot;
    reg signed [32:0] sum;
    reg signed [32:0] diff;

    always @(*) begin
        // defaults
        carry    = 1'b0;
        overflow = 1'b0;
        result   = 32'b0;

        case (opcode)
            ADD: begin
                sum = {op1[31], op1} + {op2[31], op2};
                carry    = sum[32];
                result   = sum[31:0];
                overflow = (op1[31] == op2[31]) && (result[31] != op1[31]);
            end

            SUB: begin
                diff     = {op1[31], op1} - {op2[31], op2};
                carry    = diff[32]; // borrow as carry
                result   = diff[31:0];
                overflow = (op1[31] != op2[31]) && (result[31] != op1[31]);
            end

            AND: result = op1 & op2;
            OR:  result = op1 | op2;
            XOR: result = op1 ^ op2;

            ROL: begin
                if (sh_amount == 0)
                    rot = uop1;
                else
                    rot = (uop1 << sh_amount) | (uop1 >> (32 - sh_amount));
                result = $signed(rot);
            end

            ROR: begin
                if (sh_amount == 0)
                    rot = uop1;
                else
                    rot = (uop1 >> sh_amount) | (uop1 << (32 - sh_amount));
                result = $signed(rot);
            end

            SHL: result = $signed(uop1 << sh_amount);
            SHR: result = op1 >>> sh_amount; // arithmetic right shift

            default: result = 32'b0;
        endcase

        zero     = (result == 32'b0);
        negative = result[31];
    end
endmodule
