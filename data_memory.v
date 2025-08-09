// src/data_memory.v
// Data Memory module (Synthesizable)

module data_memory (
    input wire        clk,
    input wire        rst_n,
    input wire [31:0] addr_i,
    input wire [31:0] write_data_i,
    input wire        mem_read_en_i,
    input wire        mem_write_en_i,
    output wire [31:0] read_data_o,
    output wire [31:0] debug_mem_0
);

parameter MEM_SIZE = 256; // 256 words = 1KB
reg [31:0] mem [0:MEM_SIZE-1];
reg [31:0] read_data_reg;

// Synchronous write logic
always @(posedge clk) begin
    if (mem_write_en_i) begin
        mem[addr_i[31:2]] <= write_data_i;
    end
end

// Asynchronous reset and combinational read logic
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // Reset read_data_reg to 0 on active low reset
        read_data_reg <= 32'h0;
    end else if (mem_read_en_i) begin
        read_data_reg <= mem[addr_i[31:2]];
    end
end

assign read_data_o = read_data_reg;
assign debug_mem_0 = mem[0];

`ifndef SYNTHESIS
// The initial block is for simulation only and is ignored by synthesis tools.
initial begin
    // Use an integer loop variable
    integer i;
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        mem[i] = 32'h0;
    end
end
`endif

endmodule