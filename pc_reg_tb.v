// tb/pc_reg_tb.v
// Testbench for Program Counter (PC) module

`timescale 1ns/1ns // Define time units for simulation

module pc_reg_tb;

    // --- Testbench Signals (wires and regs for connecting to DUT) ---
    reg         clk;
    reg         rst_n;
    reg  [31:0] pc_next_i;
    reg         pc_write_en_i;
    wire [31:0] pc_o;

    // --- Instantiate the Device Under Test (DUT) ---
    pc_reg DUT (
        .clk            (clk),
        .rst_n          (rst_n),
        .pc_next_i      (pc_next_i),
        .pc_write_en_i  (pc_write_en_i),
        .pc_o           (pc_o)
    );

    // --- Clock Generation ---
    // Create a clock with a period of 10ns (frequency 100 MHz)
    always #5 clk = ~clk; // Toggle clk every 5ns (half period)

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0; // Assert reset
        pc_next_i = 32'h00000000;
        pc_write_en_i = 0;

        // Dump waveforms for GTKWave
        $dumpfile("sim/pc_reg_tb.vcd"); // Where to save the waveform data
        $dumpvars(0, pc_reg_tb);       // Dump all signals in this module and its sub-modules

        // --- Test Sequence ---

        #10 rst_n = 1; // De-assert reset after 10ns

        // 1. Initial PC value after reset (should be 0x0)
        // Wait for a clock cycle to observe reset output
        #10;
        $display("Time %0t: PC after reset = %h", $time, pc_o);
        // Expected: 0x0

        // 2. Normal PC increment (PC = PC + 4)
        // Simulate fetching instruction at 0x00000000
        pc_next_i = 32'h00000004; // Set next PC to 4 (current_pc + 4)
        pc_write_en_i = 1;
        #10; // Wait for one clock cycle
        $display("Time %0t: PC after increment 1 = %h", $time, pc_o);
        // Expected: 0x00000004

        // 3. Another normal increment
        pc_next_i = 32'h00000008; // Set next PC to 8
        #10;
        $display("Time %0t: PC after increment 2 = %h", $time, pc_o);
        // Expected: 0x00000008

        // 4. Load a new PC value (e.g., for a jump or branch)
        pc_next_i = 32'h00000100; // Jump to address 0x100
        #10;
        $display("Time %0t: PC after jump = %h", $time, pc_o);
        // Expected: 0x00000100

        // 5. Test pc_write_en_i (stalling PC)
        pc_write_en_i = 0;       // Disable PC write
        pc_next_i = 32'h00000104; // Even if next is 0x104
        #10;
        $display("Time %0t: PC after attempted write (disabled) = %h", $time, pc_o);
        // Expected: 0x00000100 (should not change)

        // 6. Re-enable write and see it update
        pc_write_en_i = 1;
        #10;
        $display("Time %0t: PC after re-enabled write = %h", $time, pc_o);
        // Expected: 0x00000104

        // --- End of Simulation ---
        #20 $finish; // End simulation after 20 more ns
    end

endmodule