// src/id_ex_reg.v
// ID/EX Pipeline Register - Corrected with opcode, funct3, funct7 ports

module id_ex_reg (
    input wire        clk,
    input wire        rst_n,
    input wire        flush_i,      // For control hazards (flush pipeline)
    input wire        stall_i,      // For data hazards (stall pipeline)

    // Inputs from ID stage
    input wire [31:0] id_pc_plus_4_i,    // PC+4 from ID stage
    input wire [31:0] id_read_data1_i,   // Read data from rs1
    input wire [31:0] id_read_data2_i,   // Read data from rs2
    input wire [31:0] id_immediate_i,    // Immediate value
    input wire [4:0]  id_rs1_addr_i,     // rs1 address
    input wire [4:0]  id_rs2_addr_i,     // rs2 address
    input wire [4:0]  id_rd_addr_i,      // rd address
    input wire [6:0]  id_opcode_raw_i,   // Opcode
    input wire [2:0]  id_funct3_raw_i,   // Funct3
    input wire [6:0]  id_funct7_raw_i,   // Funct7

    // Inputs: Control signals from Control Unit (ID stage)
    input wire        id_reg_write_en_i,
    input wire [1:0]  id_mem_to_reg_i,
    input wire        id_mem_read_en_i,
    input wire        id_mem_write_en_i,
    input wire [1:0]  id_alu_src_b_i,
    input wire [3:0]  id_alu_op_i,
    input wire [1:0]  id_pc_src_i,
    input wire        id_branch_i,
    input wire        id_jump_i,
    input wire [31:0] id_pc_current_i, // PC_current from IF/ID (for AUIPC/JAL)

    // Outputs to EX stage
    output reg [31:0] ex_pc_plus_4_o,
    output reg [31:0] ex_read_data1_o,
    output reg [31:0] ex_read_data2_o,
    output reg [31:0] ex_immediate_o,
    output reg [4:0]  ex_rs1_addr_o,
    output reg [4:0]  ex_rs2_addr_o,
    output reg [4:0]  ex_rd_addr_o,
    output reg [6:0]  ex_opcode_o,
    output reg [2:0]  ex_funct3_o,
    output reg [6:0]  ex_funct7_o,

    // Outputs: Control signals to EX stage
    output reg        ex_reg_write_en_o,
    output reg [1:0]  ex_mem_to_reg_o,
    output reg        ex_mem_read_en_o,
    output reg        ex_mem_write_en_o,
    output reg [1:0]  ex_alu_src_b_o,
    output reg [3:0]  ex_alu_op_o,
    output reg [1:0]  ex_pc_src_o,
    output reg        ex_branch_o,
    output reg        ex_jump_o,
    output reg [31:0] ex_pc_current_o
);

// NOP value for injecting into pipeline
localparam NOP_INSTRUCTION = 32'h00000013; // addi x0, x0, 0

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin // Asynchronous active-low reset
        // Clear all outputs on reset
        ex_pc_plus_4_o <= 32'h0;
        ex_read_data1_o <= 32'h0;
        ex_read_data2_o <= 32'h0;
        ex_immediate_o <= 32'h0;
        ex_rs1_addr_o <= 5'b0;
        ex_rs2_addr_o <= 5'b0;
        ex_rd_addr_o <= 5'b0;
        ex_opcode_o <= 7'b0; // Corrected
        ex_funct3_o <= 3'b0; // Corrected
        ex_funct7_o <= 7'b0; // Corrected

        // Clear control signals (effectively NOP)
        ex_reg_write_en_o <= 1'b0;
        ex_mem_to_reg_o <= 2'b0;
        ex_mem_read_en_o <= 1'b0;
        ex_mem_write_en_o <= 1'b0;
        ex_alu_src_b_o <= 2'b0;
        ex_alu_op_o <= 4'b0;
        ex_pc_src_o <= 2'b0;
        ex_branch_o <= 1'b0;
        ex_jump_o <= 1'b0;
        ex_pc_current_o <= 32'h0;

    end else if (flush_i) begin // High priority flush (inject NOP)
        // Clear all data outputs
        ex_pc_plus_4_o <= 32'h0;
        ex_read_data1_o <= 32'h0;
        ex_read_data2_o <= 32'h0;
        ex_immediate_o <= 32'h0;
        ex_rs1_addr_o <= 5'b0;
        ex_rs2_addr_o <= 5'b0;
        ex_rd_addr_o <= 5'b0;
        ex_opcode_o <= 7'b0; // Corrected
        ex_funct3_o <= 3'b0; // Corrected
        ex_funct7_o <= 7'b0; // Corrected

        // Set control signals to NOP state
        ex_reg_write_en_o <= 1'b0;
        ex_mem_to_reg_o <= 2'b0;
        ex_mem_read_en_o <= 1'b0;
        ex_mem_write_en_o <= 1'b0;
        ex_alu_src_b_o <= 2'b0;
        ex_alu_op_o <= 4'b0;
        ex_pc_src_o <= 2'b0;
        ex_branch_o <= 1'b0;
        ex_jump_o <= 1'b0;
        ex_pc_current_o <= 32'h0;
    end else if (~stall_i) begin // Only update if not stalled
        // Pass all inputs to outputs
        ex_pc_plus_4_o <= id_pc_plus_4_i;
        ex_read_data1_o <= id_read_data1_i;
        ex_read_data2_o <= id_read_data2_i;
        ex_immediate_o <= id_immediate_i;
        ex_rs1_addr_o <= id_rs1_addr_i;
        ex_rs2_addr_o <= id_rs2_addr_i;
        ex_rd_addr_o <= id_rd_addr_i;
        ex_opcode_o <= id_opcode_raw_i; // Corrected
        ex_funct3_o <= id_funct3_raw_i; // Corrected
        ex_funct7_o <= id_funct7_raw_i; // Corrected

        ex_reg_write_en_o <= id_reg_write_en_i;
        ex_mem_to_reg_o <= id_mem_to_reg_i;
        ex_mem_read_en_o <= id_mem_read_en_i;
        ex_mem_write_en_o <= id_mem_write_en_i;
        ex_alu_src_b_o <= id_alu_src_b_i;
        ex_alu_op_o <= id_alu_op_i;
        ex_pc_src_o <= id_pc_src_i;
        ex_branch_o <= id_branch_i;
        ex_jump_o <= id_jump_i;
        ex_pc_current_o <= id_pc_current_i;
    end
end

endmodule