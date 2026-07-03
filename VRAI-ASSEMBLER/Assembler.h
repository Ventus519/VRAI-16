//
// Created by Ven on 6/12/26.
//

#ifndef VRAI_ASSEMBLER_H
#define VRAI_ASSEMBLER_H

#include "processing/instructs/Instructions.h"
#include "field_definitions_vrai.h"
#include <stdlib.h>
#include "processing/AsciiTree.h"

void trim(char* line);
int pre_processing(const char* src_filename, const char* dst_filename);
int parse_line(Symbols* SYMBOL_TABLE, const char* line, uint16_t counter,
    OpcodeNode* opcode_tree, Program* PROGRAM);
int parse_file(const char* pre_processed_file, const char* output_file, Program* PROGRAM_DEST);




#endif //VRAI_ASSEMBLER_H
