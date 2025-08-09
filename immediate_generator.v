// src/immediate_generator.v
// Immediate Generator module - FINAL STRUCTURAL CORRECTION (Verilog-2001)

module immediate_generator (
    input wire [31:0] instruction_i, // The 32-bit instruction
    output reg [31:0] imm_o         // The 32-bit sign-extended immediate value
);

// Define instruction opcode types
localparam OPCODE_LUI    = 7'b0110111;
localparam OPCODE_AUIPC  = 7'b0010111;
localparam OPCODE_JAL    = 7'b1101111; // J-type
localparam OPCODE_JALR   = 7'b1100111; // I-type
localparam OPCODE_BRANCH = 7'b1100011; // B-type
localparam OPCODE_LOAD   = 7'b0000011; // I-type
localparam OPCODE_STORE  = 7'b0100011; // S-type
localparam OPCODE_IMM    = 7'b0010011; // I-type (ADDI, SLTI, ANDI, etc.)

// Internal WIRES for raw immediate segments extracted from instruction_i
// These are declared at module level and assigned using continuous assignments
wire [11:0] i_imm_11_0_raw;
wire [6:0]  s_imm_11_5_raw;
wire [4:0]  s_imm_4_0_raw;

wire [12:0] b_imm_raw; // Raw 13-bit B-type immediate, before sign-extension
wire [20:0] j_imm_raw; // Raw 21-bit J-type immediate, before sign-extension
wire [11:0] s_imm_val; // Raw 12-bit S-type immediate (combined)

// Assign raw bits from instruction_i using continuous assignments (`assign` statements)
// These assignments happen concurrently, outside of any 'always' blocks
assign i_imm_11_0_raw   = instruction_i[31:20];
assign s_imm_11_5_raw   = instruction_i[31:25];
assign s_imm_4_0_raw    = instruction_i[11:7];

// B-type Raw Immediate Reassembly (13 bits)
// {imm[12], imm[11], imm[10:5], imm[4:1], imm[0]}
// From instr: {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
assign b_imm_raw = {instruction_i[31],    // imm[12]
                     instruction_i[7],     // imm[11]
                     instruction_i[30:25], // imm[10:5]
                     instruction_i[11:8],  // imm[4:1]
                     1'b0};                // imm[0] is always 0

// J-type Raw Immediate Reassembly (21 bits)
// {imm[20], imm[19:12], imm[11], imm[10:1], imm[0]}
// From instr: {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}
assign j_imm_raw = {instruction_i[31],     // imm[20]
                     instruction_i[19:12], // imm[19:12]
                     instruction_i[20],    // imm[11]
                     instruction_i[30:21], // imm[10:1]
                     1'b0};                 // imm[0] is always 0

// S-type Raw Immediate Reassembly (12 bits)
assign s_imm_val = {s_imm_11_5_raw, s_imm_4_0_raw};


// Main combinational logic to select and sign-extend the immediate
// This 'always @(*)' block assigns to 'imm_o' (a reg type)
wire [6:0] opcode = instruction_i[6:0]; // Opcode is just a slice of instruction_i

always @(*) begin
    imm_o = 32'hX; // Default output for unhandled/R-type

    case (opcode) // Use 'opcode' wire, which is derived from instruction_i
        OPCODE_LUI, OPCODE_AUIPC: begin
            // U-type: imm[31:12] = instruction_i[31:12], imm[11:0] = 0
            imm_o = {instruction_i[31:12], 12'b0};
        end
        OPCODE_JAL: begin
            // J-type: Sign-extend j_imm_raw[20]
            imm_o = {{11{j_imm_raw[20]}}, j_imm_raw}; // 11 sign bits + 21-bit raw immediate
        end
        OPCODE_JALR, OPCODE_LOAD, OPCODE_IMM: begin
            // I-type: Sign-extend i_imm_11_0_raw[11]
            imm_o = {{20{i_imm_11_0_raw[11]}}, i_imm_11_0_raw}; // 20 sign bits + 12-bit raw immediate
        end
        OPCODE_BRANCH: begin
            // B-type: Sign-extend b_imm_raw[12]
            imm_o = {{19{b_imm_raw[12]}}, b_imm_raw}; // 19 sign bits + 13-bit raw immediate
        end
        OPCODE_STORE: begin
            // S-type: Sign-extend s_imm_val[11]
            imm_o = {{20{s_imm_val[11]}}, s_imm_val}; // 20 sign bits + 12-bit raw immediate
        end
        default: begin
            imm_o = 32'hX;
        end
    endcase
end

endmodule

