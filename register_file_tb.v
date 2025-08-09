// tb/register_file_tb.v
// Testbench for Register File module

`timescale 1ns/1ns

module register_file_tb;

    // --- Testbench Signals ---
    reg         clk;
    reg         rst_n;

    reg  [4:0]  rs1_addr_i;
    reg  [4:0]  rs2_addr_i;
    
    reg  [4:0]  rd_addr_i;
    reg  [31:0] rd_data_i;
    reg         reg_write_en_i;
    wire [31:0] rs1_data_o;
    wire [31:0] rs2_data_o;

    // --- Instantiate the Device Under Test (DUT) ---
    register_file DUT (
        .clk            (clk),
        .rst_n          (rst_n),
        .rs1_addr_i     (rs1_addr_i),
        .rs2_addr_i     (rs2_addr_i),
        .rd_addr_i      (rd_addr_i),
        .rd_data_i      (rd_data_i),
        .reg_write_en_i (reg_write_en_i),
        .rs1_data_o     (rs1_data_o),
        .rs2_data_o     (rs2_data_o)
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0; // Assert reset
        rs1_addr_i = 5'd0;
        rs2_addr_i = 5'd0;
        rd_addr_i = 5'd0;
        rd_data_i = 32'h0;
        reg_write_en_i = 0;

        // Dump waveforms
        $dumpfile("sim/register_file_tb.vcd");
        $dumpvars(0, register_file_tb);

        // --- Test Sequence ---

        // 1. Apply reset
        #10 rst_n = 1; // De-assert reset

        // 2. Write to x1
        rd_addr_i = 5'd1;     // x1
        rd_data_i = 32'hDEADBEEF;
        reg_write_en_i = 1;
        #10; // Wait for one clock cycle for write to complete
        $display("Time %0t: Wrote %h to x%0d", $time, rd_data_i, rd_addr_i);

        // 3. Write to x2
        rd_addr_i = 5'd2;     // x2
        rd_data_i = 32'h12345678;
        reg_write_en_i = 1;
        #10;
        $display("Time %0t: Wrote %h to x%0d", $time, rd_data_i, rd_addr_i);

        // 4. Try to write to x0 (should not work)
        rd_addr_i = 5'd0;     // x0
        rd_data_i = 32'hFFFFFFFF; // Attempt to write this value
        reg_write_en_i = 1;
        #10;
        $display("Time %0t: Attempted to write %h to x0", $time, rd_data_i);


        // 5. Read from x1 (rs1) and x2 (rs2)
        reg_write_en_i = 0; // Disable write for read test
        rs1_addr_i = 5'd1;  // Read from x1
        rs2_addr_i = 5'd2;  // Read from x2
        #5; // Wait for combinational read
        $display("Time %0t: Read from x%0d: %h, Read from x%0d: %h",
                 $time, rs1_addr_i, rs1_data_o, rs2_addr_i, rs2_data_o);
        // Expected: x1=DEADBEEF, x2=12345678

        // 6. Read from x0 (rs1) and x1 (rs2)
        rs1_addr_i = 5'd0;  // Read from x0
        rs2_addr_i = 5'd1;  // Read from x1
        #5;
        $display("Time %0t: Read from x%0d: %h, Read from x%0d: %h",
                 $time, rs1_addr_i, rs1_data_o, rs2_addr_i, rs2_data_o);
        // Expected: x0=00000000, x1=DEADBEEF

        // 7. Write to x3 and read from x1 and x3 simultaneously
        rd_addr_i = 5'd3;
        rd_data_i = 32'hCAFEF00D;
        reg_write_en_i = 1;
        rs1_addr_i = 5'd1;
        rs2_addr_i = 5'd3; // Reading from x3 on the same cycle it's written (will read old value)
        #10; // One cycle for write
        $display("Time %0t: Wrote %h to x%0d. Read x%0d: %h, Read x%0d: %h (OLD value during write)",
                 $time, rd_data_i, rd_addr_i, rs1_addr_i, rs1_data_o, rs2_addr_i, rs2_data_o);
        // Expected: x1=DEADBEEF, x3=CAFEF00D (but will be old value during *this* cycle's read)

        // 8. Read x3 in next cycle (to get new value)
        reg_write_en_i = 0;
        rs1_addr_i = 5'd3;
        rs2_addr_i = 5'd2;
        #5;
        $display("Time %0t: Read from x%0d: %h, Read from x%0d: %h (NEW value)",
                 $time, rs1_addr_i, rs1_data_o, rs2_addr_i, rs2_data_o);
        // Expected: x3=CAFEF00D, x2=12345678


        #20 $finish; // End simulation
    end

endmodule