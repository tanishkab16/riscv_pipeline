// src/control_unit.v
// Control Unit module

module control_unit (
    input wire [6:0] opcode_i,    // Instruction opcode (bits 6:0)
    input wire [2:0] funct3_i,    // Instruction funct3 (bits 14:12)
    input wire [6:0] funct7_i,    // Instruction funct7 (bits 31:25) - only for R-type/shifts

    // Control signals for Register File
    output reg        reg_write_en_o, // Enable Register File write
    output reg [1:0]  mem_to_reg_o,   // Selects data for RegFile write (00=ALU, 01=MEM_Data, 10=PC+4)

    // Control signals for Data Memory
    output reg        mem_read_en_o,  // Enable Data Memory read
    output reg        mem_write_en_o, // Enable Data Memory write

    // Control signals for ALU
    output reg [1:0]  alu_src_b_o,    // Selects ALU operand B (00=rs2_data, 01=immediate)
    output reg [3:0]  alu_op_o,       // ALU operation code (matches alu.v localparams)

    // Control signals for PC update/branching
    output reg [1:0]  pc_src_o,       // Selects next PC (00=PC+4, 01=Branch_Target, 10=Jump_Target)
    output reg        branch_o,       // Indicates a branch instruction
    output reg        jump_o          // Indicates a JAL or JALR instruction
);

// Define RISC-V opcodes (from ISA)
localparam OPCODE_R_TYPE   = 7'b0110011; // R-type (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA)
localparam OPCODE_IMM      = 7'b0010011; // I-type (ADDI, SLTI, ANDI, ORI, XORI, SLLI, SRLI, SRAI)
localparam OPCODE_LOAD     = 7'b0000011; // I-type (LW)
localparam OPCODE_STORE    = 7'b0100011; // S-type (SW)
localparam OPCODE_BRANCH   = 7'b1100011; // B-type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
localparam OPCODE_JALR     = 7'b1100111; // I-type (JALR)
localparam OPCODE_JAL      = 7'b1101111; // J-type (JAL)
localparam OPCODE_LUI      = 7'b0110111; // U-type (LUI)
localparam OPCODE_AUIPC    = 7'b0010111; // U-type (AUIPC)

// Define funct3 values for various instructions
localparam FUNCT3_ADD_SUB  = 3'b000;
localparam FUNCT3_SLL      = 3'b001;
localparam FUNCT3_SLT      = 3'b010;
localparam FUNCT3_SLTU     = 3'b011;
localparam FUNCT3_XOR      = 3'b100;
localparam FUNCT3_SRL_SRA  = 3'b101;
localparam FUNCT3_OR       = 3'b110;
localparam FUNCT3_AND      = 3'b111;

// Define funct7 values for R-type and shifts
localparam FUNCT7_SUB      = 7'b0100000; // For SUB, SRA

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
localparam ALU_COPY_B = 4'b1111; // For LUI, AUIPC, JAL, JALR where imm is passed through

// Define PC_SRC options
localparam PC_SRC_PC_PLUS_4 = 2'b00;
localparam PC_SRC_BRANCH    = 2'b01;
localparam PC_SRC_JUMP      = 2'b10;

// Define MEM_TO_REG options
localparam MEM_TO_REG_ALU_RESULT = 2'b00;
localparam MEM_TO_REG_MEM_DATA   = 2'b01;
localparam MEM_TO_REG_PC_PLUS_4  = 2'b10;


