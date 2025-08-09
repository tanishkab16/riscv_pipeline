// src/register_file.v
// Register File module (32 x 32-bit registers)

module register_file (
    input wire        clk,           // Clock signal
    input wire        rst_n,         // Asynchronous reset (active low)

    // Read Ports
    input wire  [4:0] rs1_addr_i,    // Address of rs1 register (5 bits for 0-31)
    input wire  [4:0] rs2_addr_i,    // Address of rs2 register

    // Write Port
    input wire  [4:0] rd_addr_i,     // Address of rd register
    input wire [31:0] rd_data_i,     // Data to write to rd register
    input wire        reg_write_en_i, // Register write enable signal

    output wire [31:0] rs1_data_o,   // Data read from rs1 register
    output wire [31:0] rs2_data_o,    // Data read from rs2 register
    
    // New Debug Outputs
    output wire [31:0] debug_reg_x0,
    output wire [31:0] debug_reg_x1,
    output wire [31:0] debug_reg_x2,
    output wire [31:0] debug_reg_x3,
    output wire [31:0] debug_reg_x4,
    output wire [31:0] debug_reg_x5,
    output wire [31:0] debug_reg_x6,
    output wire [31:0] debug_reg_x7,
    output wire [31:0] debug_reg_x10
);

// Declare the register array
reg [31:0] registers [0:31]; // 32 registers, each 32-bit wide

// Explicitly declare loop variable i
integer i;
// Asynchronous Reset and Initialization
`ifndef SYNTHESIS
initial begin
    // Initialize all registers to 0 at the start of simulation
    // This helps ensure reproducible simulation results.
    for  (i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'h0;
    end
end
`endif

// Register write logic (synchronous write)
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin // Asynchronous active-low reset
        `ifndef SYNTHESIS
        // On reset, clear all registers (optional, but good practice for full reset)
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'h0;
        end
        `endif
    end else if (reg_write_en_i) begin // Write only when enabled
        // Do not write to x0 (register 0)
        if (rd_addr_i != 5'b00000) begin
            registers[rd_addr_i] <= rd_data_i;
        end
    end
end

// Register read logic (combinational read)
// Read from rs1_addr_i
assign rs1_data_o = (rs1_addr_i == 5'b00000) ? 32'h0 : registers[rs1_addr_i];

// Read from rs2_addr_i
assign rs2_data_o = (rs2_addr_i == 5'b00000) ? 32'h0 : registers[rs2_addr_i];

// Connect internal registers to new debug outputs
assign debug_reg_x0  = registers[0];
assign debug_reg_x1  = registers[1];
assign debug_reg_x2  = registers[2];
assign debug_reg_x3  = registers[3];
assign debug_reg_x4  = registers[4];
assign debug_reg_x5  = registers[5];
assign debug_reg_x6  = registers[6];
assign debug_reg_x7  = registers[7];
assign debug_reg_x10 = registers[10];

endmodule