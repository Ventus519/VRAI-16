# ISA Specification

The philosophy of this architecture is to outsource responsibilities to different units. Therefore, this architecture can be extended using additional execution units.

The four core units of this architecture are:
- SYSTEM
- JUMP
- ALU
- MEMORY

The SYSTEM unit deals with the overall system. This is where interrupts can be enabled, where specific subunits of the 
system can be read (as in the Program Counter vs the normal raw data registers in the register file). This mode also 
handles special system capabilities like the no-operation style and the HALT instruction.

The JUMP unit deals with control flow of the system. This unit is where unconditional and conditional jumps are handled. 
The instruction provides a condition, which is evaluated against COND to determine whether the Program Counter 
should be modified.

The ALU unit houses the ALU, which covers the main ALU operations. This unit deals with operations between RAW DATA 
registers.

The MEMORY unit handles memory access and Memory-Mapped IO.

15 Core RAW DATA registers:

| Encoding | Alias | Function          | Notes                                                        |
|----------|-------|-------------------|--------------------------------------------------------------|
| 0x0      | zr    | Hardwired 0 value |                                                              |
| 0x1      |       |                   |                                                              |
| 0x2      |       |                   |                                                              |
| 0x3      |       |                   |                                                              |
| 0x4      |       |                   |                                                              |
| 0x5      |       |                   |                                                              |
| 0x6      |       |                   |                                                              |
| 0x7      |       |                   |                                                              |
| 0x8      |       |                   |                                                              |
| 0x9      |       |                   |                                                              |
| 0xA      |       |                   |                                                              |
| 0xB      |       |                   |                                                              |
| 0xC      |       |                   |                                                              |
| 0xD      |       |                   |                                                              |
| 0xE      | sp    | Stack Pointer     |                                                              |
| 0xF      | COND  | Condition FLAGS   | (Lowest 3 bits) Interpreted as Condition FLAGS by JUMP Unit. |

The encoding 0xF is used to refer to the Condition Register. 

This COND register lies at the core of all core spaces of the processor. When considered in the ALU space, it can be 
written to (as specified before using CMP). When in the BRANCH space, reading COND is used to determine whether a jump 
should be taken. When in the SYSTEM Space, COND can be treated as an architectural state that may be preserved or 
restored. MEMORY space allows COND to be stored and restored for more versatile use.


The instruction has two strict fields, which are used to determine how to interpret the rest of the instruction bits. 
These fields being:
- UNIT \[3:0]
- CODE \[3:0]

This style implicitly defines a maximum unit space of 16 units.
The UNIT encoding for the core units is as follows:

| Encoding | Alias  |
|----------|--------|
| 0x0      | SYSTEM |
| 0x1      | ALU    |
| 0x2      | MEMORY |
| 0x3      | JUMP   |

Since these 4 units are required for the core architecture, the actual architecture allows for the addition of at most 
12 units. Additionally, the code space of 4 bits might be particularly limiting to units that perform more than 16 
different encoded operations. Those units would not be performing to their best under the constraints of this 
architecture unless specialized decoding is implemented for those units.


# SYSTEM Unit Instruction Encoding

The SYSTEM Unit is responsible for handling architectural state, machine-wide behavior, as well as execution behavior.

This unit owns access to the following:
- Program Counter (COUNT)
- Interrupt Control State (IFLAGS)

This Unit is responsible for:
- Interrupt Handling
- Saving and Restoring Architectural State
- Execution Control Operations

SYSTEM instructions include:
- nop
- HALT


### FORMAT:


| UNIT | CODE | SRC/DEST \[3:0] | SUBCODE | IMMEDIATE \[15:0] |
|------|------|-----------------|---------|-------------------|
| 0000 | cccc | -               | ssss    | -                 |

The CODE field is used to specify the category of the SYSTEM instruction. The SUBCODE field is used to further refine 
the operation that will take place.

In particular, the nop instruction is encoded as an instruction with all bit-fields of 0. The HALT instruction is 
encoded similarly to the nop instruction, except an all-1 subcode field.

# ALU Instruction Encoding

This unit handles basic arithmetic and logic operations between raw data values, interpreted as integers.

### FORMAT:
| UNIT | CODE | DEST | rA   | rB   | X \[11:0] | 
|------|------|------|------|------|-----------|
| 0001 | cccc | dddd | AAAA | BBBB | -         |

Operand B can be chosen to be an immediate operand using the CODE field. The highest bit of the code field is used to 
indicate that Operand B should use the immediate representation.

This immediate representation uses the lowest 16 bits of the instruction to form the immediate. 
The previous operand, rB, no longer is used to represent a register encoding.

This usage of the code field, in turn, limits the amount of operations that can be performed by the ALU. 
The following is a list of the base ALU operations:


