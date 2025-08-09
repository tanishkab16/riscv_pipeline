// src/instruction_memory.v
// Instruction Memory module (Synthesizable)

module instruction_memory (
    input wire [31:0] addr_i,
    output wire [31:0] instr_o
);

// Define memory parameters
parameter MEM_SIZE = 256; // 256 words = 1KB
reg [31:0] mem [0:MEM_SIZE-1];

// Use a synthesizable read port for the memory
assign instr_o = mem[addr_i[31:2]];

`ifndef SYNTHESIS
// This initial block is for simulation only and should be handled by a .mem file for synthesis.
initial begin
    // Hardcoded instructions here (for simulation)
    mem[0] = 32'h00a00093;
    mem[1] = 32'h00508113;
    mem[2] = 32'h40510133;
    mem[3] = 32'h01400213;
    mem[4] = 32'h00400023;
    mem[5] = 32'h00002283;
    mem[6] = 32'h06400313;
    mem[7] = 32'h00828663;
    mem[8] = 32'h00130313;
    mem[9] = 32'h0c800393;
    mem[10] = 32'h0040006f;
    mem[11] = 32'h00000013;
    mem[12] = 32'hffc0006f;
end
`endif

endmodule