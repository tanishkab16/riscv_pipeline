# simple_program_scheduled.s
# Basic RISC-V program to test arithmetic, load/store, and control flow
# Statically scheduled to avoid hazards in a basic 5-stage pipeline
# (Assumes no hardware forwarding, 1-cycle stall for ALU-RAW, 1-cycle stall for Load-Use,
#  2-cycle branch flush, 1-cycle JAL flush)

.global _start
.option nopic

_start:
    # Initialize x1 with a value
    addi x1, x0, 10           # x1 = 10

    # Perform an addition (uses x1 from previous instruction)
    # ALU-RAW hazard: x1 written by previous addi. Needs 1 NOP if no forwarding.
    addi x0, x0, 0            # NOP: Stall for x1 to be written back (ALU-RAW)
    addi x2, x1, 5            # x2 = x1 + 5 = 15

    # Perform a subtraction (uses x2 from previous instruction, x1 from 3 instructions ago)
    # x2 written by previous addi. Needs 1 NOP if no forwarding.
    addi x0, x0, 0            # NOP: Stall for x2 to be written back (ALU-RAW)
    sub x3, x2, x1            # x3 = x2 - x1 = 15 - 10 = 5

    # Store a value into memory (at address 0)
    addi x4, x0, 20           # x4 = 20

    # Store instruction uses x4.
    # ALU-RAW hazard: x4 written by previous addi. Needs 1 NOP if no forwarding.
    addi x0, x0, 0            # NOP: Stall for x4 to be written back (ALU-RAW)
    sw x4, 0(x0)              # store x4 (20) at address 0 in data memory

    # Load a value back from memory
    lw x5, 0(x0)              # load word from address 0 into x5 (x5 = 20)

    # Branching test: Should NOT branch (x5 != x0)
    # Load-Use hazard: x5 loaded by previous lw. Needs 1 NOP.
    addi x0, x0, 0            # NOP: Stall for x5 to be loaded (Load-Use)

    addi x6, x0, 100          # x6 = 100 (Independent instruction, can be placed here)
                              # This instruction is now 2 cycles after LW, so x5 is ready.

    beq x5, x0, skip_branch   # if x5 == x0 (20 == 0), jump to skip_branch (should NOT take this branch)

    # Branch Delay Slots (2 NOPs for control hazard due to branch decision in EX)
    addi x0, x0, 0            # NOP: Branch delay slot 1
    addi x0, x0, 0            # NOP: Branch delay slot 2

    addi x6, x6, 1            # x6 = 101 (this line SHOULD execute, it's after the NOPs)
skip_branch:
    addi x7, x0, 200          # x7 = 200 (this line follows the non-taken branch)

    # Unconditional jump (JAL)
    jal zero_loop             # Jump to zero_loop (processor will loop here)

    # JAL Delay Slot (1 NOP for control hazard due to JAL target in ID)
    addi x0, x0, 0            # NOP: JAL delay slot 1

    # Should NOT reach here in a normal execution flow
    addi x10, x0, 300         # x10 = 300

zero_loop:
    # Infinite loop (or simple halt point for single cycle)
    addi x0, x0, 0            # NOP (effectively)
    jal zero_loop             # Loop back to zero_loop
    # JAL Delay Slot for the loop-back JAL
    addi x0, x0, 0            # NOP: JAL delay slot 1 for loop-back
