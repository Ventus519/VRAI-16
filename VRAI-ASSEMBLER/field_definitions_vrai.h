//
// Created by Ven on 6/10/26.
//

/*
 * Translate the assembly code into a normalized form, which will then be parsed into hex
 *
 *
 *
 * 4 Pass Parsing:
 * 1st pass - Formatting (remove comments, and tabs)
 * 2nd pass - Expand Instructions (and normalize)
 * 3rd pass - Labels --> Immediates
 * 4th pass - Hexdump
 *
 */

#ifndef VRAI_ASSEMBLER_FIELD_DEFINITIONS_VRAI_H
#define VRAI_ASSEMBLER_FIELD_DEFINITIONS_VRAI_H

#include <stdbool.h>
#include <stdint.h>


typedef enum UNITS
{
    UNIT_SYS = 0x0,
    UNIT_ALU = 0x1,
    UNIT_MEM = 0x2,
    UNIT_JMP = 0x3,
    UNIT_BIT = 0x4,

    UNIT_NULL = -1
} Unit;

typedef enum REGS
{
    REG_ZR = 0x0,
    REG_Q1 = 0x1,
    REG_Q2 = 0x2,
    REG_Q3 = 0x3,
    REG_Q4 = 0x4,
    REG_Q5 = 0x5,
    REG_Q6 = 0x6,
    REG_Q7 = 0x7,
    REG_Q8 = 0x8,
    REG_Q9 = 0x9,
    REG_Q10 = 0xA,
    REG_Q11 = 0xB,
    REG_Q12 = 0xC,
    REG_Q13 = 0xD,
    REG_SP = 0xE,
    REG_COND = 0xF,

    REG_NULL = -1
} Reg;

typedef enum OP_ALU
{
    ALU_CMP = 0x0,
    ALU_ASR = 0x1,
    ALU_ADD = 0x2,
    ALU_SUB = 0x3,
    ALU_LSL = 0x4,
    ALU_LSR = 0x5,
    ALU_NAND = 0x6,
    ALU_XOR = 0x7,
    ALU_CMPI = 0x8,
    ALU_ASRI = 0x9,
    ALU_ADDI = 0xA,
    ALU_SUBI = 0xB,
    ALU_LSLI = 0xC,
    ALU_LSRI = 0xD,
    ALU_NANDI = 0xE,
    ALU_XORI = 0xF,

    ALU_NULL = -1
} op_alu;

typedef enum OP_JMP
{
    JE = 0x1,
    JL = 0x2,
    JLE = 0x3,
    JB = 0x4,
    JBE = 0x5,
    JMP = 0x8,
    JNE = 0x9,
    JGE = 0xA,
    JG = 0xB,
    JAE = 0xC,
    JA = 0xD,

    JMP_NULL = -1
} op_jmp;

typedef enum OP_MEM
{
    MEM_LD_H = 0x1,
    MEM_LD_W = 0x2,
    MEM_STR_H = 0x9,
    MEM_STR_W = 0xA,

    MEM_NULL = -1
} op_mem;

typedef enum OP_BIT
{
    BIT_AND = 0x0,
    BIT_OR = 0x1,
    BIT_NOR = 0x2,
    BIT_XNOR = 0x3,
    BIT_ROL = 0x4,
    BIT_ROR = 0x5,
    BIT_CTZ = 0x6,
    BIT_CLZ = 0x7,

    BIT_ANDI = 0x8,
    BIT_ORI = 0x9,
    BIT_NORI = 0xA,
    BIT_XNORI = 0xB,
    BIT_ROLI = 0xC,
    BIT_RORI = 0xD,
    BIT_POPCNT = 0xE,

    BIT_NULL = -1
} op_bit;


typedef enum INSTR_ALIAS
{
    CALL = 0,
    PUSH = 1,
    POP = 2,
    MOV = 3,
    MOVI = 4,
} Alias;



#endif //VRAI_ASSEMBLER_FIELD_DEFINITIONS_VRAI_H