| CODE | ALIAS | DESC                                                  | NOTES                          |     |
|------|-------|-------------------------------------------------------|--------------------------------|-----|
| 0x0  | CMP   | Compares A and B and stores the flag result in 3 bits | See (CMP)                      |     |
| 0x1  | ASR   | Arithmetic Shifts the value A Right by B bits.        | Uses lower 4 bits of B         |     |
| 0x2  | ADD   | A + B                                                 |                                |     |
| 0x3  | SUB   | A - B                                                 |                                |     |
| 0x4  | LSL   | A << B                                                | Uses lower 4 bits of B         |     |
| 0x5  | LSR   | A >> B                                                | Uses lower 4 bits of B         |     |
| 0x6  | NAND  | Logical NAND between A and B                          |                                |     |
| 0x7  | XOR   | Logical XOR between A and B                           |                                |     |
| 0x8  | CMPi  | Compares A with the immediate B                       | See (CMP)                      |     |
| 0x9  | ASRi  | Arithmetic Shifts A Right by immediate B              | Uses lower 4 bits of immediate |     |
| 0xA  | ADDi  | A + B(imm)                                            |                                |     |
| 0xB  | SUBi  | A - B(imm)                                            |                                |     |
| 0xC  | LSLi  | A << B(imm)                                           | Uses lower 4 bits of immediate |     |
| 0xD  | LSRi  | A >> B(imm)                                           | Uses lower 4 bits of immediate |     |
| 0xE  | NANDi | Logical NAND between A and immediate B                |                                |     |
| 0xF  | XORi  | Logical XOR between A and immediate B                 |                                |     |

(CMP)
The CMP (and CMPi) instruction always requires the dest operand to be 0xF (indicating a write to COND). Using a 
different dest operand is undefined behavior for this architecture.

The output of CMP results in the following format:

| bit | ALIAS | NOTES                       |
|-----|-------|-----------------------------|
| 0   | EQ    | CMP found A == B            |
| 1   | U<    | A (unsigned) < B (unsigned) |
| 2   | S<    | A (signed) < B(signed)      |

All other bits of the result are assumed to be 0.

# MEMORY Unit Instruction Encoding
Similar to how the SYSTEM Unit owns Internal Architectural State, the MEMORY Unit owns External Architectural State.

The MEMORY Unit handles external memory operations, including Memory-Mapped IO. In particular, MEMORY is separated into 
two different segments:
- Address 0x0000 ~ 0x7FFF: Standard External Memory
- Address 0x8000 ~ 0xFFFF: Device Memory (for IO Devices)

The MEMORY Unit streams a value into a specified address. This value may be a byte or word (16-bit) value. 
In particular, this architecture stores information using big-endian data.

### FORMAT:
| UNIT | CODE | SRC/DEST \[3:0] | ADDR \[3:0] | OFFSET \[15:0] | 
|------|------|-----------------|-------------|----------------|
| 0010 | cccc | -               | -           | -              |

The SRC/DEST operand is used to specify where the data should go. When storing data, this register is treated as the 
provider of the data to store. When loading data, this register is the destination to load the data.

The 16-bit offset is a signed offset applied on the address found in the ADDR operand. This offsetting is governed by 
the MEMORY Unit and not the ALU.

The highest bit of the CODE operand is used to determine whether the fundamental action is loading (0) or storing (1).

The lower 3 bits further refine the operation in the following manner:

| CODE \[2:0] | Operation Type | 
|-------------|----------------|
| 000         | Reserved       |
| 001         | 1 byte data    |
| 010         | 2 byte data    |
| 011         | Reserved       |
| 100         | Reserved       |
| 101         | Reserved       |
| 110         | Reserved       |
| 111         | Reserved       |

Memory should be aligned to the largest amount of bytes being used by the system. By default, this is 2-byte alignment.
# JUMP Unit Instruction Encoding

### FORMAT:

| UNIT | CODE | regTARGET \[3:0] | Reserved | IMMEDIATE \[15:0] |
|------|------|------------------|----------|-------------------|
| 0011 | cccc | -                | -        |                   |


### JUMP CODES

| CODE | ALIAS | NOTES                                |
|------|-------|--------------------------------------|
| 0000 | njmp  | Never Used                           | 
| 0001 | je    | Jump if CMP found A == B             |
| 0010 | jl    | Jump if A (signed) < B (signed)      |
| 0011 | jle   | Jump if A (signed) <= B (signed)     |
| 0100 | jb    | Jump if A (unsigned) < B (unsigned)  |
| 0101 | jbe   | Jump if A (unsigned) <= B (unsigned) |
| 0110 | X     | Invalid                              |
| 0111 | X     | Invalid                              |
| 1000 | jmp   | Unconditional                        |
| 1001 | jne   | Jump if A != B                       |
| 1010 | jge   | Jump if A (signed) >= B (signed)     |
| 1011 | jg    | Jump if A (signed) > B (signed)      |
| 1100 | jae   | Jump if A (unsigned) >= B (unsigned) |
| 1101 | ja    | Jump if A (unsigned) > B (unsigned)  |
| 1110 | X     | Invalid                              |
| 1111 | X     | Invalid                              |

The FLAGS stored in COND are mapped as follows:

| bit | ALIAS | NOTES                       |
|-----|-------|-----------------------------|
| 0   | EQ    | CMP found A == B            |
| 1   | U<    | A (unsigned) < B (unsigned) |
| 2   | S<    | A (signed) < B(signed)      |

The regTARGET operand is used to make indirect jumps. Every jump is technically an indirect jump, where direct jumps 
are done using regTARGET = 0000. The counter is updated with the value in regTARGET offset by the immediate provided, 
assuming the condition was met. 