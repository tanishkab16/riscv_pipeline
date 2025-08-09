// src/mem_wb_reg.v
// MEM/WB Pipeline Register - CORRECTED VERSION

module mem_wb_reg (
    input wire        clk,
    input wire        rst_n,
    input wire        flush_i,      // For control hazards (flush pipeline - also clears this register)

    // Inputs from MEM stage
    input wire [31:0] mem_alu_result_i,    // ALU result (for R-type, I-type arith/logic)
    input wire [31:0] mem_mem_read_data_i, // Data read from memory (for LW)
    input wire [31:0] mem_pc_plus_4_i,     // PC+4 (for JAL/JALR link address)
    input wire [4:0]  mem_rd_addr_i,       // rd address (for writeback)
    input wire [4:0]  mem_rs2_addr_i,      // NEW INPUT: rs2 address (for forwarding)
    input wire [6:0]  mem_opcode_i,        // NEW INPUT: opcode (for forwarding)

    // Inputs: Control signals from MEM stage
    input wire        mem_reg_write_en_i,
    input wire [1:0]  mem_mem_to_reg_i,

    // Outputs to WB stage
    output reg [31:0] wb_alu_result_o,
    output reg [31:0] wb_mem_read_data_o,
    output reg [31:0] wb_pc_plus_4_o,
    output reg [4:0]  wb_rd_addr_o,
    output reg [4:0]  wb_rs2_addr_o,       // NEW OUTPUT: rs2 address to WB stage
    output reg [6:0]  wb_opcode_o,         // NEW OUTPUT: opcode to WB stage

    // Outputs: Control signals to WB stage
    output reg        wb_reg_write_en_o,
    output reg [1:0]  wb_mem_to_reg_o
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin // Asynchronous active-low reset
        // Clear all outputs on reset
        wb_alu_result_o <= 32'h0;
        wb_mem_read_data_o <= 32'h0;
        wb_pc_plus_4_o <= 32'h0;
        wb_rd_addr_o <= 5'b0;
        wb_rs2_addr_o <= 5'b0;
        wb_opcode_o <= 7'b0;

        // Clear control signals (effectively NOP)
        wb_reg_write_en_o <= 1'b0;
        wb_mem_to_reg_o <= 2'b0;

    end else if (flush_i) begin // High priority flush (inject NOP equivalent)
        // Clear all data outputs to 0
        wb_alu_result_o <= 32'h0;
        wb_mem_read_data_o <= 32'h0;
        wb_pc_plus_4_o <= 32'h0;
        wb_rd_addr_o <= 5'b0;
        wb_rs2_addr_o <= 5'b0;
        wb_opcode_o <= 7'b0;

        // Set control signals to NOP state
        wb_reg_write_en_o <= 1'b0;
        wb_mem_to_reg_o <= 2'b0;

    end else begin // Normal update (no stall input for MEM/WB)
        // Pass all inputs to outputs
        wb_alu_result_o <= mem_alu_result_i;
        wb_mem_read_data_o <= mem_mem_read_data_i;
        wb_pc_plus_4_o <= mem_pc_plus_4_i;
        wb_rd_addr_o <= mem_rd_addr_i;
        wb_rs2_addr_o <= mem_rs2_addr_i;
        wb_opcode_o <= mem_opcode_i;

        wb_reg_write_en_o <= mem_reg_write_en_i;
        wb_mem_to_reg_o <= mem_mem_to_reg_i;
    end
end

endmodule