// Combinational Control Logic
always @(*) begin
    // Default values (for most instructions, or for unknown/R-type without explicit set)
    reg_write_en_o = 1'b0;
    mem_to_reg_o   = MEM_TO_REG_ALU_RESULT; // Default to ALU result for writes
    mem_read_en_o  = 1'b0;
    mem_write_en_o = 1'b0;
    alu_src_b_o    = 2'b00; // Default to rs2_data for ALU B input
    alu_op_o       = ALU_ADD; // Default ALU op (arbitrary, will be overwritten)
    pc_src_o       = PC_SRC_PC_PLUS_4; // Default to PC+4
    branch_o       = 1'b0;
    jump_o         = 1'b0;


    case (opcode_i)
        OPCODE_R_TYPE: begin // R-type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
            reg_write_en_o = 1'b1;
            alu_src_b_o = 2'b00; // rs2_data
            case (funct3_i)
                FUNCT3_ADD_SUB: begin
                    if (funct7_i == FUNCT7_SUB) alu_op_o = ALU_SUB;
                    else alu_op_o = ALU_ADD; // ADD
                end
                FUNCT3_SLL:     alu_op_o = ALU_SLL;
                FUNCT3_SLT:     alu_op_o = ALU_SLT;
                FUNCT3_SLTU:    alu_op_o = ALU_SLTU;
                FUNCT3_XOR:     alu_op_o = ALU_XOR;
                FUNCT3_SRL_SRA: begin
                    if (funct7_i == FUNCT7_SUB) alu_op_o = ALU_SRA;
                    else alu_op_o = ALU_SRL; // SRL
                end
                FUNCT3_OR:      alu_op_o = ALU_OR;
                FUNCT3_AND:     alu_op_o = ALU_AND;
                default:        alu_op_o = ALU_ADD; // Default for unsupported funct3
            endcase
        end

        OPCODE_IMM: begin // I-type (ADDI, SLTI, ANDI, ORI, XORI, SLLI, SRLI, SRAI)
            reg_write_en_o = 1'b1;
            alu_src_b_o = 2'b01; // Immediate
            case (funct3_i)
                FUNCT3_ADD_SUB: alu_op_o = ALU_ADD; // ADDI
                FUNCT3_SLL:     alu_op_o = ALU_SLL; // SLLI
                FUNCT3_SLT:     alu_op_o = ALU_SLT; // SLTI
                FUNCT3_SLTU:    alu_op_o = ALU_SLTU; // SLTIU
                FUNCT3_XOR:     alu_op_o = ALU_XOR; // XORI
                FUNCT3_SRL_SRA: begin // SRLI / SRAI
                    if (funct7_i == FUNCT7_SUB) alu_op_o = ALU_SRA;
                    else alu_op_o = ALU_SRL; // SRLI
                end
                FUNCT3_OR:      alu_op_o = ALU_OR; // ORI
                FUNCT3_AND:     alu_op_o = ALU_AND; // ANDI
                default:        alu_op_o = ALU_ADD; // Default for unsupported funct3
            endcase
        end

        OPCODE_LOAD: begin // I-type (LW)
            reg_write_en_o = 1'b1;
            mem_read_en_o = 1'b1;
            mem_to_reg_o = MEM_TO_REG_MEM_DATA; // Data from memory to RegFile
            alu_src_b_o = 2'b01; // Immediate (offset)
            alu_op_o = ALU_ADD; // Calculate effective address (base_reg + offset)
        end

        OPCODE_STORE: begin // S-type (SW)
            mem_write_en_o = 1'b1;
            alu_src_b_o = 2'b01; // Immediate (offset)
            alu_op_o = ALU_ADD; // Calculate effective address
        end

        OPCODE_BRANCH: begin // B-type (BEQ, BNE, etc.)
            branch_o = 1'b1;
            pc_src_o = PC_SRC_BRANCH; // Conditional jump to branch target
            alu_src_b_o = 2'b00; // Compare rs1 and rs2
            case (funct3_i)
                FUNCT3_ADD_SUB: alu_op_o = ALU_SUB; // For BEQ/BNE, compare by subtracting
                default:        alu_op_o = ALU_SUB; // Default for other branch types
            endcase
        end

        OPCODE_JAL: begin // J-type (JAL)
            reg_write_en_o = 1'b1;
            jump_o = 1'b1;
            pc_src_o = PC_SRC_JUMP; // Unconditional jump
            mem_to_reg_o = MEM_TO_REG_PC_PLUS_4; // Store PC+4 in rd
            alu_op_o = ALU_ADD; // ALU not strictly needed, but can pass through (PC+4 + 0) or simply copy PC+4
            alu_src_b_o = 2'b00; // rs2 (irrelevant for JAL ALU op)
        end

        OPCODE_JALR: begin // I-type (JALR)
            reg_write_en_o = 1'b1;
            jump_o = 1'b1;
            pc_src_o = PC_SRC_JUMP; // Unconditional jump
            mem_to_reg_o = MEM_TO_REG_PC_PLUS_4; // Store PC+4 in rd
            alu_src_b_o = 2'b01; // Immediate (offset)
            alu_op_o = ALU_ADD; // Calculate target (base_reg + offset)
        end

        OPCODE_LUI: begin // U-type (LUI)
            reg_write_en_o = 1'b1;
            alu_src_b_o = 2'b01; // Immediate
            alu_op_o = ALU_COPY_B; // ALU simply passes immediate to result
        end

        OPCODE_AUIPC: begin // U-type (AUIPC)
            reg_write_en_o = 1'b1;
            alu_src_b_o = 2'b01; // Immediate
            alu_op_o = ALU_ADD; // ALU calculates PC + immediate
        end

        default: begin // Default for unknown/unsupported opcodes
            // All control signals remain at their default (off) values
        end
    endcase
end

endmodule
