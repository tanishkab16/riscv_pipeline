// src/ex_mem_reg.v
// EX/MEM Pipeline Register - FINAL CORRECTED VERSION (for pipelined_processor)

module ex_mem_reg (
    input wire        clk,
    input wire        rst_n,
    input wire        flush_i,

    // Inputs from EX stage
    input wire [31:0] ex_pc_plus_4_i,
    input wire [31:0] ex_alu_result_i,
    input wire [31:0] ex_read_data2_i,
    input wire [4:0]  ex_rd_addr_i,
    input wire [4:0]  ex_rs2_addr_i,   // NEW INPUT: rs2 address (for stores)
    input wire [6:0]  ex_opcode_i,     // NEW INPUT: Opcode for PC mux logic in MEM/WB

    // Inputs: Control signals from EX stage
    input wire        ex_reg_write_en_i,
    input wire [1:0]  ex_mem_to_reg_i,
    input wire        ex_mem_read_en_i,
    input wire        ex_mem_write_en_i,
    input wire [1:0]  ex_pc_src_i,
    input wire        ex_jump_i,
    input wire        ex_branch_i,
    input wire        ex_alu_zero_i,

    // Outputs to MEM stage
    output reg [31:0] mem_pc_plus_4_o,
    output reg [31:0] mem_alu_result_o,
    output reg [31:0] mem_read_data2_o,
    output reg [4:0]  mem_rd_addr_o,
    output reg [4:0]  mem_rs2_addr_o,  // NEW OUTPUT: rs2 address to MEM stage
    output reg [6:0]  mem_opcode_o,    // NEW OUTPUT: Opcode to MEM stage

    // Outputs: Control signals to MEM stage
    output reg        mem_reg_write_en_o,
    output reg [1:0]  mem_mem_to_reg_o,
    output reg        mem_mem_read_en_o,
    output reg        mem_mem_write_en_o,
    output reg [1:0]  mem_pc_src_o,
    output reg        mem_jump_o,
    output reg        mem_branch_o,
    output reg        mem_alu_zero_o
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // Clear all outputs on reset
        mem_pc_plus_4_o <= 32'h0;
        mem_alu_result_o <= 32'h0;
        mem_read_data2_o <= 32'h0;
        mem_rd_addr_o <= 5'b0;
        mem_rs2_addr_o <= 5'b0;
        mem_opcode_o <= 7'b0;

        // Clear control signals (effectively NOP)
        mem_reg_write_en_o <= 1'b0;
        mem_mem_to_reg_o <= 2'b0;
        mem_mem_read_en_o <= 1'b0;
        mem_mem_write_en_o <= 1'b0;
        mem_pc_src_o <= 2'b0;
        mem_jump_o <= 1'b0;
        mem_branch_o <= 1'b0;
        mem_alu_zero_o <= 1'b0;

    end else if (flush_i) begin
        // Clear all data outputs to 0
        mem_pc_plus_4_o <= 32'h0;
        mem_alu_result_o <= 32'h0;
        mem_read_data2_o <= 32'h0;
        mem_rd_addr_o <= 5'b0;
        mem_rs2_addr_o <= 5'b0;
        mem_opcode_o <= 7'b0;

        // Set control signals to NOP state
        mem_reg_write_en_o <= 1'b0;
        mem_mem_to_reg_o <= 2'b0;
        mem_mem_read_en_o <= 1'b0;
        mem_mem_write_en_o <= 1'b0;
        mem_pc_src_o <= 2'b0;
        mem_jump_o <= 1'b0;
        mem_branch_o <= 1'b0;
        mem_alu_zero_o <= 1'b0;

    end else begin // Normal update
        // Pass all inputs to outputs
        mem_pc_plus_4_o <= ex_pc_plus_4_i;
        mem_alu_result_o <= ex_alu_result_i;
        mem_read_data2_o <= ex_read_data2_i;
        mem_rd_addr_o <= ex_rd_addr_i;
        mem_rs2_addr_o <= ex_rs2_addr_i;
        mem_opcode_o <= ex_opcode_i;

        mem_reg_write_en_o <= ex_reg_write_en_i;
        mem_mem_to_reg_o <= ex_mem_to_reg_i;
        mem_mem_read_en_o <= ex_mem_read_en_i;
        mem_mem_write_en_o <= ex_mem_write_en_i;
        mem_pc_src_o <= ex_pc_src_i;
        mem_jump_o <= ex_jump_i;
        mem_branch_o <= ex_branch_i;
        mem_alu_zero_o <= ex_alu_zero_i;
    end
end

endmodule