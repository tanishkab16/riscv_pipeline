`timescale 1ns / 1ps

module immediate_generator_tb;

  // Inputs
  reg [31:0] instruction_i;
  wire [31:0] imm_o;

  // Instantiate the Unit Under Test (UUT)
  immediate_generator dut (
    .instruction_i(instruction_i),
    .imm_o(imm_o)
  );

  // Task to test a single instruction
  task test_imm;
    input [31:0] instr_in;
    input [31:0] expected_imm;
    input [255:0] type;
    begin
      instruction_i = instr_in;
      #10;
      $display("Time %0t: %s: Instr %h, Imm %h, Expected %h",
               $time, type, instruction_i, imm_o, expected_imm);
      if (imm_o !== expected_imm) begin
        $display("ERROR: Immediate mismatch for %s", type);
        $finish;
      end
    end
  endtask

  initial begin
    // I-type: ADDI
    test_imm(32'h00100093, 32'h00000001, "I-type (ADDI)");
    test_imm(32'hfff00093, 32'hffffffff, "I-type (ADDI)");

    // S-type: SW
    test_imm(32'h001080a3, 32'h00000001, "S-type (SW)");
    test_imm(32'hfff08fa3, 32'hffffffff, "S-type (SW)");

    // B-type: BEQ
    test_imm(32'h00208663, 32'h0000000c, "B-type (BEQ)");
    test_imm(32'hffe08663, 32'hfffff7ec, "B-type (BEQ)");

    // U-type: LUI
    test_imm(32'h123450b7, 32'h12345000, "U-type (LUI)");

    // J-type: JAL
    test_imm(32'h0080006f, 32'h00000008, "J-type (JAL)");
    test_imm(32'hfff0006f, 32'hfff00ffe, "J-type (JAL)");

    $finish;
  end

endmodule
