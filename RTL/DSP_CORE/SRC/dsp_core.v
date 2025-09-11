// dsp_core.v
module dsp_core (
    input clk,
    input rst,
    input start,
    output done,
    output [15:0] pc_out,
    output [31:0] acc_out,
    output [31:0] alu_result,
    output [9:0] mem_addr
);
    // Internal signals (wires driven by submodules)
    wire [15:0] pc;
    wire [15:0] instr;
    wire [3:0] alu_op;
    wire mem_we_a, mem_we_b, mac_en, reg_we;
    wire load_imm, load_mem;
    wire [3:0] rd, rs, rt;
    wire [15:0] imm;
    wire [31:0] rdata_a, rdata_b, wdata;
    wire [31:0] dmem_rdata_a, dmem_rdata_b;
    wire [9:0] dmem_addr_a, dmem_addr_b;
    wire [31:0] dmem_wdata_a, dmem_wdata_b;
    wire [31:0] mac_acc_in, mac_acc_out;
    wire zero, negative, overflow, carry;

    assign pc_out = pc;
    assign acc_out = mac_acc_out;
    assign mem_addr = dmem_addr_a;

    // Instruction Memory ROM (synchronous read via combinational dout)
    imem_rom imem (
        .addr(pc),
        .dout(instr)
    );

    // Control Unit
    control_unit ctrl (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .start(start),
        .pc(pc),
        .alu_op(alu_op),
        .mem_we_a(mem_we_a),
        .mem_we_b(mem_we_b),
        .mac_en(mac_en),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .imm(imm),
        .reg_we(reg_we),
        .load_imm(load_imm),
        .load_mem(load_mem),
        .done(done)
    );

    // Register File
    reg_file rf (
        .clk(clk),
        .we(reg_we),
        .ra(rs),
        .rb(rt),
        .rw(rd),
        .wdata(wdata),
        .rdata_a(rdata_a),
        .rdata_b(rdata_b)
    );

    // ALU + Shifter
    alu_shifter alu (
        .opcode(alu_op),
        .op1(rdata_a),
        .op2(rdata_b),
        .sh_amount(imm[4:0]),
        .result(alu_result),
        .zero(zero),
        .negative(negative),
        .overflow(overflow),
        .carry(carry)
    );

    // MAC Unit
    MAC mac_unit (
        .clk(clk),
        .rst(rst),
        .a(rdata_a[15:0]),
        .b(rdata_b[15:0]),
        .acc_in(mac_acc_in),
        .en(mac_en),
        .acc_out(mac_acc_out)
    );

    // Butterfly (example connection)
    wire [31:0] butterfly_out0r, butterfly_out0i, butterfly_out1r, butterfly_out1i;
    butterfly butterfly_unit (
        .ar(rdata_a[15:0]),
        .ai(rdata_b[15:0]),
        .br(dmem_rdata_a[15:0]),
        .bi(dmem_rdata_b[15:0]),
        .wr(16'h4000),
        .wi(16'h0000),
        .out0r(butterfly_out0r),
        .out0i(butterfly_out0i),
        .out1r(butterfly_out1r),
        .out1i(butterfly_out1i)
    );

    // Saturate & QFormat connections (optional)
    wire [31:0] saturated_out;
    saturate saturate_unit (
        .data_in(mac_acc_out),
        .sat_max(32'h7FFFFFFF),
        .sat_min(32'h80000000),
        .data_out(saturated_out)
    );

    wire [31:0] qformat_out;
    qformat qformat_unit (
        .a(rdata_a[15:0]),
        .b(rdata_b[15:0]),
        .q_shift(imm[3:0]),
        .result(qformat_out)
    );

    // Data Memory (dual-port)
    dmem_dualport dmem (
        .clk(clk),
        .addr_a(dmem_addr_a),
        .wdata_a(dmem_wdata_a),
        .we_a(mem_we_a),
        .rdata_a(dmem_rdata_a),
        .addr_b(dmem_addr_b),
        .wdata_b(dmem_wdata_b),
        .we_b(mem_we_b),
        .rdata_b(dmem_rdata_b)
    );

    // Datapath: decide writeback data (priority)
    assign wdata = load_imm ? {16'b0, imm} :
                   load_mem ? dmem_rdata_a :
                   mac_en   ? mac_acc_out :
                   alu_result;

    // MAC feedback (accumulator input) - keep previous accumulator as base
    assign mac_acc_in = mac_acc_out;

    // Memory addressing: use Ra/reg and imm offset if requested
    assign dmem_addr_a = (load_mem || mem_we_a) ? (rdata_a[9:0] + imm[9:0]) : rdata_a[9:0];
    assign dmem_addr_b = rdata_b[9:0];

    // Memory write data (store uses rdata_b)
    assign dmem_wdata_a = rdata_b;
    assign dmem_wdata_b = rdata_b;

endmodule
