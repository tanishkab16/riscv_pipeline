// tb/single_cycle_processor_tb.v
// Testbench for Single-Cycle RISC-V Processor

`timescale 1ns/1ns

module single_cycle_processor_tb;

    // --- Testbench Signals ---
    reg clk;
    reg rst_n;

    // --- Instantiate the Device Under Test (DUT) ---
    single_cycle_processor DUT (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/single_cycle_processor_tb.vcd");
        $dumpvars(0, single_cycle_processor_tb);
        // Dump internal signals of sub-modules for detailed debugging
        $dumpvars(0, DUT.i_pc);
        $dumpvars(0, DUT.i_imem);
        $dumpvars(0, DUT.i_control);
        $dumpvars(0, DUT.i_regfile);
        $dumpvars(0, DUT.i_immgen);
        $dumpvars(0, DUT.i_alu);
        $dumpvars(0, DUT.i_dmem);


        // Initialize signals
        clk = 0;
        rst_n = 0; // Assert reset

        // Apply reset pulse
        #10 rst_n = 1; // De-assert reset

        // Run for enough clock cycles to execute the simple program
        // (Approx 11 instructions + loop = ~15-20 cycles)
        repeat (30) @(posedge clk); // Run for 30 clock cycles

        $display("--- Simulation Finished ---");
        $display("Final Register Values:");
        $display("x0 : %h", DUT.i_regfile.registers[0]); // Should be 0
        $display("x1 : %h", DUT.i_regfile.registers[1]); // Should be 0xa (10)
        $display("x2 : %h", DUT.i_regfile.registers[2]); // Should be 0xf (15)
        $display("x3 : %h", DUT.i_regfile.registers[3]); // Should be 0x5 (5)
        $display("x4 : %h", DUT.i_regfile.registers[4]); // Should be 0x14 (20)
        $display("x5 : %h", DUT.i_regfile.registers[5]); // Should be 0x14 (20)
        $display("x6 : %h", DUT.i_regfile.registers[6]); // Should be 0x65 (101)
        $display("x7 : %h", DUT.i_regfile.registers[7]); // Should be 0xc8 (200)
        $display("x10: %h", DUT.i_regfile.registers[10]);// Should be 0x0 (not reached 300)

        $display("Data Memory at address 0x0: %h", DUT.i_dmem.mem[0]); // Should be 0x14 (20)

        #10 $finish; // End simulation
    end

endmodule