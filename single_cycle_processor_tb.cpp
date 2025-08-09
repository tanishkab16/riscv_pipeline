// tb/single_cycle_processor_tb.cpp
#include <iostream>
#include <fstream>   // For reading memory files
#include <string>
#include <vector>
#include <iomanip>   // For std::hex, std::setw, std::setfill

#include <verilated.h>           // Defines common Verilator constructs
#include <verilated_vcd_c.h>     // For VCD tracing (waveform output)
#include "Vsingle_cycle_processor.h" // Include header for your Verilated top module

// Global simulation time variable (Verilator requirement)
vluint64_t main_time = 0;

double sc_time_stamp() { // Called by $time in Verilog
    return main_time;
}

// Function to load instruction memory from .mem file
void load_instruction_memory(Vsingle_cycle_processor* dut, const std::string& filename) {
    std::ifstream ifs(filename);
    if (!ifs.is_open()) {
        std::cerr << "Error: Could not open instruction memory file: " << filename << std::endl;
        exit(1);
    }

    std::string line;
    uint32_t addr = 0;
    // Accessing instruction memory by its internal name in the generated obj_dir
    // The Verilated memory is usually directly exposed as dut->i_imem->mem if i_imem is /*public*/
    // BUT since we're exposing it via top-level ports due to issues, we must load into the original instr_memory module's mem array.
    // Verilator creates V<ModuleName>__Syms struct that contains pointers to child modules.
    // It's usually accessible via dut->_module_name->instance_name->mem
    // e.g. dut->i_imem->mem[addr/4] is how it should work if it were public.
    // This is where Verilator's hiding of internal members gets tricky.
    // The best way here is to make `instruction_memory` accept `readmemh` directly in its source.
    // We'll rely on the original instruction_memory.v's $readmemh to handle loading.
    // So this function is actually NOT needed IF instruction_memory.v handles it via $readmemh.
    // Let's remove content from this function and rely on $readmemh.
    // This function will be called just for display, not actual loading.
    std::cout << "Instruction memory loaded by Verilog $readmemh from " << filename << std::endl;
}


int main(int argc, char** argv, char** env) {
    // 1. Initialize Verilator (parse command line arguments etc.)
    Verilated::commandArgs(argc, argv);

    // 2. Instantiate your top module (DUT)
    Vsingle_cycle_processor* dut = new Vsingle_cycle_processor;

    // 3. Enable VCD tracing (for waveform output)
    Verilated::traceEverOn(true); // Enable tracing (VCD)
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99); // Trace all signals (99 levels deep)
    tfp->open("sim/single_cycle_processor_tb.vcd"); // Output VCD file

    // 4. Load Instruction Memory from file (This is now handled by instruction_memory.v's initial block)
    // We still call it here to keep the file open for Verilator's $readmemh
    // The instruction_memory.v's $readmemh expects the file to be accessible relative to the simulation run directory.
    // Verilator documentation implies $readmemh is handled by Verilator itself.

    // 5. Test Sequence
    // Initialize inputs
    dut->clk = 0;
    dut->rst_n = 0; // Assert reset

    // Dump initial state (at time 0)
    dut->eval();
    tfp->dump(main_time);

    // Apply reset pulse
    main_time += 10; // Advance time to after reset pulse
    dut->rst_n = 1; // De-assert reset
    dut->eval();
    tfp->dump(main_time);

    // Run for enough clock cycles to execute the simple program
    const int SIM_CYCLES = 30; // Run for 30 clock cycles

    for (int i = 0; i < SIM_CYCLES; ++i) {
        // Positive edge
        main_time += 5; // Half clock cycle
        dut->clk = 1;
        dut->eval(); // Evaluate the combinational logic and positive edge triggered FFs
        tfp->dump(main_time);

        // Negative edge
        main_time += 5; // Half clock cycle
        dut->clk = 0;
        dut->eval(); // Evaluate the combinational logic and negative edge triggered FFs
        tfp->dump(main_time);
    }

    // 6. Simulation Finished - Display Final State
    std::cout << "--- Simulation Finished ---" << std::endl;
    std::cout << "Final Register Values:" << std::endl;
    // Accessing the new top-level debug ports
    std::cout << "x0 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x0 << std::endl;
    std::cout << "x1 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x1 << std::endl;
    std::cout << "x2 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x2 << std::endl;
    std::cout << "x3 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x3 << std::endl;
    std::cout << "x4 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x4 << std::endl;
    std::cout << "x5 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x5 << std::endl;
    std::cout << "x6 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x6 << std::endl;
    std::cout << "x7 : " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x7 << std::endl;
    std::cout << "x10: " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_reg_x10 << std::endl;

    std::cout << "Data Memory at address 0x0: " << std::hex << std::setw(8) << std::setfill('0') << dut->debug_data_mem_0 << std::endl;


    // 7. Cleanup
    tfp->close(); // Close VCD file
    delete tfp;   // Free VCD tracer memory
    delete dut;   // Free DUT memory
    return 0;     // Exit with success
}