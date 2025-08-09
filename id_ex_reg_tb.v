// tb/id_ex_reg_tb.v
// Testbench for ID/EX Pipeline Register - COMPLETE VERSION with FLUSHING

`timescale 1ns/1ns

module id_ex_reg_tb;

    // --- Testbench Signals ---
    reg         clk;
    reg         rst_n;
    reg         flush_i;
    reg         stall_i;

    reg [31:0] id_pc_plus_4_i;
    reg [31:0] id_read_data1_i;
    reg [31:0] id_read_data2_i;
    reg [31:0] id_immediate_i;
    reg [4:0]  id_rs1_addr_i;
    reg [4:0]  id_rs2_addr_i;
    reg [4:0]  id_rd_addr_i;
    reg        id_reg_write_en_i;
    reg [1:0]  id_mem_to_reg_i;
    reg        id_mem_read_en_i;
    reg        id_mem_write_en_i;
    reg [1:0]  id_alu_src_b_i;
    reg [3:0]  id_alu_op_i;
    reg [1:0]  id_pc_src_i;
    reg        id_branch_i;
    reg        id_jump_i;
    reg [31:0] id_pc_current_i;

    wire [31:0] ex_pc_plus_4_o;
    wire [31:0] ex_read_data1_o;
    wire [31:0] ex_read_data2_o;
    wire [31:0] ex_immediate_o;
    wire [4:0]  ex_rs1_addr_o;
    wire [4:0]  ex_rs2_addr_o;
    wire [4:0]  ex_rd_addr_o;
    wire        ex_reg_write_en_o;
    wire [1:0]  ex_mem_to_reg_o;
    wire        ex_mem_read_en_o;
    wire        ex_mem_write_en_o;
    wire [1:0]  ex_alu_src_b_o;
    wire [3:0]  ex_alu_op_o;
    wire [1:0]  ex_pc_src_o;
    wire        ex_branch_o;
    wire        ex_jump_o;
    wire [31:0] ex_pc_current_o;


    // --- Instantiate the Device Under Test (DUT) ---
    id_ex_reg DUT (
        .clk                 (clk),
        .rst_n               (rst_n),
        .flush_i             (flush_i),
        .stall_i             (stall_i),
        .id_pc_plus_4_i      (id_pc_plus_4_i),
        .id_read_data1_i     (id_read_data1_i),
        .id_read_data2_i     (id_read_data2_i),
        .id_immediate_i      (id_immediate_i),
        .id_rs1_addr_i       (id_rs1_addr_i),
        .id_rs2_addr_i       (id_rs2_addr_i),
        .id_rd_addr_i        (id_rd_addr_i),
        .id_reg_write_en_i   (id_reg_write_en_i),
        .id_mem_to_reg_i     (id_mem_to_reg_i),
        .id_mem_read_en_i    (id_mem_read_en_i),
        .id_mem_write_en_i   (id_mem_write_en_i),
        .id_alu_src_b_i      (id_alu_src_b_i),
        .id_alu_op_i         (id_alu_op_i),
        .id_pc_src_i         (id_pc_src_i),
        .id_branch_i         (id_branch_i),
        .id_jump_i           (id_jump_i),
        .id_pc_current_i     (id_pc_current_i),

        .ex_pc_plus_4_o      (ex_pc_plus_4_o),
        .ex_read_data1_o     (ex_read_data1_o),
        .ex_read_data2_o     (ex_read_data2_o),
        .ex_immediate_o      (ex_immediate_o),
        .ex_rs1_addr_o       (ex_rs1_addr_o),
        .ex_rs2_addr_o       (ex_rs2_addr_o),
        .ex_rd_addr_o        (ex_rd_addr_o),
        .ex_reg_write_en_o   (ex_reg_write_en_o),
        .ex_mem_to_reg_o     (ex_mem_to_reg_o),
        .ex_mem_read_en_o    (ex_mem_read_en_o),
        .ex_mem_write_en_o   (ex_mem_write_en_o),
        .ex_alu_src_b_o      (ex_alu_src_b_o),
        .ex_alu_op_o         (ex_alu_op_o),
        .ex_pc_src_o         (ex_pc_src_o),
        .ex_branch_o         (ex_branch_o),
        .ex_jump_o           (ex_jump_o),
        .ex_pc_current_o     (ex_pc_current_o)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/id_ex_reg_tb.vcd");
        $dumpvars(0, id_ex_reg_tb);

        // Initialize all inputs to 0 / sane defaults
        clk = 0; rst_n = 0; flush_i = 0; stall_i = 0;
        id_pc_plus_4_i = 32'h0; id_read_data1_i = 32'h0; id_read_data2_i = 32'h0;
        id_immediate_i = 32'h0; id_rs1_addr_i = 5'h0; id_rs2_addr_i = 5'h0; id_rd_addr_i = 5'h0;
        id_reg_write_en_i = 1'b0; id_mem_to_reg_i = 2'b0; id_mem_read_en_i = 1'b0;
        id_mem_write_en_i = 1'b0; id_alu_src_b_i = 2'b0; id_alu_op_i = 4'b0;
        id_pc_src_i = 2'b0; id_branch_i = 1'b0; id_jump_i = 1'b0; id_pc_current_i = 32'h0;

        // --- Test Sequence ---

        // 1. Apply reset
        #10 rst_n = 1; // De-assert reset
        $display("--- %0t: Test Reset ---", $time);
        $fflush();
        // Expected: All outputs should be 0

        // 2. Normal pipeline progression (e.g., ADDI x2, x1, 5)
        id_pc_plus_4_i = 32'h00000008;
        id_read_data1_i = 32'h0000000A; // x1 = 10
        id_read_data2_i = 32'h0000000F; // x2 = 15 (irrelevant for ADDI, but for test completeness)
        id_immediate_i = 32'h00000005; // immediate = 5
        id_rs1_addr_i = 5'h1; id_rs2_addr_i = 5'h2; id_rd_addr_i = 5'h2; // rd = x2
        id_reg_write_en_i = 1'b1; id_mem_to_reg_i = 2'b0; id_mem_read_en_i = 1'b0;
        id_mem_write_en_i = 1'b0; id_alu_src_b_i = 2'b01; id_alu_op_i = 4'h0; // ALUSrcB=imm, ALUOp=ADD
        id_pc_src_i = 2'b0; id_branch_i = 1'b0; id_jump_i = 1'b0; id_pc_current_i = 32'h00000004;

        #10; // Wait for clock edge
        $display("--- %0t: Test Normal Progression ---", $time);
        $fflush();
        // Expected: All outputs should match inputs (from previous clock cycle)

        // 3. Test Stall (stall_i = 1)
        stall_i = 1;
        // Inputs change, but outputs should hold previous values
        id_pc_plus_4_i = 32'h00000010; id_read_data1_i = 32'h12345678; id_read_data2_i = 32'hABCDABCD;
        id_immediate_i = 32'hFFFFFFF0; id_rs1_addr_i = 5'h3; id_rs2_addr_i = 5'h4; id_rd_addr_i = 5'h5;
        id_reg_write_en_i = 1'b0; id_mem_to_reg_i = 2'b1; id_mem_read_en_i = 1'b1;
        id_mem_write_en_i = 1'b0; id_alu_src_b_i = 2'b00; id_alu_op_i = 4'h1; // ALUSrcB=rs2, ALUOp=SUB
        id_pc_src_i = 2'b1; id_branch_i = 1'b1; id_jump_i = 1'b0; id_pc_current_i = 32'h00000008;

        #10; // Wait for clock edge
        $display("--- %0t: Test Stall ---", $time);
        $fflush();
        // Expected: Outputs should *not* change, retain previous values

        // 4. De-stall and check propagation
        stall_i = 0;
        #10; // Wait for clock edge
        $display("--- %0t: Test De-Stall Propagation ---", $time);
        $fflush();
        // Expected: Outputs should update to current inputs

        // 5. Test Flush (flush_i = 1) - higher priority than stall
        flush_i = 1;
        stall_i = 1; // Stall also active, but flush should win
        // Inputs irrelevant, outputs should be NOP/cleared state
        id_pc_plus_4_i = 32'hEEEEEEEE; id_read_data1_i = 32'hFFFFFFFF;
        id_read_data2_i = 32'hAAAAAAAA; id_immediate_i = 32'hBBBBBBBB;
        id_rs1_addr_i = 5'hF; id_rs2_addr_i = 5'hE; id_rd_addr_i = 5'hD;
        id_reg_write_en_i = 1'b1; id_mem_to_reg_i = 2'b1; id_mem_read_en_i = 1'b1;
        id_mem_write_en_i = 1'b1; id_alu_src_b_i = 2'b1; id_alu_op_i = 4'hF; // ALUSrcB=imm, ALUOp=COPY_B
        id_pc_src_i = 2'b1; id_branch_i = 1'b1; id_jump_i = 1'b1; id_pc_current_i = 32'hCCCCCCCC;

        #10; // Wait for clock edge
        $display("--- %0t: Test Flush ---", $time);
        $fflush();
        // Expected: All data outputs should be 0s, control signals 0s

        // 6. De-flush, de-stall
        flush_i = 0;
        stall_i = 0;
        // Inputs change, outputs should update
        id_pc_plus_4_i = 32'hDDDDDDDD; id_read_data1_i = 32'hDDDDDDDD;
        id_read_data2_i = 32'hDDDDDDDD; id_immediate_i = 32'hDDDDDDDD;
        id_rs1_addr_i = 5'hA; id_rs2_addr_i = 5'hB; id_rd_addr_i = 5'hC;
        id_reg_write_en_i = 1'b0; id_mem_to_reg_i = 2'b0; id_mem_read_en_i = 1'b0;
        id_mem_write_en_i = 1'b0; id_alu_src_b_i = 2'b0; id_alu_op_i = 4'h0;
        id_pc_src_i = 2'b0; id_branch_i = 1'b0; id_jump_i = 1'b0; id_pc_current_i = 32'hFFFFFFFF;

        #10; // Wait for clock edge
        $display("--- %0t: Test De-Flush/De-Stall Propagation ---", $time);
        $fflush();
        // Expected: Outputs should update to current inputs

        #20 $finish; // End simulation
    end

endmodule