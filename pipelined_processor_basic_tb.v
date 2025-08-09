// Code your testbench here
// or browse Examples
// tb/pipelined_processor_basic_tb.v
// Testbench for Basic 5-Stage Pipelined RISC-V Processor (No Hazards Yet)

`timescale 1ns/1ns
`default_nettype none 

module pipelined_processor_basic_tb;

    // --- Testbench Signals ---
    reg clk;
    reg rst_n;
  
   // Wires to capture debug outputs
    wire [31:0] debug_reg_x0_val;
    wire [31:0] debug_reg_x1_val;
    wire [31:0] debug_reg_x2_val;
    wire [31:0] debug_reg_x3_val;
    wire [31:0] debug_reg_x4_val;
    wire [31:0] debug_reg_x5_val;
    wire [31:0] debug_reg_x6_val;
    wire [31:0] debug_reg_x7_val;
    wire [31:0] debug_reg_x10_val;
    wire [31:0] debug_data_mem_0_val;


    // --- Instantiate the Device Under Test (DUT) ---
    // This will instantiate your main pipelined processor module
    pipelined_processor DUT ( // Name of the top-level pipelined module
        .clk   (clk),
        .rst_n (rst_n),
        // Connect debug outputs
        .debug_reg_x0  (debug_reg_x0_val),
        .debug_reg_x1  (debug_reg_x1_val),
        .debug_reg_x2  (debug_reg_x2_val),
        .debug_reg_x3  (debug_reg_x3_val),
        .debug_reg_x4  (debug_reg_x4_val),
        .debug_reg_x5  (debug_reg_x5_val),
        .debug_reg_x6  (debug_reg_x6_val),
        .debug_reg_x7  (debug_reg_x7_val),
        .debug_reg_x10 (debug_reg_x10_val),
        .debug_data_mem_0 (debug_data_mem_0_val)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/pipelined_processor_basic_tb.vcd");
        $dumpvars(0, pipelined_processor_basic_tb);

        // Initialize signals
        clk = 0;
        rst_n = 0; // Assert reset

        // Apply reset pulse
        #10 rst_n = 1; // De-assert reset

        // Run for enough clock cycles to execute the simple program
        // A pipelined processor executes one instruction per cycle (after pipeline fill).
        // Our simple program has ~13 instructions. Plus pipeline fill (4 cycles).
        // So, 13 + 4 = ~17 cycles to complete. Run for more to be safe.
        repeat (40) @(posedge clk); // Run for 40 clock cycles

        $display("--- Pipelined Simulation Finished ---");
        $fflush();
        $display("Final Register Values:");
        $fflush();
        $display("x0 : %h", debug_reg_x0_val);
        $fflush();
        $display("x1 : %h", debug_reg_x1_val);
        $fflush();
        $display("x2 : %h", debug_reg_x2_val);
        $fflush();
        $display("x3 : %h", debug_reg_x3_val);
        $fflush();
        $display("x4 : %h", debug_reg_x4_val);
        $fflush();
        $display("x5 : %h", debug_reg_x5_val);
        $fflush();
        $display("x6 : %h", debug_reg_x6_val);
        $fflush();
        $display("x7 : %h", debug_reg_x7_val);
        $fflush();
        $display("x10: %h", debug_reg_x10_val);
        $fflush();

        $display("Data Memory at address 0x0: %h", debug_data_mem_0_val);
        $fflush();

        #10 $finish; // End simulation
    end

endmodule