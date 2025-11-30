# 1-TOPS-SILICON
Portal for the 1-TOPS team

# Introduction to Computer Architecture Using RISC-V

## 1. Introduction to Computer Architecture

Computer architecture is the conceptual design and fundamental operational structure of a computer system. It defines how hardware components interact and how software instructions are executed. Understanding computer architecture is essential for electrical engineers working on processor design, embedded systems, and hardware-software co-design.

### 1.1 The Von Neumann Architecture

![Von Neumann Architecture](http://computerscience.gcse.guru/wp-content/uploads/2016/04/Von-Neumann-Architecture-Diagram.jpg)

Most modern computers follow the **Von Neumann architecture**, proposed by mathematician John von Neumann in 1945. This architecture is characterized by:

- **Stored-program concept**: Both instructions and data reside in the same memory space
- **Sequential execution**: Instructions are fetched and executed one at a time in order
- **Shared bus**: A single bus transfers data, addresses, and control signals between components

The core components of the Von Neumann architecture include:

| Component | Function |
|-----------|----------|
| **Central Processing Unit (CPU)** | Executes instructions and performs calculations |
| **Memory Unit** | Stores both instructions and data |
| **Input/Output Devices** | Interface between computer and external world |
| **System Bus** | Interconnects all components for data transfer |

### 1.2 Inside the CPU

The CPU consists of three main functional units:

**Arithmetic Logic Unit (ALU)**: Performs all arithmetic operations (addition, subtraction, multiplication, division) and logical operations (AND, OR, NOT, XOR, comparisons).

**Control Unit (CU)**: Directs the operation of the processor by generating control signals that orchestrate the fetching, decoding, and execution of instructions.

**Registers**: Small, high-speed storage locations within the CPU that hold data currently being processed, addresses, and processor state information.

### 1.3 The Instruction Cycle

Every instruction goes through a fundamental cycle:

1. **Fetch**: Retrieve the instruction from memory using the Program Counter (PC)
2. **Decode**: Interpret the instruction to determine the operation and operands
3. **Execute**: Perform the specified operation in the ALU
4. **Memory Access**: Read from or write to memory if required
5. **Write Back**: Store the result in the destination register

---

## 2. RISC vs. CISC Architectures

Processor instruction set architectures (ISAs) fall into two main categories:

### 2.1 Complex Instruction Set Computing (CISC)

CISC processors, such as Intel x86, feature:
- Large instruction sets with hundreds of complex instructions
- Variable-length instructions (1 to 15+ bytes)
- Instructions that may take multiple clock cycles
- Complex addressing modes
- Fewer general-purpose registers

**Advantage**: Compact code size, fewer instructions needed for complex tasks

### 2.2 Reduced Instruction Set Computing (RISC)

RISC processors, including RISC-V and ARM, feature:
- Smaller instruction sets with simpler operations
- Fixed-length instructions (typically 32 bits)
- Most instructions execute in a single clock cycle
- Simple addressing modes (register and immediate)
- More general-purpose registers

**Advantage**: Simpler hardware, easier pipelining, lower power consumption

| Feature | RISC | CISC |
|---------|------|------|
| Instruction set size | Small (~40-100) | Large (~500-1000+) |
| Instruction length | Fixed (32-bit) | Variable |
| Cycles per instruction | Usually 1 | Multiple |
| Number of registers | More (32+) | Fewer |
| Addressing modes | Limited | Extensive |
| Pipelining efficiency | High | Lower |
| Power consumption | Lower | Higher |

---

## 3. Introduction to RISC-V

### 3.1 What is RISC-V?

**RISC-V** (pronounced "risk-five") is an open-source instruction set architecture developed at UC Berkeley starting in 2010. Unlike proprietary ISAs such as x86 or ARM, RISC-V is freely available under open-source licenses, making it ideal for:

- Academic research and education
- Custom processor design without licensing fees
- Embedded systems and IoT devices
- High-performance computing applications

### 3.2 RISC-V Design Philosophy

RISC-V was designed with several key principles:

**Modularity**: The ISA consists of a base integer instruction set plus optional extensions. Designers can select only the features needed for their application.

**Simplicity**: The base instruction set (RV32I) contains only 40 instructions, making it easy to learn and implement.

**Extensibility**: Custom instructions can be added without disrupting existing functionality.

### 3.3 RISC-V Base ISAs and Extensions

RISC-V supports multiple base configurations:

| Base ISA | Description |
|----------|-------------|
| RV32I | 32-bit integer base (40 instructions) |
| RV32E | 32-bit embedded (16 registers instead of 32) |
| RV64I | 64-bit integer base |
| RV128I | 128-bit integer base (under development) |

Common extensions include:

| Extension | Description |
|-----------|-------------|
| **M** | Integer multiplication and division |
| **A** | Atomic instructions for synchronization |
| **F** | Single-precision floating point |
| **D** | Double-precision floating point |
| **C** | Compressed 16-bit instructions |
| **G** | General-purpose (I + M + A + F + D) |

For example, **RV32IMAF** indicates a 32-bit processor with integer base, multiplication, atomics, and single-precision floating point.

---

## 4. RISC-V Registers

### 4.1 Integer Registers

RV32I provides **32 general-purpose registers**, each 32 bits wide, named x0 through x31. Register **x0** is hardwired to zeroâ€”reading it always returns 0, and writes are ignored.

| Register | ABI Name | Description | Saved By |
|----------|----------|-------------|----------|
| x0 | zero | Hardwired zero | â€” |
| x1 | ra | Return address | Caller |
| x2 | sp | Stack pointer | Callee |
| x3 | gp | Global pointer | â€” |
| x4 | tp | Thread pointer | â€” |
| x5-x7 | t0-t2 | Temporaries | Caller |
| x8 | s0/fp | Saved register / Frame pointer | Callee |
| x9 | s1 | Saved register | Callee |
| x10-x11 | a0-a1 | Arguments / Return values | Caller |
| x12-x17 | a2-a7 | Function arguments | Caller |
| x18-x27 | s2-s11 | Saved registers | Callee |
| x28-x31 | t3-t6 | Temporaries | Caller |

### 4.2 Special Registers

- **Program Counter (PC)**: Holds the address of the current instruction
- **Floating-point registers (f0-f31)**: Used with F/D extensions for floating-point operations
- **Control and Status Registers (CSRs)**: System-level registers for interrupts, exceptions, and privileged operations

---

## 5. RISC-V Instruction Formats

All RV32I instructions are exactly **32 bits** wide. The ISA defines **six instruction formats**, each with a consistent field layout that simplifies hardware decoding:

### 5.1 The Six Instruction Formats

**R-type (Register)**: For register-to-register operations
```
| funct7 (7) | rs2 (5) | rs1 (5) | funct3 (3) | rd (5) | opcode (7) |
```

**I-type (Immediate)**: For immediate operations, loads, and jalr
```
| imm[11:0] (12) | rs1 (5) | funct3 (3) | rd (5) | opcode (7) |
```

**S-type (Store)**: For store instructions
```
| imm[11:5] (7) | rs2 (5) | rs1 (5) | funct3 (3) | imm[4:0] (5) | opcode (7) |
```

**B-type (Branch)**: For conditional branches
```
| imm[12|10:5] (7) | rs2 (5) | rs1 (5) | funct3 (3) | imm[4:1|11] (5) | opcode (7) |
```

**U-type (Upper Immediate)**: For lui and auipc
```
| imm[31:12] (20) | rd (5) | opcode (7) |
```

**J-type (Jump)**: For jal (jump and link)
```
| imm[20|10:1|11|19:12] (20) | rd (5) | opcode (7) |
```

### 5.2 Field Descriptions

| Field | Bits | Description |
|-------|------|-------------|
| opcode | 7 | Identifies the instruction type |
| rd | 5 | Destination register (0-31) |
| rs1 | 5 | First source register (0-31) |
| rs2 | 5 | Second source register (0-31) |
| funct3 | 3 | Further specifies the operation |
| funct7 | 7 | Additional operation specification |
| imm | varies | Immediate (constant) value |

**Key design feature**: Source registers (rs1, rs2) and destination register (rd) always occupy the same bit positions across formats, simplifying the decode hardware.

---

## 6. RISC-V Instruction Set

### 6.1 Arithmetic Instructions

**Addition and Subtraction**:
```assembly
add  rd, rs1, rs2    # rd = rs1 + rs2
addi rd, rs1, imm    # rd = rs1 + imm (sign-extended 12-bit)
sub  rd, rs1, rs2    # rd = rs1 - rs2
```

**Multiplication and Division** (M extension):
```assembly
mul  rd, rs1, rs2    # rd = (rs1 Ã— rs2)[31:0]
div  rd, rs1, rs2    # rd = rs1 Ã· rs2 (signed)
rem  rd, rs1, rs2    # rd = rs1 mod rs2
```

### 6.2 Logical and Shift Instructions

**Logical Operations**:
```assembly
and  rd, rs1, rs2    # rd = rs1 AND rs2
or   rd, rs1, rs2    # rd = rs1 OR rs2
xor  rd, rs1, rs2    # rd = rs1 XOR rs2
andi rd, rs1, imm    # rd = rs1 AND imm
ori  rd, rs1, imm    # rd = rs1 OR imm
xori rd, rs1, imm    # rd = rs1 XOR imm
```

**Shift Operations**:
```assembly
sll  rd, rs1, rs2    # rd = rs1 << rs2 (logical left)
srl  rd, rs1, rs2    # rd = rs1 >> rs2 (logical right)
sra  rd, rs1, rs2    # rd = rs1 >> rs2 (arithmetic right)
slli rd, rs1, imm    # rd = rs1 << imm
srli rd, rs1, imm    # rd = rs1 >> imm (logical)
srai rd, rs1, imm    # rd = rs1 >> imm (arithmetic)
```

### 6.3 Load and Store Instructions

RISC-V uses **load-store architecture**â€”only load/store instructions access memory; all other operations work on registers.

```assembly
lw  rd, offset(rs1)  # rd = Memory[rs1 + offset] (32-bit word)
lh  rd, offset(rs1)  # rd = Memory[rs1 + offset] (16-bit half, sign-extended)
lb  rd, offset(rs1)  # rd = Memory[rs1 + offset] (8-bit byte, sign-extended)
sw  rs2, offset(rs1) # Memory[rs1 + offset] = rs2 (32-bit)
sh  rs2, offset(rs1) # Memory[rs1 + offset] = rs2[15:0] (16-bit)
sb  rs2, offset(rs1) # Memory[rs1 + offset] = rs2[7:0] (8-bit)
```

### 6.4 Branch Instructions

RISC-V branches compare two registers directly (no flags register):

```assembly
beq  rs1, rs2, label  # Branch if rs1 == rs2
bne  rs1, rs2, label  # Branch if rs1 != rs2
blt  rs1, rs2, label  # Branch if rs1 < rs2 (signed)
bge  rs1, rs2, label  # Branch if rs1 >= rs2 (signed)
bltu rs1, rs2, label  # Branch if rs1 < rs2 (unsigned)
bgeu rs1, rs2, label  # Branch if rs1 >= rs2 (unsigned)
```

### 6.5 Jump Instructions

```assembly
jal  rd, label        # Jump to label; rd = PC + 4 (return address)
jalr rd, rs1, offset  # Jump to rs1 + offset; rd = PC + 4
```

For function calls, use `jal ra, function_label`. To return, use `jalr zero, ra, 0`.

### 6.6 Upper Immediate Instructions

```assembly
lui   rd, imm         # rd = imm << 12 (load upper 20 bits)
auipc rd, imm         # rd = PC + (imm << 12)
```

To load a 32-bit constant into a register:
```assembly
lui  t0, 0x12345      # t0 = 0x12345000
addi t0, t0, 0x678    # t0 = 0x12345678
```

---

## 7. Assembly Programming Examples

### 7.1 Example: Computing Factorial

```assembly
# Compute factorial of n (stored in a1)
# Result returned in a0

.factorial:
    addi a0, zero, 1     # result = 1
    addi t0, zero, 1     # counter = 1

.loop:
    mul  a0, a0, t0      # result = result Ã— counter
    addi t0, t0, 1       # counter++
    bge  a1, t0, .loop   # if n >= counter, continue loop
    
    jalr zero, ra, 0     # return
```

### 7.2 Example: Array Sum

```assembly
# Sum elements of array
# a1 = base address, a2 = number of elements
# Result in a0

.array_sum:
    addi a0, zero, 0     # sum = 0
    addi t0, zero, 0     # index = 0

.sum_loop:
    lw   t1, 0(a1)       # t1 = array[index]
    add  a0, a0, t1      # sum += t1
    addi a1, a1, 4       # advance pointer
    addi t0, t0, 1       # index++
    blt  t0, a2, .sum_loop  # if index < n, continue
    
    jalr zero, ra, 0     # return
```

### 7.3 Example: Function Call with Stack

```assembly
# main calls foo(5)
.main:
    addi sp, sp, -8      # allocate stack frame
    sw   ra, 0(sp)       # save return address
    sw   s0, 4(sp)       # save s0
    
    addi a0, zero, 5     # argument = 5
    jal  ra, .foo        # call foo
    
    # result is in a0
    lw   s0, 4(sp)       # restore s0
    lw   ra, 0(sp)       # restore return address
    addi sp, sp, 8       # deallocate stack
    jalr zero, ra, 0     # return

.foo:
    mul  a0, a0, a0      # return x^2
    jalr zero, ra, 0
```

---

## 8. Memory Hierarchy

Modern computers employ a **memory hierarchy** to balance speed, capacity, and cost:

### 8.1 The Memory Pyramid

| Level | Memory Type | Typical Size | Access Time |
|-------|-------------|--------------|-------------|
| 1 | CPU Registers | ~1 KB | < 1 ns |
| 2 | L1 Cache | 32-64 KB | 1-2 ns |
| 3 | L2 Cache | 256 KB - 1 MB | 3-10 ns |
| 4 | L3 Cache | 4-32 MB | 10-20 ns |
| 5 | Main Memory (RAM) | 4-64 GB | 50-100 ns |
| 6 | Secondary Storage (SSD/HDD) | 256 GB - 8 TB | 10-10000 Âµs |

### 8.2 Cache Memory

Cache exploits the **principle of locality**:

- **Temporal locality**: Recently accessed data is likely to be accessed again soon
- **Spatial locality**: Data near recently accessed locations is likely to be accessed soon

When the CPU requests data:
1. Check L1 cache â†’ **cache hit** (fast) or miss
2. If miss, check L2 cache â†’ hit or miss
3. Continue down hierarchy until data is found
4. Copy data into higher cache levels for future access

---

## 9. Pipelining

### 9.1 The Classic 5-Stage Pipeline

Pipelining improves throughput by overlapping instruction execution. The classic RISC pipeline has five stages:

| Stage | Abbreviation | Description |
|-------|--------------|-------------|
| 1 | IF | Instruction Fetch from memory |
| 2 | ID | Instruction Decode and register read |
| 3 | EX | Execute operation in ALU |
| 4 | MEM | Memory access (load/store) |
| 5 | WB | Write Back result to register |

Without pipelining, each instruction takes 5 cycles. With pipelining, a new instruction can start every cycle, achieving up to 5Ã— throughput improvement.

### 9.2 Pipeline Hazards

**Data Hazards**: An instruction needs data that a previous instruction hasn't yet produced.
- Solution: Forwarding (bypassing), or stalling the pipeline

**Control Hazards**: Branch outcomes are unknown until the branch instruction completes.
- Solution: Branch prediction, delayed branches

**Structural Hazards**: Two instructions need the same hardware resource simultaneously.
- Solution: Resource duplication, careful scheduling

---

## 10. Summary

This tutorial introduced fundamental concepts in computer architecture using RISC-V as a practical example:

- **Von Neumann architecture** provides the foundation for modern stored-program computers
- **RISC** architectures like RISC-V prioritize simplicity, fixed instruction length, and pipelined execution
- **RISC-V** is an open-source ISA with modular design, making it ideal for education and custom implementations
- The **instruction set** includes arithmetic, logical, load/store, branch, and jump operations organized into six formats
- **Memory hierarchy** and **pipelining** are key techniques for achieving high performance

Understanding these concepts provides the foundation for advanced topics including superscalar processors, out-of-order execution, multicore architectures, and hardware-software co-design.

---

## References and Further Reading

1. Patterson, D. A., & Hennessy, J. L. *Computer Organization and Design: The Hardware/Software Interface, RISC-V Edition*. Morgan Kaufmann.

2. Waterman, A., & AsanoviÄ‡, K. (Eds.). *The RISC-V Instruction Set Manual*. RISC-V Foundation. Available at: https://riscv.org/

3. Harris, S., & Harris, D. *Digital Design and Computer Architecture: RISC-V Edition*. Morgan Kaufmann.

4. Sarangi, S. R. *Computer Organisation and Architecture*. IIT Delhi. Available at: https://www.cse.iitd.ac.in/~srsarangi/archbook/

---

*Tutorial prepared for EE undergraduate curriculum â€” Computer Architecture Module*
