# VRAI-16 Assembler

This document is a work in progress. Information here is subject to change. 

This section of VRAI-16 contains the necessary files for compiling the VRAI-16 Assembler. This assembler was written in
C. 

The purpose of this document is to discuss the following:
- VRAI-16 Assembly Language
- VRAI-16 Assembler 

In particular, the first portion of this document mentions information about the assembly language. The latter portion 
focuses more on the Assembler. 

## VRAI-16 Assembly Language

### Register Names
The following names are defined by default in the assembler:
| Register Alias | Default Assembler Symbols |
|----------------|---------------------------|
| zr             | zr, q0                    |
| q1             | q1                        |
| q2             | q2                        |
| q3             | q3                        |
| q4             | q4                        |
| q5             | q5                        |
| q6             | q6                        |
| q7             | q7                        |
| q8             | q8                        |
| q9             | q9                        |
| q10            | q10                       |
| q11            | q11                       |
| q12            | q12                       |
| q13            | q13                       |
| sp             | sp, q14                   |
| COND           | COND, q15                 |



### Core Instructions
The following instructions are the core instructions to the architecture. The instructions are organized by the unit they pertain to. 

Operands in this documentation are written as "%name (type)"
The types being:
- i:U16 (unsigned 16 bit integer \[immediate\])
- R (register)
- L (label)

| Unit | Instruction Name | Operands Required                   | Description                                                     |
|------|-----------------|--------------------------------------|----------------------------------------------------------------|
| SYS  | nop              | -                                   | Architectural No-operation                                      |
| SYS  | count            | %x(i:U16), %DEST(R)                 | Stores the current value of the counter + %x into %DEST         |  
| SYS  | HALT             | -                                   | Halts program execution (stores 1 into HALT register)                 |
| ALU  | cmp              | %A(R), %B(R)                        | Compares %A with %B and stores the associated flags into COND   |
| ALU  | cmpi             | %A(R), %B(i:U16)                    |  Compares %A with %B(i:U16) and updates the flags in COND        |
| ALU  | asr              | %DEST(R), %A(R), %B(R)              | Arithmetic Shift right %A by %B\[3:0\] bits and stores in %DEST |
| ALU  | asri             | %DEST(R), %A(R), %B(i:U16)          | Arithmetic Shift Right %A by %B(i:U16)\[3:0\] bits and stores in %DEST                                                           |
| ALU  | add              | %DEST(R), %A(R), %B(R)              | Adds %A with %B and stores the result in %DEST                       |
| ALU  | addi             | %DEST(R), %A(R), %B(i:U16)          |      Adds %A with %B(i:U16) and stores the result in %DEST                                                           |
| ALU  | sub              | %DEST(R), %A(R), %B(R)                 | Subtracts %B from %A and stores the result in %DEST                |
| ALU  | subi             | %DEST(R), %A(R), %B(i:U16)             | Subtracts %B(i:U16) from %A and stores the result in %DEST         |
| ALU  | lsl              | %DEST(R), %A(R), %B(R)                 | (Logical) Shifts Left %A by %B\[3:0\] bits and stores in %DEST     |
| ALU  | lsli             | %DEST(R), %A(R), %B(i:U!6)             | (Logical) Shifts Left %A by %B(i:U16)\[3:0\] bits and stores in %DEST                                                              |
| ALU  | lsr              | %DEST(R), %A(R), %B(R)                 | Logical Shifts Right %A by %B\[3:0\] bits and stores in %DEST      |
| ALU  | lsri             | %DEST(R), %A(R), %B(i:U16)             | Logical Shifts Right %A by %B(i:U16)\[3:0\] bits and stores in %DEST                                                              |
| ALU  | nand             | %DEST(R), %A(R), %B(R)                 | Bitwise NAND %A with %B and store the result in %DEST              |
| ALU  | nandi            | %DEST(R), %A(R), %B(i:U16)             | Bitwise NAND %A with %B(i:U16) and store the result in %DEST       |
| ALU  | xor              | %DEST(R), %A(R), %B(R)                 | Bitwise XOR %A with %B and store the result in %DEST               |
| ALU  | xori             | %DEST(R), %A(R), %B(i:U16)             | Bitwise XOR %A with %B(i:U16) and store the result in %DEST        |
| MEM  | str_h            | %BASE(R), %x(i:U16), %SRC(R)           | Stores the lowest byte of %SRC into MEMORY at address %BASE + %x   |
| MEM  | str_w            | %BASE(R), %x(i:U16), %SRC(R)           | Stores the 16-bit value of %SRC into MEMORY at address %BASE + %x  |
| MEM  | ld_h             | %DEST(R), %BASE(R), %x(i:U16)          | Loads the byte from address %BASE + %x of MEMORY into %DEST        |
| MEM  | ld_w             | %DEST(R), %BASE(R), %x(i:U16)          | Loads the 16 bits from address %BASE + %x of MEMORY into %DEST     |
| JMP  | jmp              | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY unconditionally                 |
| JMP  | jmpr             | %INDIRECT(R)                           | Branches to the value in %INDIRECT unconditionally                 |
| JMP  | je               | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if the EQ bit of COND is set    |
| JMP  | jne              | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if the EQ bit of COND isn't set |
| JMP  | jb               | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if the U< bit of COND is set    |
| JMP  | jae              |  %DEST(L, i:U16)                       | Branches to DEST in PROGRAM MEMORY if the U< bit is not set        |
| JMP  | jbe              | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if EQ or U< is set              |
| JMP  | ja               | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if neither EQ nor U< is set     |
| JMP  | jl               | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if the S< of COND is set        |
| JMP  | jge              | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if S< is not set                | 
| JMP  | jle              | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if EQ or S< is set              |
| JMP  | jg               | %DEST(L, i:U16)                        | Branches to DEST in PROGRAM MEMORY if neither EQ nor S< is set     |


