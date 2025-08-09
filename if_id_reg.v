// src/if_id_reg.v
// IF/ID Pipeline Register

module if_id_reg (
    input wire        clk,
    input wire        rst_n,
    input wire        flush_i,      // For control hazards (flush pipeline)
    input wire        stall_i,      // For data hazards (stall pipeline)

    // Inputs from IF stage
    input wire [31:0] if_pc_plus_4_i, // PC+4 from IF stage
    input wire [31:0] if_instruction_i, // Instruction from IF stage

    // Outputs to ID stage
    output reg [31:0] id_pc_plus_4_o,
    output reg [31:0] id_instruction_o
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin // Asynchronous active-low reset
        id_pc_plus_4_o <= 32'h0;
        id_instruction_o <= 32'h0; // Or NOP (32'h00000013 for addi x0,x0,0)
    end else if (flush_i) begin // High priority flush
        id_pc_plus_4_o <= 32'h0;
        id_instruction_o <= 32'h00000013; // Inject a NOP (addi x0,x0,0)
    end else if (~stall_i) begin // Only update if not stalled
        id_pc_plus_4_o <= if_pc_plus_4_i;
        id_instruction_o <= if_instruction_i;
    end
end

endmodule