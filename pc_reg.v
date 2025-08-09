// src/pc_reg.v
// Program Counter (PC) module

module pc_reg (
    input wire        clk,          // Clock signal
    input wire        rst_n,        // Asynchronous reset (active low)
    input wire [31:0] pc_next_i,    // Next PC value input
    input wire        pc_write_en_i,// Enable to update PC (for normal increment or branch/jump)
    output reg [31:0] pc_o          // Current PC value output
);

// PC register update logic
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin // Asynchronous active-low reset
        pc_o <= 32'h00000000; // Reset PC to 0
    end else if (pc_write_en_i) begin // Update PC only when enabled
        pc_o <= pc_next_i;
    end
end

endmodule
