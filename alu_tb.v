// tb/alu_tb.v
// Testbench for ALU module

`timescale 1ns/1ns

module alu_tb;

    // --- Testbench Signals ---
    reg  [31:0] op1_i;
    reg  [31:0] op2_i;
    reg  [3:0]  alu_op_i;
    wire [31:0] alu_result_o;
    wire        zero_o;

    // --- Instantiate the Device Under Test (DUT) ---
    alu DUT (
        .op1_i        (op1_i),
        .op2_i        (op2_i),
        .alu_op_i     (alu_op_i),
        .alu_result_o (alu_result_o),
        .zero_o       (zero_o)
    );

    // Define ALU operation codes (must match alu.v)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;
    localparam ALU_COPY_B = 4'b1111;

    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // Initialize inputs
        op1_i = 32'h0;
        op2_i = 32'h0;
        alu_op_i = ALU_ADD; // Start with ADD

        // --- Test Sequence ---

        #10; // Wait for initial propagation

        // 1. ADD
        op1_i = 32'd10;
        op2_i = 32'd5;
        alu_op_i = ALU_ADD;
        #10;
        $display("Time %0t: %h + %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: 10 + 5 = F (0x0F), Zero = 0

        // 2. SUB (result is zero)
        op1_i = 32'd20;
        op2_i = 32'd20;
        alu_op_i = ALU_SUB;
        #10;
        $display("Time %0t: %h - %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: 20 - 20 = 0, Zero = 1

        // 3. AND
        op1_i = 32'hF0F0;
        op2_i = 32'h0F0F;
        alu_op_i = ALU_AND;
        #10;
        $display("Time %0t: %h & %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: F0F0 & 0F0F = 0000, Zero = 1

        // 4. OR
        op1_i = 32'hF0F0;
        op2_i = 32'h0F0F;
        alu_op_i = ALU_OR;
        #10;
        $display("Time %0t: %h | %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: F0F0 | 0F0F = FFFF, Zero = 0

        // 5. XOR
        op1_i = 32'hA5A5A5A5;
        op2_i = 32'h5A5A5A5A;
        alu_op_i = ALU_XOR;
        #10;
        $display("Time %0t: %h ^ %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: A5A5A5A5 ^ 5A5A5A5A = FFFFFFFF, Zero = 0

        // 6. SLL (Shift Left Logical)
        op1_i = 32'h0000000F; // 15
        op2_i = 32'd2;        // Shift by 2
        alu_op_i = ALU_SLL;
        #10;
        $display("Time %0t: %h << %d = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: 0000000F << 2 = 0000003C (60), Zero = 0

        // 7. SRL (Shift Right Logical)
        op1_i = 32'h80000000;
        op2_i = 32'd1;
        alu_op_i = ALU_SRL;
        #10;
        $display("Time %0t: %h >> %d = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: 80000000 >> 1 = 40000000, Zero = 0

        // 8. SRA (Shift Right Arithmetic - preserves sign)
        op1_i = 32'hFFFFFFFE; // -2 signed
        op2_i = 32'd1;
        alu_op_i = ALU_SRA;
        #10;
        $display("Time %0t: %h >>> %d = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: FFFFFFFE (-2) >>> 1 = FFFFFFFF (-1), Zero = 0

        // 9. SLT (Set Less Than - signed)
        op1_i = 32'd5;
        op2_i = 32'd10;
        alu_op_i = ALU_SLT;
        #10;
        $display("Time %0t: %d SLT %d = %h, Zero = %b", $time, $signed(op1_i), $signed(op2_i), alu_result_o, zero_o);
        // Expected: 5 < 10 = 1, Zero = 0

        // 10. SLT (Set Less Than - signed) - false case
        op1_i = 32'd10;
        op2_i = 32'd5;
        alu_op_i = ALU_SLT;
        #10;
        $display("Time %0t: %d SLT %d = %h, Zero = %b", $time, $signed(op1_i), $signed(op2_i), alu_result_o, zero_o);
        // Expected: 10 < 5 = 0, Zero = 1

        // 11. SLT (signed) - negative numbers
        op1_i = 32'hFFFFFFFF; // -1
        op2_i = 32'd0;
        alu_op_i = ALU_SLT;
        #10;
        $display("Time %0t: %d SLT %d = %h, Zero = %b", $time, $signed(op1_i), $signed(op2_i), alu_result_o, zero_o);
        // Expected: -1 < 0 = 1, Zero = 0

        // 12. SLTU (Set Less Than Unsigned)
        op1_i = 32'hFFFFFFFF; // unsigned max
        op2_i = 32'd0;
        alu_op_i = ALU_SLTU;
        #10;
        $display("Time %0t: %h SLTU %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: FFFFFFFF (large) < 0 (small) = 0, Zero = 1

        // 13. SLTU (unsigned) - true case
        op1_i = 32'd10;
        op2_i = 32'hFFFFFFFF;
        alu_op_i = ALU_SLTU;
        #10;
        $display("Time %0t: %h SLTU %h = %h, Zero = %b", $time, op1_i, op2_i, alu_result_o, zero_o);
        // Expected: 10 (small) < FFFFFFFF (large) = 1, Zero = 0

        // 14. ALU_COPY_B
        op1_i = 32'hAAAAAAAA; // irrelevant for COPY_B
        op2_i = 32'hBBBBBBBB;
        alu_op_i = ALU_COPY_B;
        #10;
        $display("Time %0t: COPY_B %h = %h, Zero = %b", $time, op2_i, alu_result_o, zero_o);
        // Expected: BBBBBBBB, Zero = 0

        // 15. Default (unhandled operation)
        alu_op_i = 4'b1010; // Unknown op code
        #10;
        $display("Time %0t: Default op: Result = %h, Zero = %b", $time, alu_result_o, zero_o);
        // Expected: XXXXXXXX (or some other uninitialized value), Zero = 0 or X

        #20 $finish; // End simulation
    end

endmodule