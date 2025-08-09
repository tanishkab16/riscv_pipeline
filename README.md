# RISC-V 5-Stage Pipelined Processor

A 5-stage pipelined RISC-V processor built from scratch in Verilog. This project implements a core subset of the RV32I instruction set architecture and includes a complete flow for functional simulation, synthesis, and physical layout visualization. This implementation focuses on the core pipeline structure, without implementing hazard control or forwarding logic.

***

### Implemented ISA Subset

The processor is designed to execute a specific set of instructions from the RV32I ISA, as defined in the `docs/ISA_subset.md` file.

* **R-Type**: `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`
* **I-Type**: `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `lw`
* **S-Type**: `sw`
* **B-Type**: `beq`, `bne`
* **J-Type**: `jal`
* **U-Type**: `lui`, `auipc`

***

### Design Overview

The core of this project is a `pipelined_processor` module that implements a classical 5-stage pipeline: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Write-Back (WB).

The design is modular, with each stage comprising dedicated sub-modules and pipeline registers:

* **`pc_reg.v`**: The program counter, responsible for tracking the current instruction address.
* **`instruction_memory.v`**: The instruction memory that provides instructions based on the PC.
* **`if_id_reg.v`**: The pipeline register between the IF and ID stages.
* **`control_unit.v`**: Decodes instruction fields and generates all control signals.
* **`register_file.v`**: A 32x32-bit register file with two read ports and one write port.
* **`immediate_generator.v`**: Generates and sign-extends the immediate values for different instruction types.
* **`id_ex_reg.v`**: The pipeline register between the ID and EX stages.
* **`alu.v`**: The Arithmetic Logic Unit for executing arithmetic, logical, and shifting operations.
* **`ex_mem_reg.v`**: The pipeline register between the EX and MEM stages.
* **`data_memory.v`**: The data memory for handling `lw` (load word) and `sw` (store word) instructions.
* **`mem_wb_reg.v`**: The pipeline register between the MEM and WB stages.

***

### Simulation Flow

The processor's functionality was verified using a comprehensive C++ testbench (`tb/single_cycle_processor_tb.cpp`) and a Cadence simulation tool on EDA Playground.

1.  **Test Program**: The assembly program `asm/simple_program.s` was compiled to generate a machine code `.mem` file. This program contains a sequence of instructions designed to test arithmetic, memory access, and control flow.
2.  **Testbench Execution**: The `single_cycle_processor_tb` testbench instantiates the processor, applies a reset pulse, and then runs for 30 clock cycles. During this period, it dumps all key signals to a waveform file.
3.  **Final State Verification**: The testbench explicitly checks the final state of several registers (x1, x2, x3, x4, x5, x6, x7, x10) and the data memory to ensure the program executed correctly.
4.  **Waveforms**: The simulation generated `sim/single_cycle_processor_tb.vcd`, which was analyzed in a waveform viewer to debug the pipeline's behavior.

![WhatsApp Image 2025-08-02 at 00 47 33_236c6101](https://github.com/user-attachments/assets/81808263-210e-4089-bbad-5638f7eb4321)

![WhatsApp Image 2025-08-02 at 00 48 24_77e12953](https://github.com/user-attachments/assets/c723090c-aa8d-4e64-b9be-8faa63b8434e)

***

### Synthesis Flow

The design was synthesized to a gate-level netlist using the Yosys Open Synthesis Suite.

1.  **Synthesis Script**: A script named `synth.ys` was created to automate the synthesis flow. This script reads all source Verilog files, sets the `pipelined_processor` module as the top-level entity, and performs a series of optimization passes.
2.  **Conditional Compilation**: The script uses a `-D SYNTHESIS` flag to tell Yosys to ignore non-synthesizable `initial` blocks in the memory modules, ensuring a successful synthesis process.
3.  **Technology Mapping**: The script utilized the `abc` pass to map the optimized netlist to a generic technology library.
4.  **Result**: The final gate-level netlist was successfully generated in `synth/pipelined_processor_synth.v`.

***

### Final Results

The synthesis process successfully compiled the entire processor. Below are the key statistics from the final Yosys synthesis log for the `pipelined_processor` module:

* **Total Cells**: The design was implemented using a variety of logic gates and flip-flops.
    * `ORNOT` cells: 17
    * `AND` cells: 42
    * `NAND` cells: 54
    * `MUX` cells: 223
    * `XNOR` cells: 70
    * `NOT` cells: 8
    * `NOR` cells: 72
    * `OR` cells: 142
    * `ANDNOT` cells: 151
    * `XOR` cells: 113

* **Visualization**: The synthesized netlist was converted into a visual schematic using `netlistsvg`. This provided a clear diagram of the gate-level implementation, confirming the correct logical structure of the hardware.
