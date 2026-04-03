
# risc-v_rv32i
this project is an implementation of a 32 bit processor in verilog based on rv32i subset of the RISC-V  ISA . 
# RISC-V Multi-Cycle Processor — Datapath (RV32I)

A fully functional **multi-cycle RISC-V RV32I datapath** implemented in Verilog, designed for FPGA deployment and educational use. This module is the hardware core of a multi-cycle processor — all control signals are driven externally by a FSM-based control unit.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Module Interface](#module-interface)
- [Datapath Components](#datapath-components)
- [Supported Instructions](#supported-instructions)
- [Parameters](#parameters)
- [Signal Reference](#signal-reference)
- [Debug Interface](#debug-interface)
- [File Structure](#file-structure)
- [Simulation](#simulation)
- [FPGA Synthesis](#fpga-synthesis)

---

## Overview

This datapath implements the **execution core** of a multi-cycle RISC-V processor. Unlike a single-cycle design, the multi-cycle approach reuses hardware across clock cycles — the same ALU handles both address calculation and arithmetic, and the same memory bus services both instruction fetch and data access (in separate cycles).

Control signals (`pc_write`, `mem_enable`, `alu_in_sel`, etc.) are provided externally by a finite state machine (FSM) control unit that sequences operations over multiple clock cycles per instruction.


## Architecture

The datapath follows a **shared-bus multi-cycle** organization:

```
                   ┌──────────┐
         ┌────────►│    PC    │◄── pc_next (mux_pc)
         │         └────┬─────┘
         │              │ pc_curr
         │    ┌─────────▼──────────┐     ┌──────────────┐
         │    │  Instruction Mem   │────►│   Decoder    │─► opcode/funct3/funct7
         │    └────────────────────┘     └──────────────┘
         │                                      │
         │    ┌────────────────────┐     ┌──────▼───────┐
         │    │   Register File   │◄────│  Imm Extend  │
         │    │  rs1 / rs2 / rd   │     │  (12/20-bit) │
         │    └────────┬──────────┘     └──────────────┘
         │             │ rs1_data / rs2_data
         │    ┌────────▼──────────┐
         │    │       ALU         │──► alu_result / zero_flag
         │    └────────┬──────────┘
         │             │
         │    ┌────────▼──────────┐     ┌──────────────┐
         │    │    Data Memory    │────►│  Load Unit   │
         │    └───────────────────┘     └──────┬───────┘
         │                                     │ lsu_out
         │    ┌───────────────────┐            │
         └────│    WB Mux         │◄───────────┘
              │ (alu_res / lsu)   │
              └───────────────────┘
<img width="940" height="456" alt="image" src="https://github.com/user-attachments/assets/3815f4e0-cdc6-47b3-af21-5ed879a0d2b5" />

```

### PC Selection Logic

The next PC is selected by a 4-to-1 mux based on `{is_jump, sign_ext_sel_20bit | branch_taken}`:

| `sel[1]` (is_jump) | `sel[0]` (branch/20bit) | Next PC         | Instruction     |
|--------------------|--------------------------|-----------------|-----------------|
| 0                  | 0                        | `PC + 4`        | Normal          |
| 0                  | 1                        | `PC + imm_SB`   | Branch taken    |
| 1                  | 0                        | `ALU result`    | JALR            |
| 1                  | 1                        | `PC + imm_UJ`   | JAL             |

---

## Module Interface

```verilog
module datapath #(
    parameter width               = 32,
              instr_mem_addr_width = 9,
              instr_mem_depth      = 512,
              regfile_depth        = 32,
              data_width           = 32,
              data_mem_depth       = 512,
              data_mem_addr_width  = 9
)(
    // Clock and Reset
    input  clk, reset,

    // Control Signals (driven by FSM Control Unit)
    input  alu_in_sel,          // 0=rs2_data, 1=sign_ext_imm_12
    input  pc_write,            // enable PC register update
    input  mem_enable,          // data memory enable
    input  mem_rd_wr_bar,       // 1=read, 0=write
    input  reg_write_en,        // register file write enable
    input  reg_write_sel,       // 0=ALU result, 1=memory load
    input  is_branch,           // branch instruction flag
    input  is_jump,             // jump instruction flag
    input  sign_ext_sel_20bit,  // 0=12-bit imm, 1=20-bit imm (JAL)
    input  [1:0] sign_ext_sel_12bit, // 00=I-type, 01=S-type, 10=SB-type
    input  [3:0] alu_control,   // ALU operation select

    // Debug Interface
    input  debug_en,
    input  [4:0]  regfile_debug_addr,
    output [31:0] debug_regfile_data,

    // Outputs to Control Unit (for FSM decoding)
    output [6:0] opcode,
    output [2:0] funct3,
    output [6:0] funct7
);
```

---

## Datapath Components

| Instance      | Module              | Description                                          |
|---------------|---------------------|------------------------------------------------------|
| `PC`          | `pipo_reg`          | Program Counter register with synchronous reset and enable |
| `pc_inc`      | `pc_adder`          | Computes `PC + 4` (next sequential instruction)      |
| `IM`          | `instr_mem`         | Synchronous instruction memory (BRAM inferred)       |
| `RF`          | `regfile`           | 32×32 register file, x0 hardwired to 0              |
| `mux_imm`     | `mux3_to_1`         | Selects between I-type, S-type, SB-type immediates  |
| `sign_extender_module_12bit` | `sign_extender` | Sign-extends 12-bit immediates to 32-bit   |
| `sign_extender_module_20bit` | `sign_extender` | Sign-extends 20-bit immediates to 32-bit   |
| `branch_target_calc` | `pc_adder`   | Computes branch/jump target: `PC + offset`          |
| `mux_pc`      | `mux4_to_1`         | Selects next PC from {PC+4, branch target, ALU, JAL target} |
| `ALU`         | `alu`               | 32-bit ALU with zero flag output                    |
| `branch`      | `branch_handler`    | Evaluates branch condition using funct3 + ALU flags |
| `lsu`         | `load_store_unit`   | Handles byte/half/word load & store alignment       |
| `DM`          | `data_mem`          | Synchronous data memory with byte-enable writes     |

---

## Supported Instructions

| Type    | Instructions                                           |
|---------|--------------------------------------------------------|
| R-type  | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU     |
| I-type  | ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI |
| Load    | LW, LH, LB, LHU, LBU                                  |
| Store   | SW, SH, SB                                             |
| Branch  | BEQ, BNE, BLT, BGE, BLTU, BGEU                        |
| Jump    | JAL, JALR                                              |

---

## Parameters

| Parameter              | Default | Description                              |
|------------------------|---------|------------------------------------------|
| `width`                | 32      | Data bus width (bits)                    |
| `instr_mem_addr_width` | 9       | Instruction memory address bits          |
| `instr_mem_depth`      | 512     | Instruction memory depth (words)         |
| `regfile_depth`        | 32      | Number of registers                      |
| `data_width`           | 32      | Data memory word width (bits)            |
| `data_mem_depth`       | 512     | Data memory depth (words)                |
| `data_mem_addr_width`  | 9       | Data memory address bits                 |

> Total addressable instruction memory: 512 × 4 = **2 KB**  
> Total addressable data memory: 512 × 4 = **2 KB**

---

## Signal Reference

### Control Inputs

| Signal               | Width | Description                                         |
|----------------------|-------|-----------------------------------------------------|
| `alu_in_sel`         | 1     | `0` = rs2 data into ALU B; `1` = sign-extended immediate |
| `pc_write`           | 1     | High to update PC on next rising edge               |
| `mem_enable`         | 1     | Enable data memory access                           |
| `mem_rd_wr_bar`      | 1     | `1` = read; `0` = write                             |
| `reg_write_en`       | 1     | Enable write to register file                       |
| `reg_write_sel`      | 1     | `0` = write ALU result; `1` = write memory load     |
| `is_branch`          | 1     | Marks instruction as branch (enables branch logic)  |
| `is_jump`            | 1     | Marks instruction as jump (JAL/JALR)                |
| `sign_ext_sel_20bit` | 1     | `0` = use 12-bit offset; `1` = use 20-bit (JAL)    |
| `sign_ext_sel_12bit` | 2     | `00`=I-type, `01`=S-type, `10`=SB-type immediate   |

### Datapath Outputs to Control Unit

| Signal    | Width | Description                               |
|-----------|-------|-------------------------------------------|
| `opcode`  | 7     | `instr[6:0]` — used by FSM to decode instr type |
| `funct3`  | 3     | `instr[14:12]` — operation variant         |
| `funct7`  | 7     | `instr[31:25]` — R-type operation modifier |

---

## Debug Interface

The datapath exposes a read port for register file inspection during simulation and FPGA debugging:

```verilog
// To read register x15 at runtime:
debug_en            = 1;
regfile_debug_addr  = 5'd15;
// debug_regfile_data now holds the value of x15
```

When `debug_en = 1`, the `rs1_addr` port of the register file is overridden with `regfile_debug_addr`, and `debug_regfile_data` outputs the corresponding register value. This does **not** interfere with normal instruction execution when `debug_en = 0`.

---

## File Structure

```
risc-v
├── datapath.v              
├── alu.v                   ← 32-bit ALU
│── regfile.v               ← 32×32 Register File
├── instr_mem.v             ← Instruction Memory (BRAM)
├── data_mem.v              ← Data Memory (BRAM)
│── pipo_reg.v              ← Parameterized D Flip-Flop register
│── pc_adder.v              ← Simple 32-bit adder for PC
├── sign_extender.v         ← Parameterized sign extension
├── mux.v                   ← 2-to-1 MUX
|── mux3_to_1.v             ← 3-to-1 MUX
├── mux4_to_1.v             ← 4-to-1 MUX
├── branch_handler.v        ← Branch condition evaluator
└── load_store_unit.v       ← Byte/Half/Word load-store alignment

│ tb_datapath.v           ← Simulation testbench
├─ bench/
│ *.hex                   ← RISC-V program hex files
└── README.md
```

---

## Simulation

### Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) `>= 11`
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)

### Compile and Run

```bash
# Compile all sources
iverilog -o *v

# Run simulation
vvp out

# View waveform
gtkwave tb.vcd
```

### Loading a Program

Place your assembled RISC-V hex file in `bench/` and load it in the testbench:

```verilog
$readmemh("bench/bubble_sort.hex", dut.IM.mem);
```

To assemble a RISC-V program:

```bash
riscv32-unknown-elf-as program.s -o program.o
riscv32-unknown-elf-objcopy -O ihex program.o program.hex
```

---

## FPGA Synthesis

Tested on **Xilinx Basys3** (Artix-7 XC7A35T) using Vivado 2023.2.

### Important Notes

- `instr_mem` and `data_mem` are written to infer **Block RAM (BRAM)**. Ensure the synchronous read pattern is preserved to avoid LUTRAM inference.
- The `(* mark_debug = "true" *)` attribute can be added to internal signals for **ILA (Integrated Logic Analyzer)** probing in Vivado.
- `pc_curr[10:2]` is used for word-aligned memory addressing — this maps the 32-bit byte-address PC to a 9-bit word address (bits [10:2]).

## Notes

- **x0 is hardwired to 0** inside `regfile.v` — writes to x0 are ignored.
- The LSU handles **sub-word memory accesses**: byte (`LB`/`SB`), halfword (`LH`/`SH`), and word (`LW`/`SW`) with proper sign/zero extension on loads and byte-lane steering on stores.
- This module is the **Phase 0 baseline** for a branch prediction comparison project. A 5-stage pipelined version with hazard detection and forwarding is developed in Phase 1.
