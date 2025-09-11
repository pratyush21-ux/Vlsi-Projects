// tb_simple_dsp_core.v
`timescale 1ns/1ps

module tb_simple_dsp_core;

    reg clk, rst, start;
    wire done;
    wire [15:0] pc_out;
    wire [31:0] acc_out, alu_result;
    wire [9:0] mem_addr;

    // Instantiate DSP core
    dsp_core dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .pc_out(pc_out),
        .acc_out(acc_out),
        .alu_result(alu_result),
        .mem_addr(mem_addr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main test sequence
    initial begin
        $display("=== Starting Enhanced DSP Core Test ===");

        rst = 1; start = 0;
        #100;
        rst = 0;
        $display("Reset released at time %0t", $time);

        #20;
        start = 1;
        $display("Start signal asserted at time %0t", $time);
        #10;
        start = 0;
        $display("Program execution started...");

        // Wait for completion (use your wait task)
        wait_for_completion(1000);

        // Check results
        $display("\n=== Final Results ===");
        $display("Final PC: %h", pc_out);
        $display("Final ACC: %d", acc_out);

        if (acc_out == 30) begin
            $display("✅ PERFECT: Got expected FIR result (ACC = 30)");
        end else if (acc_out > 0) begin
            $display("⚠️  PARTIAL: MAC working but result = %d (expected 30)", acc_out);
        end else begin
            $display("❌ FAIL: Accumulator remained zero");
        end

        // Check memory result (access internal memory for test verification)
        $display("Memory[100] = %d", dut.dmem.mem[100]);

        $finish;
    end

    // Enhanced monitoring
    always @(posedge clk) begin
        if (!rst && !done) begin
            // Show detailed MAC operations
            if (dut.mac_en) begin
                $display("[%0t] MAC: %d * %d -> ACC will be %d",
                        $time, dut.rdata_a[15:0], dut.rdata_b[15:0],
                        dut.mac_acc_out + (dut.rdata_a[15:0] * dut.rdata_b[15:0]));
            end

            // Show register writes
            if (dut.reg_we) begin
                $display("[%0t] REG_WRITE: R%d <= %d", $time, dut.rd, dut.wdata);
            end

            // Show memory operations
            if (dut.load_mem) begin
                $display("[%0t] LOAD_MEM: addr=%h -> data=%d", $time, dut.dmem_addr_a, dut.dmem_rdata_a);
            end
        end
    end

    task wait_for_completion;
        input integer max_cycles;
        integer cycle;
        begin
            cycle = 0;
            while(!done && cycle < max_cycles) begin
                @(posedge clk);
                if (cycle % 20 == 0) begin
                    $display("[Cycle %3d] PC=%h | ACC=%d | R1=%d | R2=%d | R5=%d | R6=%d",
                            cycle, pc_out, acc_out,
                            dut.rf.regs[1], dut.rf.regs[2], dut.rf.regs[5], dut.rf.regs[6]);
                end
                cycle = cycle + 1;
            end

            if (!done) begin
                $display("❌ TIMEOUT after %0d cycles", max_cycles);
            end else begin
                $display("✅ Execution completed at cycle %0d", cycle);
            end
        end
    endtask

endmodule
