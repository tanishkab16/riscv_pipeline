// Code your testbench here
// or browse Examples
// tb/ex_mem_reg_tb.v
// Testbench for EX/MEM Pipeline Register

`timescale 1ns/1ns

module ex_mem_reg_tb;

    // --- Testbench Signals ---
    reg         clk;
    reg         rst_n;
    reg         flush_i;

    reg [31:0] ex_pc_plus_4_i;
    reg [31:0] ex_alu_result_i;
    reg [31:0] ex_read_data2_i;
    reg [4:0]  ex_rd_addr_i;

    reg        ex_reg_write_en_i;
    reg [1:0]  ex_mem_to_reg_i;
    reg        ex_mem_read_en_i;
    reg        ex_mem_write_en_i;
    reg [1:0]  ex_pc_src_i;
    reg        ex_jump_i;
    reg        ex_branch_i;
    reg        ex_alu_zero_i;

    wire [31:0] mem_pc_plus_4_o;
    wire [31:0] mem_alu_result_o;
    wire [31:0] mem_read_data2_o;
    wire [4:0]  mem_rd_addr_o;
    wire        mem_reg_write_en_o;
    wire [1:0]  mem_mem_to_reg_o;
    wire        mem_mem_read_en_o;
    wire        mem_mem_write_en_o;
    wire [1:0]  mem_pc_src_o;
    wire        mem_jump_o;
    wire        mem_branch_o;
    wire        mem_alu_zero_o;


    // --- Instantiate the Device Under Test (DUT) ---
    ex_mem_reg DUT (
        .clk                 (clk),
        .rst_n               (rst_n),
        .flush_i             (flush_i),

        .ex_pc_plus_4_i      (ex_pc_plus_4_i),
        .ex_alu_result_i     (ex_alu_result_i),
        .ex_read_data2_i     (ex_read_data2_i),
        .ex_rd_addr_i        (ex_rd_addr_i),

        .ex_reg_write_en_i   (ex_reg_write_en_i),
        .ex_mem_to_reg_i     (ex_mem_to_reg_i),
        .ex_mem_read_en_i    (ex_mem_read_en_i),
        .ex_mem_write_en_i   (ex_mem_write_en_i),
        .ex_pc_src_i         (ex_pc_src_i),
        .ex_jump_i           (ex_jump_i),
        .ex_branch_i         (ex_branch_i),
        .ex_alu_zero_i       (ex_alu_zero_i),

        .mem_pc_plus_4_o     (mem_pc_plus_4_o),
        .mem_alu_result_o    (mem_alu_result_o),
        .mem_read_data2_o    (mem_read_data2_o),
        .mem_rd_addr_o       (mem_rd_addr_o),
        .mem_reg_write_en_o  (mem_reg_write_en_o),
        .mem_mem_to_reg_o    (mem_mem_to_reg_o),
        .mem_mem_read_en_o   (mem_mem_read_en_o),
        .mem_mem_write_en_o  (mem_mem_write_en_o),
        .mem_pc_src_o        (mem_pc_src_o),
        .mem_jump_o          (mem_jump_o),
        .mem_branch_o        (mem_branch_o),
        .mem_alu_zero_o      (mem_alu_zero_o)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/ex_mem_reg_tb.vcd");
        $dumpvars(0, ex_mem_reg_tb);

        // Initialize all inputs to 0 / sane defaults
        clk = 0; rst_n = 0; flush_i = 0;
        ex_pc_plus_4_i = 32'h0; ex_alu_result_i = 32'h0; ex_read_data2_i = 32'h0; ex_rd_addr_i = 5'h0;
        ex_reg_write_en_i = 1'b0; ex_mem_to_reg_i = 2'b0; ex_mem_read_en_i = 1'b0;
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b0; ex_jump_i = 1'b0; ex_branch_i = 1'b0; ex_alu_zero_i = 1'b0;

        // --- Test Sequence ---

        // 1. Apply reset
        #10 rst_n = 1; // De-assert reset
        $display("--- %0t: Test Reset ---", $time);
        $fflush();
      // Expected: All outputs should be 0

        // 2. Normal pipeline progression (e.g., ADDI x2, x1, 5)
        ex_pc_plus_4_i = 32'h00000008;
        ex_alu_result_i = 32'h0000000F; // ALU result (15)
        ex_read_data2_i = 32'h0000000F; // x2 value (irrelevant for ADDI)
        ex_rd_addr_i = 5'h2; // rd = x2
        ex_reg_write_en_i = 1'b1; ex_mem_to_reg_i = 2'b0; ex_mem_read_en_i = 1'b0; // MemToReg=ALU_Result
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b0; ex_jump_i = 1'b0; ex_branch_i = 1'b0; ex_alu_zero_i = 1'b0;

        #10; // Wait for clock edge
        $display("--- %0t: Test Normal Progression (ADDI) ---", $time);
        $fflush();
        // Expected: All outputs should match inputs

        // 3. Test Store instruction (SW x4, 0(x0))
        ex_pc_plus_4_i = 32'h00000014;
        ex_alu_result_i = 32'h00000000; // Effective address 0
        ex_read_data2_i = 32'h00000014; // Data to store (20)
        ex_rd_addr_i = 5'h0; // rd = x0 (irrelevant for SW)
        ex_reg_write_en_i = 1'b0; ex_mem_to_reg_i = 2'b0; ex_mem_read_en_i = 1'b0;
        ex_mem_write_en_i = 1'b1; ex_pc_src_i = 2'b0; ex_jump_i = 1'b0; ex_branch_i = 1'b0; ex_alu_zero_i = 1'b0;

        #10; // Wait for clock edge
        $display("--- %0t: Test Store (SW) ---", $time);
        $fflush();
        // Expected: mem_mem_write_en_o = 1, other controls as 0, data passed

        // 4. Test Load instruction (LW x5, 0(x0))
        ex_pc_plus_4_i = 32'h00000018;
        ex_alu_result_i = 32'h00000000; // Effective address 0
        ex_read_data2_i = 32'h0; // Irrelevant for LW
        ex_rd_addr_i = 5'h5; // rd = x5
        ex_reg_write_en_i = 1'b1; ex_mem_to_reg_i = 2'b1; ex_mem_read_en_i = 1'b1; // MemToReg=MEM_DATA
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b0; ex_jump_i = 1'b0; ex_branch_i = 1'b0; ex_alu_zero_i = 1'b0;

        #10; // Wait for clock edge
        $display("--- %0t: Test Load (LW) ---", $time);
        $fflush();
        // Expected: mem_mem_read_en_o = 1, mem_reg_write_en_o = 1, mem_mem_to_reg_o = MEM_DATA

        // 5. Test Branch instruction (BEQ x5, x0, 8) - Branch NOT taken
        ex_pc_plus_4_i = 32'h00000020;
        ex_alu_result_i = 32'h00000014; // x5-x0 = 20-0 = 20 (not zero)
        ex_read_data2_i = 32'h0; // Irrelevant for branch
        ex_rd_addr_i = 5'h0; // Irrelevant for branch
        ex_reg_write_en_i = 1'b0; ex_mem_to_reg_i = 2'b0; ex_mem_read_en_i = 1'b0;
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b1; ex_jump_i = 1'b0; ex_branch_i = 1'b1; ex_alu_zero_i = 1'b0; // Branch not taken

        #10; // Wait for clock edge
        $display("--- %0t: Test Branch (Not Taken) ---", $time);
        $fflush();
        // Expected: mem_branch_o=1, mem_alu_zero_o=0 (still 0), pc_src=BRANCH (passed through)

        // 6. Test Branch instruction (BEQ x5, x0, 8) - Branch TAKEN (forcing alu_zero=1)
        ex_pc_plus_4_i = 32'h00000020; // Same PC+4
        ex_alu_result_i = 32'h00000000; // Forcing ALU result to be 0 for Branch Taken (x5-x5=0)
        ex_read_data2_i = 32'h0;
        ex_rd_addr_i = 5'h0;
        ex_reg_write_en_i = 1'b0; ex_mem_to_reg_i = 2'b0; ex_mem_read_en_i = 1'b0;
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b1; ex_jump_i = 1'b0; ex_branch_i = 1'b1; ex_alu_zero_i = 1'b1; // Branch taken
        #10; // Wait for clock edge
        $display("--- %0t: Test Branch (Taken) ---", $time);
        $fflush();
        // Expected: mem_branch_o=1, mem_alu_zero_o=1, pc_src=BRANCH (passed through)

        // 7. Test JAL instruction (JAL x0, 8)
        ex_pc_plus_4_i = 32'h0000002C; // PC+4 for JAL
        ex_alu_result_i = 32'h0000002C; // ALU_ADD (PC + 4) result, or any pass-through
        ex_read_data2_i = 32'h0;
        ex_rd_addr_i = 5'h0; // rd = x0
        ex_reg_write_en_i = 1'b1; ex_mem_to_reg_i = 2'b10; ex_mem_read_en_i = 1'b0; // MemToReg=PC+4
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b10; ex_jump_i = 1'b1; ex_branch_i = 1'b0; ex_alu_zero_i = 1'b0;

        #10; // Wait for clock edge
        $display("--- %0t: Test JAL ---", $time);
        $fflush();
        // Expected: mem_jump_o=1, mem_pc_src_o=JUMP, mem_mem_to_reg_o=PC+4

        // 8. Test Flush (flush_i = 1)
        flush_i = 1;
        // Inputs irrelevant, outputs should be NOP/cleared state
        ex_pc_plus_4_i = 32'hEEEEEEEE; ex_alu_result_i = 32'hFFFFFFFF; ex_read_data2_i = 32'hAAAAAAAA; ex_rd_addr_i = 5'hD;
        ex_reg_write_en_i = 1'b1; ex_mem_to_reg_i = 2'b1; ex_mem_read_en_i = 1'b1;
        ex_mem_write_en_i = 1'b1; ex_pc_src_i = 2'b1; ex_jump_i = 1'b1; ex_branch_i = 1'b1; ex_alu_zero_i = 1'b1;
        #10; // Wait for clock edge
        $display("--- %0t: Test Flush ---", $time);
        $fflush();
        // Expected: All data outputs should be 0s, control signals 0s

        // 9. De-flush
        flush_i = 0;
        // Inputs change, outputs should update
        ex_pc_plus_4_i = 32'hDDDDDDDD; ex_alu_result_i = 32'hDDDDDDDD; ex_read_data2_i = 32'hDDDDDDDD; ex_rd_addr_i = 5'hC;
        ex_reg_write_en_i = 1'b0; ex_mem_to_reg_i = 2'b0; ex_mem_read_en_i = 1'b0;
        ex_mem_write_en_i = 1'b0; ex_pc_src_i = 2'b0; ex_jump_i = 1'b0; ex_branch_i = 1'b0; ex_alu_zero_i = 1'b0;
        #10; // Wait for clock edge
        $display("--- %0t: Test De-Flush Propagation ---", $time);
        $fflush();
        // Expected: Outputs should update to current inputs

        #20 $finish; // End simulation
    end

endmodule