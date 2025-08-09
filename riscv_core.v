// src/riscv_core.v
// Top-level synthesizable module for the RISC-V Pipelined Core

`timescale 1ns/1ns
`default_nettype none

`include "pipelined_processor.v"

module riscv_core (
    input wire clk,
    input wire rst_n
);

// Instantiate your pipelined processor
// Note: We are not connecting the debug outputs, as they are non-synthesizable.
pipelined_processor i_processor (
    .clk   (clk),
    .rst_n (rst_n)
);

endmodule
