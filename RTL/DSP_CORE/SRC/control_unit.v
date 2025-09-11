// control_unit.v
module control_unit (
    input clk,
    input rst,
    input [15:0] instr,
    input start,
    output reg [15:0] pc,
    output reg [3:0] alu_op,
    output reg mem_we_a,
    output reg mem_we_b,
    output reg mac_en,
    output reg [3:0] rd,
    output reg [3:0] rs,
    output reg [3:0] rt,
    output reg [15:0] imm,
    output reg reg_we,
    output reg load_imm,
    output reg load_mem,
    output reg done
);
    localparam NOP  = 4'h0,
               LOAD = 4'h1,
               STORE= 4'h2,
               ADD  = 4'h3,
               SUB  = 4'h4,
               MAC  = 4'h5,
               SHIFT= 4'h6,
               JMP  = 4'h7,
               BEQ  = 4'h8,
               HALT = 4'hF;

    wire [3:0] opcode = instr[15:12];
    reg [2:0] state;
    localparam IDLE = 3'h0, FETCH = 3'h1, DECODE = 3'h2,
               EXECUTE = 3'h3, WRITEBACK = 3'h4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 16'b0;
            state <= IDLE;
            done <= 1'b0;
            alu_op <= 4'b0;
            mem_we_a <= 1'b0;
            mem_we_b <= 1'b0;
            mac_en <= 1'b0;
            reg_we <= 1'b0;
            load_imm <= 1'b0;
            load_mem <= 1'b0;
            rd <= 4'b0; rs <= 4'b0; rt <= 4'b0; imm <= 16'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= FETCH;
                        done <= 1'b0;
                    end
                end

                FETCH: begin
                    state <= DECODE;
                end

                DECODE: begin
                    rd <= instr[11:8];
                    rs <= instr[7:4];
                    rt <= instr[3:0];
                    // sign-extend 4-bit immediate to 16-bit (if needed); original used zero-extend
                    imm <= {12'b0, instr[3:0]};
                    state <= EXECUTE;
                end

                EXECUTE: begin
                    // clear
                    reg_we <= 1'b0;
                    mac_en <= 1'b0;
                    mem_we_a <= 1'b0;
                    mem_we_b <= 1'b0;
                    load_imm <= 1'b0;
                    load_mem <= 1'b0;
                    alu_op <= 4'h0;

                    case (opcode)
                        NOP: begin
                            pc <= pc + 1;
                            state <= FETCH;
                        end

                        LOAD: begin
                            if (rs == 4'b0) begin
                                // LOAD Rd, #imm
                                load_imm <= 1'b1;
                                reg_we <= 1'b1;
                            end else begin
                                // LOAD Rd, [Rs + offset]
                                load_mem <= 1'b1;
                                reg_we <= 1'b1;
                            end
                            pc <= pc + 1;
                            state <= WRITEBACK;
                        end

                        STORE: begin
                            mem_we_a <= 1'b1;
                            pc <= pc + 1;
                            state <= WRITEBACK;
                        end

                        ADD: begin
                            alu_op <= 4'h0; // map to ADD in ALU
                            reg_we <= 1'b1;
                            pc <= pc + 1;
                            state <= WRITEBACK;
                        end

                        SUB: begin
                            alu_op <= 4'h1;
                            reg_we <= 1'b1;
                            pc <= pc + 1;
                            state <= WRITEBACK;
                        end

                        MAC: begin
                            mac_en <= 1'b1;
                            reg_we <= 1'b1;
                            pc <= pc + 1;
                            state <= WRITEBACK;
                        end

                        JMP: begin
                            pc <= {12'b0, instr[3:0]};
                            state <= FETCH;
                        end

                        BEQ: begin
                            // branch if rs == 0 (this control unit uses register index value check; actual datapath must compare regs)
                            if (rs == 4'b0)
                                pc <= {12'b0, instr[3:0]};
                            else
                                pc <= pc + 1;
                            state <= FETCH;
                        end

                        HALT: begin
                            done <= 1'b1;
                            state <= IDLE;
                        end

                        default: begin
                            pc <= pc + 1;
                            state <= FETCH;
                        end
                    endcase
                end

                WRITEBACK: begin
                    // lower control signals after writeback
                    reg_we <= 1'b0;
                    mac_en <= 1'b0;
                    mem_we_a <= 1'b0;
                    mem_we_b <= 1'b0;
                    load_imm <= 1'b0;
                    load_mem <= 1'b0;
                    state <= FETCH;
                end
            endcase
        end
    end
endmodule
