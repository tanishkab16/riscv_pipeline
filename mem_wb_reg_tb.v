// Code your testbench here
// or browse Examples
// tb/mem_wb_reg_tb.v
// Testbench for MEM/WB Pipeline Register

`timescale 1ns/1ns

module mem_wb_reg_tb;

    // --- Testbench Signals ---
    reg         clk;
    reg         rst_n;
    reg         flush_i;

    reg [31:0] mem_alu_result_i;
    reg [31:0] mem_mem_read_data_i;
    reg [31:0] mem_pc_plus_4_i;
    reg [4:0]  mem_rd_addr_i;

    reg        mem_reg_write_en_i;
    reg [1:0]  mem_mem_to_reg_i;

    wire [31:0] wb_alu_result_o;
    wire [31:0] wb_mem_read_data_o;
    wire [31:0] wb_pc_plus_4_o;
    wire [4:0]  wb_rd_addr_o;
    wire        wb_reg_write_en_o;
    wire [1:0]  wb_mem_to_reg_o;


    // --- Instantiate the Device Under Test (DUT) ---
    mem_wb_reg DUT (
        .clk                 (clk),
        .rst_n               (rst_n),
        .flush_i             (flush_i),

        .mem_alu_result_i    (mem_alu_result_i),
        .mem_mem_read_data_i (mem_mem_read_data_i),
        .mem_pc_plus_4_i     (mem_pc_plus_4_i),
        .mem_rd_addr_i       (mem_rd_addr_i),

        .mem_reg_write_en_i  (mem_reg_write_en_i),
        .mem_mem_to_reg_i    (mem_mem_to_reg_i),

        .wb_alu_result_o     (wb_alu_result_o),
        .wb_mem_read_data_o  (wb_mem_read_data_o),
        .wb_pc_plus_4_o      (wb_pc_plus_4_o),
        .wb_rd_addr_o        (wb_rd_addr_o),
        .wb_reg_write_en_o   (wb_reg_write_en_o),
        .wb_mem_to_reg_o     (wb_mem_to_reg_o)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/mem_wb_reg_tb.vcd");
        $dumpvars(0, mem_wb_reg_tb);

        // Initialize all inputs to 0 / sane defaults
        clk = 0; rst_n = 0; flush_i = 0;
        mem_alu_result_i = 32'h0; mem_mem_read_data_i = 32'h0; mem_pc_plus_4_i = 32'h0; mem_rd_addr_i = 5'h0;
        mem_reg_write_en_i = 1'b0; mem_mem_to_reg_i = 2'b0;

        // --- Test Sequence ---

        // 1. Apply reset
        #10 rst_n = 1; // De-assert reset
        $display("--- %0t: Test Reset ---", $time);
        $fflush();
        // Expected: All outputs should be 0

        // 2. Normal pipeline progression (e.g., R-type ADD/SUB/AND etc.)
        mem_alu_result_i = 32'h0000000F; // ALU Result = 15
        mem_mem_read_data_i = 32'hABCDABCD; // Irrelevant for R-type
        mem_pc_plus_4_i = 32'h00000008; // PC+4 for R-type
        mem_rd_addr_i = 5'h3; // rd = x3
        mem_reg_write_en_i = 1'b1; mem_mem_to_reg_i = 2'b0; // RegWrite=1, MemToReg=ALU_Result

        #10; // Wait for clock edge
        $display("--- %0t: Test Normal Progression (R-type) ---", $time);
        $fflush();
        // Expected: wb_alu_result_o=15, wb_rd_addr_o=x3, wb_reg_write_en_o=1, etc.

        // 3. Test Load instruction (LW)
        mem_alu_result_i = 32'h12345678; // ALU Result = address (irrelevant for LW writeback)
        mem_mem_read_data_i = 32'h00000014; // Data read from memory = 20
        mem_pc_plus_4_i = 32'h00000018; // PC+4 for LW
        mem_rd_addr_i = 5'h5; // rd = x5
        mem_reg_write_en_i = 1'b1; mem_mem_to_reg_i = 2'b1; // RegWrite=1, MemToReg=MEM_DATA

        #10; // Wait for clock edge
        $display("--- %0t: Test Load (LW) ---", $time);
        $fflush();
        // Expected: wb_mem_read_data_o=20, wb_rd_addr_o=x5, wb_reg_write_en_o=1, etc.

        // 4. Test Jump and Link (JAL)
        mem_alu_result_i = 32'hBBBBBBBB; // Irrelevant for JAL
        mem_mem_read_data_i = 32'hCCCCCCCC; // Irrelevant for JAL
        mem_pc_plus_4_i = 32'h0000002C; // PC+4 for JAL (link address)
        mem_rd_addr_i = 5'h1; // rd = x1 (store link address here)
        mem_reg_write_en_i = 1'b1; mem_mem_to_reg_i = 2'b10; // RegWrite=1, MemToReg=PC+4

        #10; // Wait for clock edge
        $display("--- %0t: Test Jump and Link (JAL) ---", $time);
        $fflush();
        // Expected: wb_pc_plus_4_o=0x2C, wb_rd_addr_o=x1, wb_reg_write_en_o=1, etc.

        // 5. Test Non-Write (e.g., SW, BEQ)
        mem_alu_result_i = 32'h0; mem_mem_read_data_i = 32'h0; mem_pc_plus_4_i = 32'h0; mem_rd_addr_i = 5'h0;
        mem_reg_write_en_i = 1'b0; mem_mem_to_reg_i = 2'b0; // RegWrite=0

        #10; // Wait for clock edge
        $display("--- %0t: Test Non-Write (SW/BEQ) ---", $time);
        $fflush();
        // Expected: All writeback outputs should be 0/unchanged, reg_write_en_o=0

        // 6. Test Flush
        flush_i = 1;
        // Inputs irrelevant, outputs should be 0s
        mem_alu_result_i = 32'hEEEEEEEE; mem_mem_read_data_i = 32'hFFFFFFFF; mem_pc_plus_4_i = 32'hAAAAAAAA; mem_rd_addr_i = 5'hB;
        mem_reg_write_en_i = 1'b1; mem_mem_to_reg_i = 2'b1;

        #10; // Wait for clock edge
        $display("--- %0t: Test Flush ---", $time);
        $fflush();
        // Expected: All outputs should be 0s

        // 7. De-flush
        flush_i = 0;
        // Inputs change, outputs should update normally
        mem_alu_result_i = 32'hDDDDDDDD; mem_mem_read_data_i = 32'hDDDDDDDD; mem_pc_plus_4_i = 32'hDDDDDDDD; mem_rd_addr_i = 5'hC;
        mem_reg_write_en_i = 1'b1; mem_mem_to_reg_i = 2'b0;

        #10; // Wait for clock edge
        $display("--- %0t: Test De-Flush Propagation ---", $time);
        $fflush();
        // Expected: Outputs should update to current inputs

        #20 $finish; // End simulation
    end

endmodule