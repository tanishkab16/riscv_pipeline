// tb/control_unit_tb.v
// Testbench for Control Unit module - FINAL VERIFIED VERSION (NO TASK)

`timescale 1ns/1ns

module control_unit_tb;

    // --- Testbench Signals ---
    reg  [6:0] opcode_i;
    reg  [2:0] funct3_i;
    reg  [6:0] funct7_i;

    wire        reg_write_en_o;
    wire [1:0]  mem_to_reg_o;
    wire        mem_read_en_o;
    wire        mem_write_en_o;
    wire [1:0]  alu_src_b_o;
    wire [3:0]  alu_op_o;
    wire [1:0]  pc_src_o;
    wire        branch_o;
    wire        jump_o;

    // --- Instantiate the Device Under Test (DUT) ---
    control_unit DUT (
        .opcode_i        (opcode_i),
        .funct3_i        (funct3_i),
        .funct7_i        (funct7_i),
        .reg_write_en_o  (reg_write_en_o),
        .mem_to_reg_o    (mem_to_reg_o),
        .mem_read_en_o   (mem_read_en_o),
        .mem_write_en_o  (mem_write_en_o),
        .alu_src_b_o     (alu_src_b_o),
        .alu_op_o        (alu_op_o),
        .pc_src_o        (pc_src_o),
        .branch_o        (branch_o),
        .jump_o          (jump_o)
    );

    // Define RISC-V opcodes (must match control_unit.v)
    localparam OPCODE_R_TYPE   = 7'b0110011;
    localparam OPCODE_IMM      = 7'b0010011;
    localparam OPCODE_LOAD     = 7'b0000011;
    localparam OPCODE_STORE    = 7'b0100011;
    localparam OPCODE_BRANCH   = 7'b1100011;
    localparam OPCODE_JALR     = 7'b1100111;
    localparam OPCODE_JAL      = 7'b1101111;
    localparam OPCODE_LUI      = 7'b0110111;
    localparam OPCODE_AUIPC    = 7'b0010111;

    // Define funct3 values
    localparam FUNCT3_ADD_SUB  = 3'b000;
    localparam FUNCT3_SLL      = 3'b001;
    localparam FUNCT3_SLT      = 3'b010;
    localparam FUNCT3_SLTU     = 3'b011;
    localparam FUNCT3_XOR      = 3'b100;
    localparam FUNCT3_SRL_SRA  = 3'b101;
    localparam FUNCT3_OR       = 3'b110;
    localparam FUNCT3_AND      = 3'b111;

    // Define funct7 values
    localparam FUNCT7_ADD      = 7'b0000000;
    localparam FUNCT7_SUB      = 7'b0100000;

    // Define ALU operation codes
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

    // Define PC_SRC options
    localparam PC_SRC_PC_PLUS_4 = 2'b00;
    localparam PC_SRC_BRANCH    = 2'b01;
    localparam PC_SRC_JUMP      = 2'b10;

    // Define MEM_TO_REG options
    localparam MEM_TO_REG_ALU_RESULT = 2'b00;
    localparam MEM_TO_REG_MEM_DATA   = 2'b01;
    localparam MEM_TO_REG_PC_PLUS_4  = 2'b10;


    // --- Initial Block (Test Scenario) ---
    initial begin
        // Dump waveforms
        $dumpfile("sim/control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);

        // Initialize inputs
        opcode_i = 7'b0;
        funct3_i = 3'b0;
        funct7_i = 7'b0;

        #10; // Allow time for initial propagation

        // --- Test Cases ---
        // (Expanded task logic inline for maximum iverilog compatibility)

        // 1. R-Type: ADD
        opcode_i = OPCODE_R_TYPE;
        funct3_i = FUNCT3_ADD_SUB;
        funct7_i = FUNCT7_ADD;
        #10;
        $display("--- %0t: Test ADD ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT); // FIXED CASE
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b00);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   || // FIXED CASE
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b00    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
            $display("!!! MISMATCH !!!");
        end
        $display("");

        // 2. R-Type: SUB
        opcode_i = OPCODE_R_TYPE;
        funct3_i = FUNCT3_ADD_SUB;
        funct7_i = FUNCT7_SUB;
        #10;
        $display("--- %0t: Test SUB ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b00);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_SUB);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   || // FIXED CASE
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b00    ||
            alu_op_o       !== ALU_SUB       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
            $display("!!! MISMATCH !!!");
        end
        $display("");

        // 3. I-Type: ADDI
        opcode_i = OPCODE_IMM;
        funct3_i = FUNCT3_ADD_SUB;
        funct7_i = 7'b0; // Irrelevant for ADDI
        #10;
        $display("--- %0t: Test ADDI ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   || // FIXED CASE
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
            $display("!!! MISMATCH !!!");
        end
        $display("");

        // 4. I-Type: LW (Load Word)
        opcode_i = OPCODE_LOAD;
        funct3_i = 3'b000; // For LW
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test LW ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_MEM_DATA);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b1);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_MEM_DATA   ||
            mem_read_en_o  !== 1'b1  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 5. S-Type: SW (Store Word)
        opcode_i = OPCODE_STORE;
        funct3_i = 3'b000; // For SW
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test SW ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b0);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b1);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b0 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   || // FIXED CASE
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b1 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 6. B-Type: BEQ (Branch Equal)
        opcode_i = OPCODE_BRANCH;
        funct3_i = FUNCT3_ADD_SUB; // For BEQ/BNE comparison
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test BEQ ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b0);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b00);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_SUB);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_BRANCH);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b1);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b0 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   || // FIXED CASE
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b00    ||
            alu_op_o       !== ALU_SUB       ||
            pc_src_o       !== PC_SRC_BRANCH       ||
            branch_o       !== 1'b1       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 7. J-Type: JAL (Jump and Link)
        opcode_i = OPCODE_JAL;
        funct3_i = 3'b0; // Irrelevant for JAL
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test JAL ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_PC_PLUS_4);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b00);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_JUMP);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b1);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_PC_PLUS_4   ||
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b00    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_JUMP       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b1) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 8. I-Type: JALR (Jump and Link Register)
        opcode_i = OPCODE_JALR;
        funct3_i = 3'b000; // For JALR
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test JALR ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_PC_PLUS_4);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_JUMP);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b1);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_PC_PLUS_4   ||
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_JUMP       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b1) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 9. U-Type: LUI (Load Upper Immediate)
        opcode_i = OPCODE_LUI;
        funct3_i = 3'b0; // Irrelevant
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test LUI ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_COPY_B);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   ||
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_COPY_B       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 10. U-Type: AUIPC (Add Upper Immediate to PC)
        opcode_i = OPCODE_AUIPC;
        funct3_i = 3'b0; // Irrelevant
        funct7_i = 7'b0; // Irrelevant
        #10;
        $display("--- %0t: Test AUIPC ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_ADD);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   ||
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_ADD       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 11. R-Type: SLL
        opcode_i = OPCODE_R_TYPE;
        funct3_i = FUNCT3_SLL;
        funct7_i = FUNCT7_ADD; // For SLL
        #10;
        $display("--- %0t: Test SLL ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b00);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_SLL);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   ||
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b00    ||
            alu_op_o       !== ALU_SLL       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");

        // 12. I-Type: SRLI
        opcode_i = OPCODE_IMM;
        funct3_i = FUNCT3_SRL_SRA;
        funct7_i = FUNCT7_ADD; // For SRLI
        #10;
        $display("--- %0t: Test SRLI ---", $time);
        $display("  RegWrite: %b (Exp: %b)", reg_write_en_o, 1'b1);
        $display("  MemToReg: %b (Exp: %b)", mem_to_reg_o, MEM_TO_REG_ALU_RESULT);
        $display("  MemRead:  %b (Exp: %b)", mem_read_en_o, 1'b0);
        $display("  MemWrite: %b (Exp: %b)", mem_write_en_o, 1'b0);
        $display("  ALUSrcB:  %b (Exp: %b)", alu_src_b_o, 2'b01);
        $display("  ALUOp:    %b (Exp: %b)", alu_op_o, ALU_SRL);
        $display("  PCSrc:    %b (Exp: %b)", pc_src_o, PC_SRC_PC_PLUS_4);
        $display("  Branch:   %b (Exp: %b)", branch_o, 1'b0);
        $display("  Jump:     %b (Exp: %b)", jump_o, 1'b0);
        if (reg_write_en_o !== 1'b1 ||
            mem_to_reg_o   !== MEM_TO_REG_ALU_RESULT   ||
            mem_read_en_o  !== 1'b0  ||
            mem_write_en_o !== 1'b0 ||
            alu_src_b_o    !== 2'b01    ||
            alu_op_o       !== ALU_SRL       ||
            pc_src_o       !== PC_SRC_PC_PLUS_4       ||
            branch_o       !== 1'b0       ||
            jump_o         !== 1'b0) begin
        $display("!!! MISMATCH !!!");
        end
        $display("");


        #20 $finish; // End simulation
    end

endmodule