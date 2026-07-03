//
// Created by Ven on 6/11/26.
//

#ifndef VRAI_ASSEMBLER_ASCIITREE_H
#define VRAI_ASSEMBLER_ASCIITREE_H

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#include "../field_definitions_vrai.h"

typedef struct OPCODE_INFO
{
    Unit UNIT_TYPE;

    union
    {
        struct SYS_STYLE
        {
            int8_t CATEGORY;
            int8_t CODE;
        } SYS_CODES;

        struct NON_SYS
        {
            int8_t CODE;
        } NON_SYS_CODES;
    } OPCODE_FIELDS;

    bool USE_IMMEDIATE;

} OpcodeInfo;

typedef struct ASCII_TREE_NODE AsciiOpcodeTreeNode;
typedef struct ASCII_TREE_NODE OpcodeNode;

struct ASCII_TREE_NODE
{
    AsciiOpcodeTreeNode* possible_attachment [128];
    OpcodeInfo* opcode;
    bool valid_end;
};

void print_opcode_info(const OpcodeInfo* opcode);

OpcodeNode* create_opcode_tree_node();
int insert_opcode(OpcodeNode* root, const char* str_name, Unit unit,
                  int8_t code, int8_t subcode, bool USE_IMMEDIATE); //deprecated

int insert_opcode_from_info(OpcodeNode* root, const char* str_name, const OpcodeInfo* opcode);

OpcodeInfo* search_opcode_in_tree(OpcodeNode* root, const char* str_name);

void insert_opcodes(OpcodeNode* tree);

#endif //VRAI_ASSEMBLER_ASCIITREE_H
