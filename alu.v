// src/alu.v
// Arithmetic Logic Unit (ALU) module

module alu (
    input wire [31:0] op1_i,         // First operand
    input wire [31:0] op2_i,         // Second operand
    input wire  [3:0] alu_op_i,      // ALU operation code (control signal)
    output reg [31:0] alu_result_o,  // ALU result
    output reg        zero_o         // Zero flag (result is 0)
);

// Define ALU operation codes (these are arbitrary, will be determined by Control Unit)
// You can use parameter for better readability later, or localparam inside alu.v
localparam ALU_ADD  = 4'b0000; // ADD
localparam ALU_SUB  = 4'b0001; // SUB
localparam ALU_AND  = 4'b0010; // AND
localparam ALU_OR   = 4'b0011; // OR
localparam ALU_XOR  = 4'b0100; // XOR
localparam ALU_SLL  = 4'b0101; // Shift Left Logical
localparam ALU_SRL  = 4'b0110; // Shift Right Logical
localparam ALU_SRA  = 4'b0111; // Shift Right Arithmetic
localparam ALU_SLT  = 4'b1000; // Set Less Than (signed)
localparam ALU_SLTU = 4'b1001; // Set Less Than Unsigned
localparam ALU_COPY_B = 4'b1111; // For cases where op2 is just passed through (e.g., LUI, JAL, etc.)

// ALU combinational logic
always @(*) begin
    alu_result_o = 32'hX; // Default to X (unknown) for unhandled operations
    zero_o = 1'b0;       // Default zero flag to 0

    case (alu_op_i)
        ALU_ADD:    alu_result_o = op1_i + op2_i;
        ALU_SUB:    alu_result_o = op1_i - op2_i;
        ALU_AND:    alu_result_o = op1_i & op2_i;
        ALU_OR:     alu_result_o = op1_i | op2_i;
        ALU_XOR:    alu_result_o = op1_i ^ op2_i;
        ALU_SLL:    alu_result_o = op1_i << op2_i[4:0]; // Shift amount is 5 bits
        ALU_SRL:    alu_result_o = op1_i >> op2_i[4:0];
        ALU_SRA:    alu_result_o = $signed(op1_i) >>> op2_i[4:0]; // Signed right shift
        ALU_SLT:    alu_result_o = ($signed(op1_i) < $signed(op2_i)) ? 32'h1 : 32'h0;
        ALU_SLTU:   alu_result_o = (op1_i < op2_i) ? 32'h1 : 32'h0;
        ALU_COPY_B: alu_result_o = op2_i; // Pass through op2 (e.g., for AUIPC/LUI where ALU just needs immediate)
        default:    alu_result_o = 32'hX; // Handle unexpected op_codes
    endcase

    // Set zero flag
    if (alu_result_o == 32'h0) begin
        zero_o = 1'b1;
    end
end

endmodule
