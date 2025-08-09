// tb/if_id_reg_tb.v
// Testbench for IF/ID Pipeline Register

`timescale 1ns/1ns

module if_id_reg_tb;

    // --- Testbench Signals ---
    reg         clk;
    reg         rst_n;
    reg         flush_i;
    reg         stall_i;
    reg  [31:0] if_pc_plus_4_i;
    reg  [31:0] if_instruction_i;
    wire [31:0] id_pc_plus_4_o;
    wire [31:0] id_instruction_o;

    // --- Instantiate the Device Under Test (DUT) ---
    if_id_reg DUT (
        .clk                 (clk),
        .rst_n               (rst_n),
        .flush_i             (flush_i),
        .stall_i             (stall_i),
        .if_pc_plus_4_i      (if_pc_plus_4_i),
        .if_instruction_i    (if_instruction_i),
        .id_pc_plus_4_o      (id_pc_plus_4_o),
        .id_instruction_o    (id_instruction_o)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/if_id_reg_tb.vcd");
        $dumpvars(0, if_id_reg_tb);

        // Initialize inputs
        clk = 0;
        rst_n = 0;   // Assert reset
        flush_i = 0;
        stall_i = 0;
        if_pc_plus_4_i = 32'h0;
        if_instruction_i = 32'h0;

        // --- Test Sequence ---

        // 1. Apply reset
        #10 rst_n = 1; // De-assert reset
        // Expected: Outputs should be 0x0

        // 2. Normal pipeline progression
        if_pc_plus_4_i = 32'h00000004;
        if_instruction_i = 32'h00a00093; // addi x1, x0, 10
        #10; // Wait for clock edge
        // Expected: id_pc_plus_4_o = 0x4, id_instruction_o = 0x00a00093

        // 3. Another normal progression
        if_pc_plus_4_i = 32'h00000008;
        if_instruction_i = 32'h00508113; // addi x2, x1, 5
        #10;
        // Expected: id_pc_plus_4_o = 0x8, id_instruction_o = 0x00508113

        // 4. Test Stall (stall_i = 1)
        stall_i = 1;
        if_pc_plus_4_i = 32'h0000000C; // New value from IF
        if_instruction_i = 32'h001101b3; // New instruction from IF
        #10; // Wait for clock edge
        // Expected: Outputs should *not* change, retain previous values (0x8, 0x00508113)

        // 5. De-stall and check propagation
        stall_i = 0;
        #10; // Wait for clock edge
        // Expected: Outputs should update to 0x0C, 0x001101b3

        // 6. Test Flush (flush_i = 1) - higher priority than stall
        flush_i = 1;
        stall_i = 1; // Stall also active, but flush should win
        if_pc_plus_4_i = 32'h00000010; // New value from IF
        if_instruction_i = 32'h01400213; // New instruction from IF
        #10; // Wait for clock edge
        // Expected: Outputs should be NOP (0x00000013) for instruction, and 0x0 for PC+4

        // 7. De-flush, de-stall
        flush_i = 0;
        stall_i = 0;
        if_pc_plus_4_i = 32'h00000014; // Value for next cycle
        if_instruction_i = 32'h00400023;
        #10;
        // Expected: Outputs should update to 0x14, 0x00400023

        #20 $finish; // End simulation
    end

endmodule