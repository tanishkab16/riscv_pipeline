// src/pipelined_processor.v
// 5-Stage Pipelined RISC-V Processor (Basic - No Hazards Yet)
// FINAL EDA PLAYGROUND Xcelium FIX (ALL PORT CONNECTIONS NAMED)

`timescale 1ns/1ns
`default_nettype none

`include "pc_reg.v"
`include "instruction_memory.v"
`include "control_unit.v"
`include "register_file.v"
`include "immediate_generator.v"
`include "alu.v"
`include "data_memory.v"
`include "if_id_reg.v"
`include "id_ex_reg.v"
`include "ex_mem_reg.v"
`include "mem_wb_reg.v"


module pipelined_processor (
    input wire clk, // Clock
    input wire rst_n // Asynchronous active-low reset

    // --- NEW OUTPUT PORTS TO EXPOSE INTERNAL STATE (DEBUG) ---
    ,output wire [31:0] debug_reg_x0
    ,output wire [31:0] debug_reg_x1
    ,output wire [31:0] debug_reg_x2
    ,output wire [31:0] debug_reg_x3
    ,output wire [31:0] debug_reg_x4
    ,output wire [31:0] debug_reg_x5
    ,output wire [31:0] debug_reg_x6
    ,output wire [31:0] debug_reg_x7
    ,output wire [31:0] debug_reg_x10
    ,output wire [31:0] debug_data_mem_0
);

// --- ALL INTERNAL WIRE DECLARATIONS (Declared Once at Top) ---

// IF Stage Wires
wire [31:0] if_pc_current;
wire [31:0] if_pc_next;
wire [31:0] if_instruction_out;
wire [31:0] if_pc_plus_4_out;

// IF/ID Pipeline Register Outputs
wire [31:0] id_pc_plus_4_reg;
wire [31:0] id_instruction_reg;
// ID Stage Wires (Outputs of ID stage combinational logic)
wire [31:0] id_pc_current_raw;
wire [31:0] id_read_data1_out;
wire [31:0] id_read_data2_out;
wire [31:0] id_immediate_out;

// ID Stage Instruction Field Wires (Declared here explicitly)
wire [6:0]  id_opcode_raw;
wire [4:0]  id_rd_addr_raw;
wire [2:0]  id_funct3_raw;
wire [4:0]  id_rs1_addr_raw;
wire [4:0]  id_rs2_addr_raw;
wire [6:0]  id_funct7_raw;
// ID Stage Control Wires (from Control Unit)
wire        id_reg_write_en_ctrl;
wire [1:0]  id_mem_to_reg_ctrl;
wire        id_mem_read_en_ctrl;
wire        id_mem_write_en_ctrl;
wire [1:0]  id_alu_src_b_ctrl;
wire [3:0]  id_alu_op_ctrl;
wire [1:0]  id_pc_src_ctrl;
wire        id_branch_ctrl;
wire        id_jump_ctrl;
// ID/EX Pipeline Register Outputs
wire [31:0] ex_pc_plus_4_reg;
wire [31:0] ex_read_data1_reg;
wire [31:0] ex_read_data2_reg;
wire [31:0] ex_immediate_reg;
wire [4:0]  ex_rs1_addr_reg;
wire [4:0]  ex_rs2_addr_reg;
wire [4:0]  ex_rd_addr_reg;
wire [6:0]  ex_opcode_reg;
wire [2:0]  ex_funct3_reg;
wire [6:0]  ex_funct7_reg;
wire [31:0] ex_pc_current_reg;

// EX Stage Control Wires (from ID/EX Reg)
wire        ex_reg_write_en_reg;
wire [1:0]  ex_mem_to_reg_reg;
wire        ex_mem_read_en_reg;
wire        ex_mem_write_en_reg;
wire [1:0]  ex_alu_src_b_reg;
wire [3:0]  ex_alu_op_reg;
wire [1:0]  ex_pc_src_reg;
wire        ex_branch_reg;
wire        ex_jump_reg;

// EX Stage Wires (Outputs of EX stage combinational logic)
wire [31:0] ex_alu_op1_out;
wire [31:0] ex_alu_op2_out;
wire [31:0] ex_alu_result_out;
wire        ex_alu_zero_out;
// EX Stage Target Address Wires (Declared here explicitly)
wire [31:0] ex_branch_target_addr;
wire [31:0] ex_jal_target_addr;
wire [31:0] ex_jalr_target_addr;
// EX/MEM Pipeline Register Outputs
wire [31:0] mem_pc_plus_4_reg;
wire [31:0] mem_alu_result_reg;
wire [31:0] mem_read_data2_reg;
wire [4:0]  mem_rd_addr_reg;
wire [4:0]  mem_rs2_addr_reg;
wire [6:0]  mem_opcode_reg;

// MEM Stage Control Wires (from EX/MEM Reg)
wire        mem_reg_write_en_reg;
wire [1:0]  mem_mem_to_reg_reg;
wire        mem_mem_read_en_reg;
wire        mem_mem_write_en_reg;
wire [1:0]  mem_pc_src_reg;
wire        mem_jump_reg;
wire        mem_branch_reg;
wire        mem_alu_zero_reg;

// MEM Stage Wires (Outputs of MEM stage combinational logic)
wire [31:0] mem_read_data_out;
// MEM/WB Pipeline Register Outputs
wire [31:0] wb_alu_result_reg;
wire [31:0] wb_mem_read_data_reg;
wire [31:0] wb_pc_plus_4_reg;
wire [4:0]  wb_rd_addr_reg;
wire [4:0]  wb_rs2_addr_reg;
wire [6:0]  wb_opcode_reg;

// WB Stage Control Wires (from MEM/WB Reg)
wire        wb_reg_write_en_reg;
wire [1:0]  wb_mem_to_reg_reg;

// WB Stage Wires (Outputs of WB stage combinational logic)
wire [31:0] wb_reg_write_data_out;
// ==========================================================
//  Global Parameters
// ==========================================================
// --- Local Parameters (Copied from Control Unit for visibility) ---
/* verilator lint_off UNUSEDPARAM */
localparam OPCODE_JAL    = 7'b1101111;
localparam OPCODE_JALR   = 7'b1100111;
localparam OPCODE_AUIPC  = 7'b0010111;
localparam OPCODE_BRANCH = 7'b1100011;

localparam PC_SRC_PC_PLUS_4 = 2'b00;
localparam PC_SRC_BRANCH    = 2'b01;
localparam PC_SRC_JUMP      = 2'b10;

localparam MEM_TO_REG_ALU_RESULT = 2'b00;
localparam MEM_TO_REG_MEM_DATA   = 2'b01;
localparam MEM_TO_REG_PC_PLUS_4  = 2'b10;
/* verilator lint_on UNUSEDPARAM */


// --- Module Instantiations ---

// --- IF Stage (Instruction Fetch) ---
// PC
pc_reg i_pc (
    .clk            (clk),
    .rst_n          (rst_n),
    .pc_next_i      (if_pc_next),
    .pc_write_en_i  (1'b1), // No stalling yet, so PC always writes
    .pc_o           (if_pc_current)
);
// Instruction Memory
instruction_memory i_imem (
    .addr_i  (if_pc_current),
    .instr_o (if_instruction_out)
);
assign if_pc_plus_4_out = if_pc_current + 32'd4;


// --- IF/ID Pipeline Register ---
if_id_reg i_if_id_reg (
    .clk                 (clk),
    .rst_n               (rst_n),
    .flush_i             (1'b0), // No flush/stall logic yet
    .stall_i             (1'b0),

    .if_pc_plus_4_i      (if_pc_plus_4_out),
    .if_instruction_i    (if_instruction_out),

    .id_pc_plus_4_o      (id_pc_plus_4_reg),
    .id_instruction_o    (id_instruction_reg)
);
// --- ID Stage (Instruction Decode) ---
// Extract fields from ID stage instruction (these are already declared above)
assign id_opcode_raw   = id_instruction_reg[6:0];
assign id_rd_addr_raw  = id_instruction_reg[11:7];
assign id_funct3_raw   = id_instruction_reg[14:12];
assign id_rs1_addr_raw = id_instruction_reg[19:15];
assign id_rs2_addr_raw = id_instruction_reg[24:20];
assign id_funct7_raw   = id_instruction_reg[31:25];

assign id_pc_current_raw = id_pc_plus_4_reg - 32'd4;
// PC of current instruction in ID stage

// Control Unit
control_unit i_control (
    .opcode_i        (id_opcode_raw),
    .funct3_i        (id_funct3_raw),
    .funct7_i        (id_funct7_raw),
    .reg_write_en_o  (id_reg_write_en_ctrl),
    .mem_to_reg_o    (id_mem_to_reg_ctrl),
    .mem_read_en_o   (id_mem_read_en_ctrl),
    .mem_write_en_o  (id_mem_write_en_ctrl),
    .alu_src_b_o     (id_alu_src_b_ctrl),
    .alu_op_o        (id_alu_op_ctrl),
    .pc_src_o        (id_pc_src_ctrl),
    .branch_o        (id_branch_ctrl),
    .jump_o          (id_jump_ctrl)
);
// Register File (Read rs1 and rs2, Write from WB stage)
register_file i_regfile (
    .clk            (clk),
    .rst_n          (rst_n),
    .rs1_addr_i     (id_rs1_addr_raw),
    .rs2_addr_i     (id_rs2_addr_raw),
    .rd_addr_i      (wb_rd_addr_reg),        // Write from WB stage
    .rd_data_i      (wb_reg_write_data_out), // Write from WB stage
    .reg_write_en_i (wb_reg_write_en_reg),   // Write from WB stage
    .rs1_data_o     (id_read_data1_out),
    .rs2_data_o     (id_read_data2_out),
    .debug_reg_x0   (debug_reg_x0),
    .debug_reg_x1   (debug_reg_x1),
    .debug_reg_x2   (debug_reg_x2),
    .debug_reg_x3   (debug_reg_x3),
    .debug_reg_x4   (debug_reg_x4),
    .debug_reg_x5   (debug_reg_x5),
    .debug_reg_x6   (debug_reg_x6),
    .debug_reg_x7   (debug_reg_x7),
    .debug_reg_x10  (debug_reg_x10)
);
// Immediate Generator
immediate_generator i_immgen (
    .instruction_i (id_instruction_reg),
    .imm_o         (id_immediate_out)
);
// --- ID/EX Pipeline Register ---
id_ex_reg i_id_ex_reg (
    .clk                 (clk),
    .rst_n               (rst_n),
    .flush_i             (1'b0), // No flush/stall logic yet
    .stall_i             (1'b0),

    .id_pc_plus_4_i      (id_pc_plus_4_reg),
    .id_read_data1_i     (id_read_data1_out),
    .id_read_data2_i     (id_read_data2_out),
    .id_immediate_i      (id_immediate_out),
    .id_rs1_addr_i       (id_rs1_addr_raw),
    .id_rs2_addr_i       (id_rs2_addr_raw),
    .id_rd_addr_i        (id_rd_addr_raw),
    .id_opcode_raw_i     (id_opcode_raw),
    .id_funct3_raw_i     (id_funct3_raw),
    .id_funct7_raw_i     (id_funct7_raw),

    .id_reg_write_en_i   (id_reg_write_en_ctrl),
    .id_mem_to_reg_i     (id_mem_to_reg_ctrl),
    .id_mem_read_en_i    (id_mem_read_en_ctrl),
    .id_mem_write_en_i   (id_mem_write_en_ctrl),
    .id_alu_src_b_i      (id_alu_src_b_ctrl),
    .id_alu_op_i         (id_alu_op_ctrl),
    .id_pc_src_i         (id_pc_src_ctrl),
    .id_branch_i         (id_branch_ctrl),
    .id_jump_i           (id_jump_ctrl),
    .id_pc_current_i     (id_pc_current_raw),

    .ex_pc_plus_4_o      (ex_pc_plus_4_reg),
    .ex_read_data1_o     (ex_read_data1_reg),
    .ex_read_data2_o     (ex_read_data2_reg),
    .ex_immediate_o      (ex_immediate_reg),
    .ex_rs1_addr_o       (ex_rs1_addr_reg),
    .ex_rs2_addr_o       (ex_rs2_addr_reg),
    .ex_rd_addr_o        (ex_rd_addr_reg),
    .ex_opcode_o         (ex_opcode_reg),
    .ex_funct3_o         (ex_funct3_reg),
    .ex_funct7_o         (ex_funct7_reg),

    .ex_reg_write_en_o   (ex_reg_write_en_reg),
    .ex_mem_to_reg_o     (ex_mem_to_reg_reg),
    .ex_mem_read_en_o    (ex_mem_read_en_reg),
    .ex_mem_write_en_o   (ex_mem_write_en_reg),
    .ex_alu_src_b_o      (ex_alu_src_b_reg),
    .ex_alu_op_o         (ex_alu_op_reg),
    .ex_pc_src_o         (ex_pc_src_reg),
    .ex_branch_o         (ex_branch_reg),
    .ex_jump_o           (ex_jump_reg),
    .ex_pc_current_o     (ex_pc_current_reg)
);


// --- EX Stage (Execute) ---
// ALU Operand 1 selection (Needs ex_opcode_reg)
assign ex_alu_op1_out = (ex_opcode_reg == OPCODE_AUIPC || ex_opcode_reg == OPCODE_JAL) ?
ex_pc_current_reg : ex_read_data1_reg;

// ALU Operand 2 selection
assign ex_alu_op2_out = (ex_alu_src_b_reg == 2'b00) ? ex_read_data2_reg : ex_immediate_reg;
// ALU
alu i_alu (
    .op1_i        (ex_alu_op1_out),
    .op2_i        (ex_alu_op2_out),
    .alu_op_i     (ex_alu_op_reg),
    .alu_result_o (ex_alu_result_out),
    .zero_o       (ex_alu_zero_out)
);
// PC update logic (decision made in EX, applied in IF)
// Calculate branch target address
assign ex_branch_target_addr = ex_pc_current_reg + ex_immediate_reg;
// Calculate jump target address (for JAL)
assign ex_jal_target_addr = ex_pc_current_reg + ex_immediate_reg;
// Calculate JALR target address
assign ex_jalr_target_addr = (ex_read_data1_reg + ex_immediate_reg) & 32'hFFFFFFFE;
// Mux for next PC selection (decision made in EX, applied in IF)
// This feeds back to IF stage, outside of pipeline registers
assign if_pc_next = (ex_pc_src_reg == PC_SRC_BRANCH && ex_branch_reg && ex_alu_zero_out) ?
ex_branch_target_addr : // Branch taken
                    (ex_pc_src_reg == PC_SRC_JUMP && ex_jump_reg && ex_opcode_reg == OPCODE_JAL) ?
ex_jal_target_addr : // JAL
                    (ex_pc_src_reg == PC_SRC_JUMP && ex_jump_reg && ex_opcode_reg == OPCODE_JALR) ?
ex_jalr_target_addr : // JALR
                    (if_pc_current + 32'd4);
// Default to PC+4 (no branch/jump)


// --- EX/MEM Pipeline Register ---
ex_mem_reg i_ex_mem_reg (
    .clk                 (clk),
    .rst_n               (rst_n),
    .flush_i             (1'b0), // No flush logic yet

    .ex_pc_plus_4_i      (ex_pc_plus_4_reg),
    .ex_alu_result_i     (ex_alu_result_out),
    .ex_read_data2_i     (ex_read_data2_reg),
    .ex_rd_addr_i        (ex_rd_addr_reg),
    .ex_rs2_addr_i       (ex_rs2_addr_reg),   // Pass rs2_addr
    .ex_opcode_i         (ex_opcode_reg),     // Pass opcode

    .ex_reg_write_en_i   (ex_reg_write_en_reg),
    .ex_mem_to_reg_i     (ex_mem_to_reg_reg),
    .ex_mem_read_en_i    (mem_mem_read_en_reg),
    .ex_mem_write_en_i   (ex_mem_write_en_reg),
    .ex_pc_src_i         (ex_pc_src_reg),
    .ex_jump_i           (ex_jump_reg),
    .ex_branch_i         (ex_branch_reg),
    .ex_alu_zero_i       (ex_alu_zero_out),

    .mem_pc_plus_4_o     (mem_pc_plus_4_reg),
    .mem_alu_result_o    (mem_alu_result_reg),
    .mem_read_data2_o    (mem_read_data2_reg),
    .mem_rd_addr_o       (mem_rd_addr_reg),
    .mem_rs2_addr_o      (mem_rs2_addr_reg),   // Output rs2_addr
    .mem_opcode_o        (mem_opcode_reg),     // Output opcode

    .mem_reg_write_en_o  (mem_reg_write_en_reg),
    .mem_mem_to_reg_o    (mem_mem_to_reg_reg),
    .mem_pc_src_o        (mem_pc_src_reg),
    .mem_jump_o          (mem_jump_reg),
    .mem_branch_o        (mem_branch_reg),
    .mem_alu_zero_o      (mem_alu_zero_reg)
);
// --- MEM Stage (Memory Access) ---
// Data Memory
wire [31:0] debug_dmem_mem_0;
data_memory i_dmem (
    .clk            (clk),
    .rst_n          (rst_n),
    .addr_i         (mem_alu_result_reg), // ALU result is the effective address
    .write_data_i   (mem_read_data2_reg), // Data to write (from rs2_data) for SW
    .mem_read_en_i  (mem_mem_read_en_reg),
    .mem_write_en_i (mem_mem_write_en_reg),
    .read_data_o    (mem_read_data_out),
    .debug_mem_0    (debug_dmem_mem_0)
);
// --- MEM/WB Pipeline Register ---
mem_wb_reg i_mem_wb_reg (
    .clk                 (clk),
    .rst_n               (rst_n),
    .flush_i             (1'b0), // No flush logic yet

    .mem_alu_result_i    (mem_alu_result_reg),
    .mem_mem_read_data_i (mem_read_data_out),
    .mem_pc_plus_4_i     (mem_pc_plus_4_reg),
    .mem_rd_addr_i       (mem_rd_addr_reg),
    .mem_rs2_addr_i      (mem_rs2_addr_reg), // Pass rs2_addr
    .mem_opcode_i        (mem_opcode_reg),   // Pass opcode

    .mem_reg_write_en_i  (mem_reg_write_en_reg),
    .mem_mem_to_reg_i    (mem_mem_to_reg_reg),

    .wb_alu_result_o     (wb_alu_result_reg),
    .wb_mem_read_data_o  (wb_mem_read_data_reg),
    .wb_pc_plus_4_o      (wb_pc_plus_4_reg),
    .wb_rd_addr_o        (wb_rd_addr_reg),
    .wb_rs2_addr_o       (wb_rs2_addr_reg), // Output rs2_addr
    .wb_opcode_o         (wb_opcode_reg),   // Output opcode

    .wb_reg_write_en_o   (wb_reg_write_en_reg),
    .wb_mem_to_reg_o     (wb_mem_to_reg_reg)
);
// --- WB Stage (Write Back) ---
// Data to write back to Register File
assign wb_reg_write_data_out = (wb_mem_to_reg_reg == MEM_TO_REG_MEM_DATA) ?
wb_mem_read_data_reg :     // From Data Memory (for LW)
                               (wb_mem_to_reg_reg == MEM_TO_REG_ALU_RESULT) ?
wb_alu_result_reg :    // From ALU (for R-type, I-type arith/logic, AUIPC, LUI)
                               (wb_mem_to_reg_reg == MEM_TO_REG_PC_PLUS_4) ?
wb_pc_plus_4_reg : // For JAL/JALR (link address)
                               32'hX;
// Should not happen for supported instructions


// --- Debug Outputs ---
// Connect internal states to top-level debug ports
assign debug_data_mem_0 = debug_dmem_mem_0;


endmodule