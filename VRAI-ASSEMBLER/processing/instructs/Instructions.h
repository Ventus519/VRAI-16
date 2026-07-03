#ifndef INSTRUCTIONS_H
#define INSTRUCTIONS_H


#include <stdio.h>

#include "../../field_definitions_vrai.h"

typedef struct INSTR
{
    Unit UNIT;
    uint16_t ADDR;

    union
    {
        struct
        {
            int8_t CATEGORY;
            int8_t CODE;
            Reg DEST;
            uint16_t IMM;
            bool USE_IMM;
        } SYS;

        struct
        {
            int8_t CODE;
            Reg DEST;
            Reg SRC_A;
            Reg SRC_B;
            uint16_t IMM;
            bool USE_IMM;
        } ALU;

        struct
        {
            int8_t CODE;
            Reg DEST_SRC;
            Reg ADDR_SRC;
            uint16_t IMM;
        } MEM;

        struct
        {
            int8_t CODE;
            Reg INDIRECT;
            uint16_t IMM;
            bool USE_REG;
            char* UNRESOLVED_LABEL;
        } JMP;

        struct
        {
            int8_t CODE;
            Reg DEST;
            Reg SRC_A;
            Reg SRC_B;
            uint16_t IMM;
            bool USE_IMM;
        } BIT;

    } FIELDS;

} Instr;

typedef struct SYMBOL
{
    char name[256];
    uint16_t value;
} Sym;

typedef struct SYMBOLS
{
    Sym* TABLE;
    int SYMBOL_COUNT;
} Symbols;

typedef struct PROGRAM
{
    Instr* INSTRUCTS;
    int INSTRUCTION_COUNT;
    int MAX_INSTRUCTIONS;
}Program;

int add_symbol(Symbols* SYMBOL_TABLE, int TABLE_MAX_SIZE, char* name, uint16_t value);
int symbol_lookup(Symbols* SYMBOL_TABLE, const char* name, uint16_t* value);

Program* create_program();
int queue_instruction(Program* PROGRAM, Instr* INSTRUCTION);
int resize_program(Program* PROGRAM);

void print_instruction(const Instr* INSTRUCTION);
int hex_instruction(const Instr* INSTRUCTION, FILE* DEST);

#endif