// tb/instruction_memory_tb.v
// Testbench for Instruction Memory module

`timescale 1ns/1ns

module instruction_memory_tb;

    // --- Testbench Signals ---
    reg  [31:0] addr_i;
    wire [31:0] instr_o;

    // --- Instantiate the Device Under Test (DUT) ---
    instruction_memory DUT (
        .addr_i  (addr_i),
        .instr_o (instr_o)
    );

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);

        // --- Test Sequence ---

        // Test 1: Read from address 0x00000000
        addr_i = 32'h00000000;
        #10; // Allow time for combinational logic to propagate
        $display("Time %0t: Address %h, Instruction %h", $time, addr_i, instr_o);
        // Expected: 00500093 (addi x1, x0, 5)

        // Test 2: Read from address 0x00000004
        addr_i = 32'h00000004;
        #10;
        $display("Time %0t: Address %h, Instruction %h", $time, addr_i, instr_o);
        // Expected: 00A08113 (addi x2, x1, 10)

        // Test 3: Read from address 0x00000014 (sw instruction)
        addr_i = 32'h00000014;
        #10;
        $display("Time %0t: Address %h, Instruction %h", $time, addr_i, instr_o);
        // Expected: 00302023 (sw x3, 0(x0))

        // Test 4: Read from address 0x0000001C (beq instruction)
        addr_i = 32'h0000001C;
        #10;
        $display("Time %0t: Address %h, Instruction %h", $time, addr_i, instr_o);
        // Expected: 00028C63 (beq x5, x0, 0x8)

        // Test 5: Try an unaligned address (bits [1:0] should be ignored)
        // This shouldn't happen with PC, but useful for testing the [31:2] logic
        addr_i = 32'h00000001; // Should still read instruction at 0x00000000
        #10;
        $display("Time %0t: Address %h (unaligned), Instruction %h", $time, addr_i, instr_o);
        // Expected: 00500093

        // Test 6: Try an address beyond our defined instructions (should read 0s or x's depending on simulator)
        addr_i = 32'h00000100; // This address is within MEM_SIZE, but no instruction defined in .mem
        #10;
        $display("Time %0t: Address %h (empty), Instruction %h", $time, addr_i, instr_o);
        // Expected: 00000000 (if uninitialized memory defaults to zero)

        #20 $finish; // End simulation
    end

endmodule