In addition to the above, there are also some more situational instructions for the jump unit to allow indirect branching on conditions:

| Unit | Instruction Name | Operands Required                   | Description                                                     |
|------|-----------------|--------------------------------------|----------------------------------------------------------------|
| JMP  | jer             | %DEST(R)                             | Indirect DEST version of je                                     |
| JMP  | jner            | %DEST(R)                             | Indirect DEST version of jne                                    |
| JMP  | jbr             | %DEST(R)                             | Indirect DEST version of jb                                     |
| JMP  | jaer            | %DEST(R)                             | Indirect DEST version of jae                                    |
| JMP  | jbe             | %DEST(R)                             | Indirect DEST version of jbe                                    | 
| JMP  | jar             | %DEST(R)                             | Indirect DEST version of ja                                     |
| JMP  | jlr             | %DEST(R)                             | Indirect DEST version of jl                                     |
| JMP  | jger            | %DEST(R)                             | Indirect DEST version of jge                                    |
| JMP  | jler            | %DEST(R)                             | Indirect DEST version of jle                                    | 
| JMP  | jgr             | %DEST(R)                             | Indirect DEST version of jg                                     |


While the above 4 units are enough to build a meaningful system, a standardized 5th unit exists to simplify certain bit-oriented operations:

| Unit | Instruction Name | Operands Required                   | Description                                                     |
|------|-----------------|--------------------------------------|----------------------------------------------------------------|
| BIT  | and             | %DEST(R), %A(R), %B(R)               | Bitwise AND %A with %B and store the result into %DEST          |
| BIT  | andi            | %DEST(R), %A(R), %B(i:U16)           | Bitwise AND %A with %B(i:U16) and store the result into %DEST   |
| BIT  | or              | %DEST(R), %A(R), %B(R)               | Bitwise OR %A with %B and store the result into %DEST           |
| BIT  | ori             | %DEST(R), %A(R), %B(i:U16)           | Bitwise OR %A with %B(i:U16) and store the result into %DEST    |
| BIT  | nor             | %DEST(R), %A(R), %B(R)               | Bitwise NOR %A with %B and store the result into %DEST          |
| BIT  | nori            | %DEST(R), %A(R), %B(i:U16)           | Bitwise NOR %A with %B(i:U16) and store the result into %DEST   |
| BIT  | xnor            | %DEST(R), %A(R), %B(R)               | Bitwise XNOR %A with %B and store the result into %DEST         |
| BIT  | xnori           | %DEST(R), %A(R), %B(i:U16)           | Bitwise XNOR %A with %B(i:U16) and store the result into %DEST  |
| BIT  | rol             | %DEST(R), %A(R), %B(R)               | Rotates %A left by %B\[3:0\] and store the result into %DEST    |
| BIT  | roli            | %DEST(R), %A(R), %B(i:U16)           | Rotates %A left by %B(i:U16)\[3:0\] and store the result into %DEST  |
| BIT  | ror             | %DEST(R), %A(R), %B(R)               | Rotates %A right by %B\[3:0\] and store the result into %DEST   |
| BIT  | rori            | %DEST(R), %A(R), %B(i:U16)           | Rotates %A right by %B(i:U16)\[3:0\] and store the result into %DEST  |
| BIT  | ctz             | %DEST(R), %A(R)                      | Stores the amount of terminating 0's found in %A into %DEST     |
| BIT  | clz             | %DEST(R), %A(R)                      | Stores the amount of leading 0's found in %A into %DEST         | 
| BIT  | popcnt          | %DEST(R), %A(R)                      | Stores the number of 1's found in %A into %DEST                 |


### Syntax for Core Instructions



### Instruction Aliases and Macros


## Specifics Regarding the VRAI-16 Assembler