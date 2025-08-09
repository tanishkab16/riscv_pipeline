# RISC-V RV32I Processor - Initial ISA Subset

This document outlines the minimal subset of RV32I instructions to be implemented for the initial functional processor. Expanding beyond these instructions will occur only after the core pipeline with hazard detection and forwarding is fully verified.

**1. R-Type (Register-Register Operations):**
* `add`: Add
* `sub`: Subtract
* `and`: Bitwise AND
* `or`: Bitwise OR
* `xor`: Bitwise XOR
* `sll`: Shift Left Logical
* `srl`: Shift Right Logical
* `sra`: Shift Right Arithmetic

**2. I-Type (Immediate Operations):**
* `addi`: Add Immediate
* `andi`: Bitwise AND Immediate
* `ori`: Bitwise OR Immediate
* `xori`: Bitwise XOR Immediate
* `slli`: Shift Left Logical Immediate
* `srli`: Shift Right Logical Immediate
* `srai`: Shift Right Arithmetic Immediate
* `lw`: Load Word (from memory)

**3. S-Type (Store Operations):**
* `sw`: Store Word (to memory)

**4. B-Type (Branch Operations):**
* `beq`: Branch if Equal
* `bne`: Branch if Not Equal

**5. J-Type (Jump Operations):**
* `jal`: Jump and Link

**6. U-Type (Upper Immediate Operations):**
* `lui`: Load Upper Immediate
* `auipc`: Add Upper Immediate to PC

---
**Future Expansion (After Core Functionality is Verified):**
* `slt`, `sltu`, `slti`, `sltiu` (Set Less Than)
* `blt`, `bge`, `bltu`, `bgeu` (More Branch Types)
* `jalr` (Jump and Link Register)
* System Call/Privileged instructions (if ambitious, much later)