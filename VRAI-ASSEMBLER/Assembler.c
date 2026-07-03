//
// Created by Ven on 6/12/26.
//

#include "Assembler.h"

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

const int MAX_LINE_LEN = 2048;
const int MAX_PROGRAM_SIZE = 65536/4;
const int _MAX_SYMBOLS = 65536/4;


void trim(char* line)
{
    if (!line)
    {
        return;
    }

    char* end = line + strlen(line) - 1;

    char* start = line;
    while (isspace(*start) && start < end)
    {
        start++;
    }

    if (start != line)
    {

        //doing this instead of a memmove makes the function less prone to collapsing from indentations
        int count = 0;
        for (count = 0; start[count] != '\0'; count++)
        {
            line[count] = start[count];
        }
        line[count] = '\0';
    }


    while (end > line && isspace(*end))
    {
        *end = '\0';
        end--;
    }
}

int pre_processing(const char* src_filename, const char* dest_filename)
{
    int result = 0;


    if (!src_filename || !dest_filename)
    {
        return 1;
    }

    FILE* src = fopen(src_filename, "r");
    if (!src)
    {
        return 1;
    }

    FILE* dest = fopen(dest_filename, "w");
    if (!dest)
    {
        result = 1;
        goto SRC_FILE_CLEANUP;
    }

    {

        char line[MAX_LINE_LEN];
        char op[256], arg1[256], arg2[256], arg3[256];

        while (fgets(line, sizeof(line), src))
        {
            char* comment = strchr(line, ';');
            if (comment)
            {
                *comment = '\0';
            }
            trim(line);
            if (line[0] == '\0')
            {
                continue;
            }

            op[0] = '\0';
            arg1[0] = '\0';
            arg2[0] = '\0';
            arg3[0] = '\0';
            int tokens = sscanf(line, "%255s %255s %255s %255s", op, arg1, arg2, arg3);
            if (tokens <= 0)
            {
                continue;
            }
            int arg1_len = strlen(arg1);
            int arg2_len = strlen(arg2);

            if ((tokens > 1) && arg1[arg1_len - 1] == ',')
            {
                arg1[arg1_len - 1] = '\0';
            }
            if ((tokens > 2) && arg2[arg2_len - 1] == ',')
            {
                arg2[arg2_len - 1] = '\0';
            }

            if (strcmp(op, "call") == 0)
            {
                if (tokens != 2)
                {
                    result = 1;
                    goto DEST_FILE_CLEANUP;
                }
                fprintf(dest, "count [+16] COND\n");
                fprintf(dest, "subi sp, sp, 2\n");
                fprintf(dest, "str_w [sp+0x8000], COND\n");
                fprintf(dest, "jmp %s\n", arg1);
            }

            else if (strcmp(op, "ret") == 0)
            {
                if (tokens != 1)
                {
                    result = 1;
                    goto DEST_FILE_CLEANUP;
                }

                fprintf(dest, "ld_w COND, [sp+0x8000]\n");
                fprintf(dest, "addi sp, sp, 2\n");
                fprintf(dest, "jmpr COND\n");
            }

            else if (strcmp(op, "push") == 0)
            {
                if (tokens != 2)
                {
                    result = 1;
                    goto DEST_FILE_CLEANUP;
                }

                fprintf(dest, "subi sp, sp, 2\n");
                fprintf(dest, "str_w [sp+0x8000], %s\n", arg1);
            }

            else if (strcmp(op, "pop") == 0)
            {
                if (tokens != 2)
                {
                    result = 1;
                    goto DEST_FILE_CLEANUP;
                }
                fprintf(dest, "ld_w %s, [sp+0x8000]\n", arg1);
                fprintf(dest, "addi sp, sp, 2\n");
            }

            else if (strcmp(op, "mov") == 0)
            {
                if (tokens != 3)
                {
                    result = 1;
                    goto DEST_FILE_CLEANUP;
                }
                fprintf(dest, "addi %s, %s, 0\n", arg1, arg2);
            }

            else if (strcmp(op, "movi") == 0)
            {
                if (tokens != 3)
                {
                    result = 1;
                    goto DEST_FILE_CLEANUP;
                }
                fprintf(dest, "addi %s, zr, %s\n", arg1, arg2);
            }

            else
            {
                fprintf(dest, "%s\n", line);
            }

        }
    }

    DEST_FILE_CLEANUP:
        fclose(dest);
    SRC_FILE_CLEANUP:
        fclose(src);
    return result;
}

static int separate_tokens_in_line(char* source_line, char* dest_line)
{
    char normalized_line[MAX_LINE_LEN];
    char* src = source_line;
    char* dest = normalized_line;

    while (*src)
    {
        if (*src == '+' || *src == '[' || *src == ']' || *src == ',')
        {
            *dest++ = ' ';
            *dest++ = *src;
            *dest++ = ' ';
        }
        else if (*src == '-')
        {
            *dest++ = ' ';
            *dest++ = '+';
            *dest++ = ' ';
            *dest++ = '-';
        }
        else
        {
            *dest++ = *src;
        }
        src++;
    }
    *dest = '\0';
    strcpy(dest_line, normalized_line);
    return 0;

}

static int tokenize(char* normalized_line, char** token_stream, int MAX_TOKEN_COUNT)
{
    //return the amount of tokens
    int token_count = 0;
    char* token = strtok(normalized_line, " \t\r\n");
    while (token && token_count < MAX_TOKEN_COUNT)
    {
        strcpy(token_stream[token_count], token);
        token_count++;
        token = strtok(NULL, " \t\r\n");
    }

    return token_count;
}

static int check_token_declaration(Symbols* SYMBOL_TABLE, uint16_t counter, char** tokens, int token_count)
{
    if (!SYMBOL_TABLE || !(SYMBOL_TABLE -> TABLE) || !tokens || !tokens[0])
    {
        return 2;
    }

    if ((strcmp(tokens[0], "const") == 0) && (token_count >= 4))
    {
        //printf("FOUND CONST\n");
        uint16_t value;
        if (symbol_lookup(SYMBOL_TABLE, tokens[3], &value))
        {
            return 2;
        }
        add_symbol(SYMBOL_TABLE, _MAX_SYMBOLS, tokens[1], value);
        printf("SYMBOL %s now mapped to %d\n", tokens[1], value);
        return 1;
    }


    if (tokens[0][strlen(tokens[0]) - 1] == ':')
    {
        tokens[0][strlen(tokens[0]) - 1] = '\0';
        add_symbol(SYMBOL_TABLE, _MAX_SYMBOLS,tokens[0], counter);
        printf("SYMBOL %s now mapped to %d\n", tokens[0], counter);
        return 1;
    }

    return 0; //not a token declaration
}


int parse_line(Symbols* SYMBOL_TABLE, const char* line, uint16_t counter, OpcodeNode* opcode_tree, Program* PROGRAM)
{
    if (!line || !PROGRAM || !(PROGRAM -> INSTRUCTS) || !(SYMBOL_TABLE) || !(SYMBOL_TABLE -> TABLE))
    {
        return 1;
    }


    char temp_line[MAX_LINE_LEN];
    temp_line[0] = '\0';
    strcpy(temp_line, line);
    trim(temp_line);
    //printf("RAW: %s\n", temp_line);

    char normalized_line[MAX_LINE_LEN];
    normalized_line[0] = '\0';
    separate_tokens_in_line(temp_line, normalized_line);
    //printf("NORMALIZED: %s\n", normalized_line);

    char** tokens = malloc(sizeof(char*) * 8);
    if (!tokens)
    {
        return 1;
    }
    for (int i = 0; i < 8; i++)
    {
        tokens[i] = malloc(256);
        if (!tokens[i])
        {
            for (int k = 0; k < i; k++)
            {
                free(tokens[k]);
            }
            free(tokens);
            return 1;
        }
        tokens[i][0] = '\0';
    }

    int token_count = tokenize(normalized_line, tokens, 8);
    int result = 0;
    if (token_count == 0)
    {
        goto END;
    }


    //printf("CHECKING FOR DECLARATIONS\n");
    switch (check_token_declaration(SYMBOL_TABLE, counter, tokens, token_count))
    {
        case 0:
            {
                //printf("NO DECLARATIONS\n");
                break;
            }
        case 1:
            {
                //printf("SUCCESSFUL DECLARATION\n");
                goto END;
            }
        default: printf("BAD DECLARATION\n"); result = 1; goto END;
    }

    //not a token declaration at this point
    char* possible_opcode = tokens[0];
    OpcodeInfo* info = search_opcode_in_tree(opcode_tree, possible_opcode);
    if (!info)
    {
        printf("PROVIDED LINE: %s\n", line);
        printf("NORMALIZED LINE: %s\n", normalized_line);
        printf("Bad Opcode Provided: %s\n", possible_opcode);
        result = 1;
        goto END;
    }

    Instr* parsed = calloc(1, sizeof(Instr));
    parsed -> ADDR = counter;
    parsed -> UNIT = info -> UNIT_TYPE;

    switch (parsed -> UNIT)
    {
    case UNIT_SYS:
        {
            parsed -> FIELDS.SYS.CATEGORY = info -> OPCODE_FIELDS.SYS_CODES.CATEGORY;
            parsed -> FIELDS.SYS.CODE = info -> OPCODE_FIELDS.SYS_CODES.CODE;
            parsed -> FIELDS.SYS.USE_IMM = info -> USE_IMMEDIATE;

            if (parsed -> FIELDS.SYS.USE_IMM)
            {
                if (token_count != 6 || symbol_lookup(SYMBOL_TABLE, tokens[3], (uint16_t* ) &parsed -> FIELDS.SYS.IMM)
                    || symbol_lookup(SYMBOL_TABLE, tokens[5], (uint16_t* ) &parsed -> FIELDS.SYS.DEST))
                {
                    result = 1;
                    goto END;
                }
            }
            break;

        }
    case UNIT_ALU:
        {
            parsed -> FIELDS.ALU.CODE = info -> OPCODE_FIELDS.NON_SYS_CODES.CODE;
            parsed -> FIELDS.ALU.USE_IMM = info -> USE_IMMEDIATE;

            if (parsed -> FIELDS.ALU.CODE == ALU_CMP || parsed -> FIELDS.ALU.CODE == ALU_CMPI)
            {
                parsed -> FIELDS.ALU.DEST = REG_COND;
                if (token_count != 4 || symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.ALU.SRC_A))
                {
                    result = 1;
                    goto END;
                }
                if (parsed -> FIELDS.ALU.USE_IMM)
                {
                    if (symbol_lookup(SYMBOL_TABLE, tokens[3], (uint16_t* ) &parsed -> FIELDS.ALU.IMM))
                    {
                        result = 1;
                        goto END;
                    }
                }
                else
                {
                    if (symbol_lookup(SYMBOL_TABLE, tokens[3], (uint16_t* ) &parsed -> FIELDS.ALU.SRC_B))
                    {
                        result = 1;
                        goto END;
                    }
                }
                break;
            }

            if (token_count != 6 || symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.ALU.DEST)
                || symbol_lookup(SYMBOL_TABLE, tokens[3], (uint16_t* ) &parsed -> FIELDS.ALU.SRC_A))
            {
                result = 1;
                goto END;
            }

            if (parsed -> FIELDS.ALU.USE_IMM)
            {
                if (symbol_lookup(SYMBOL_TABLE, tokens[5], (uint16_t* ) &parsed -> FIELDS.ALU.IMM))
                {
                    result = 1;
                    goto END;
                }
            }
            else
            {
                if (symbol_lookup(SYMBOL_TABLE, tokens[5], (uint16_t* ) &parsed -> FIELDS.ALU.SRC_B))
                {
                    result = 1;
                    goto END;
                }
            }

            break;
        }
    case UNIT_MEM:
        {
            parsed -> FIELDS.MEM.CODE = info -> OPCODE_FIELDS.NON_SYS_CODES.CODE;
            if (token_count != 8)
            {
                result = 1;
                goto END;
            }

            switch (parsed -> FIELDS.MEM.CODE)
            {
            case MEM_STR_H:
            case MEM_STR_W:
                {
                    //str_w [ zr + 0x8000 ] , zr
                    if (symbol_lookup(SYMBOL_TABLE, tokens[2], (uint16_t* ) &parsed -> FIELDS.MEM.ADDR_SRC) ||
                        symbol_lookup(SYMBOL_TABLE, tokens[4], (uint16_t* ) &parsed -> FIELDS.MEM.IMM) ||
                        symbol_lookup(SYMBOL_TABLE, tokens[7], (uint16_t* ) &parsed -> FIELDS.MEM.DEST_SRC))
                    {
                        result = 1;
                        goto END;
                    }
                    break;
                }
            case MEM_LD_H:
            case MEM_LD_W:
                {
                    //ld_w zr , [ zr + 0x8000 ]
                    if (symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.MEM.DEST_SRC) ||
                        symbol_lookup(SYMBOL_TABLE, tokens[4], (uint16_t* ) &parsed -> FIELDS.MEM.ADDR_SRC) ||
                        symbol_lookup(SYMBOL_TABLE, tokens[6], (uint16_t* ) &parsed -> FIELDS.MEM.IMM))
                    {
                        result = 1;
                        goto END;
                    }
                    break;
                }
            default: result = 1; goto END;
            }

            break;
        }
    case UNIT_JMP:
        {
            parsed -> FIELDS.JMP.CODE = info -> OPCODE_FIELDS.NON_SYS_CODES.CODE;
            parsed -> FIELDS.JMP.USE_REG = !info -> USE_IMMEDIATE;
            if (token_count != 2)
            {
                result = 1;
                goto END;
            }
            if (parsed -> FIELDS.JMP.USE_REG)
            {
                if (symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.JMP.INDIRECT))
                {
                    result = 1;
                    goto END;
                }
                parsed -> FIELDS.JMP.UNRESOLVED_LABEL = NULL;
            }
            else
            {
                if (symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.JMP.IMM))
                {
                    parsed -> FIELDS.JMP.UNRESOLVED_LABEL = tokens[1];
                }
                else
                {
                    parsed -> FIELDS.JMP.UNRESOLVED_LABEL = NULL;
                }
            }
            break;
        }
    case UNIT_BIT:
        {
            parsed -> FIELDS.BIT.CODE = info -> OPCODE_FIELDS.NON_SYS_CODES.CODE;
            parsed -> FIELDS.BIT.USE_IMM = info -> USE_IMMEDIATE;

            if (parsed -> FIELDS.BIT.CODE == BIT_CLZ || parsed -> FIELDS.BIT.CODE == BIT_CTZ || parsed -> FIELDS.BIT.CODE == BIT_POPCNT)
            {
                parsed -> FIELDS.BIT.SRC_B = REG_ZR;
                if (token_count != 4 || symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.BIT.DEST))
                {
                    result = 1;
                    goto END;
                }
                if (symbol_lookup(SYMBOL_TABLE, tokens[3], (uint16_t* ) &parsed -> FIELDS.BIT.SRC_A))
                {
                    result = 1;
                    goto END;
                }

                break;
            }

            if (token_count != 6 || symbol_lookup(SYMBOL_TABLE, tokens[1], (uint16_t* ) &parsed -> FIELDS.BIT.DEST)
                || symbol_lookup(SYMBOL_TABLE, tokens[3], (uint16_t* ) &parsed -> FIELDS.BIT.SRC_A))
            {
                result = 1;
                goto END;
            }

            if (parsed -> FIELDS.BIT.USE_IMM)
            {
                if (symbol_lookup(SYMBOL_TABLE, tokens[5], (uint16_t* ) &parsed -> FIELDS.BIT.IMM))
                {
                    result = 1;
                    goto END;
                }
            }
            else
            {
                if (symbol_lookup(SYMBOL_TABLE, tokens[5], (uint16_t* ) &parsed -> FIELDS.BIT.SRC_B))
                {
                    result = 1;
                    goto END;
                }
            }

            break;
        }
    default: result = 1; goto END;
    }

    queue_instruction(PROGRAM, parsed);
    free (parsed);

    END:
    free(tokens);
    return result;


    // char* possible_opcode = tokens[0];
    // OpcodeInfo* info = search_opcode_in_tree(opcode_tree, possible_opcode);
    // if (!info)
    // {
    //     printf("Bad Opcode Provided: %s\n", possible_opcode);
    // }

    printf("Success\n");
    return 0;
}

int parse_file(const char* pre_processed_file, const char* output_file, Program* PROGRAM_DEST)
{
    int result = 0;

    if (!pre_processed_file || !output_file || !PROGRAM_DEST || !(PROGRAM_DEST->INSTRUCTS))
    {
        return 1;
    }

    FILE* src = fopen(pre_processed_file, "r");
    if (!src)
    {
        return 1;
    }

    FILE* dest = fopen(output_file, "w");
    if (!dest)
    {
        result = 1;
        goto SRC_FILE_CLEANUP;
    }


    OpcodeNode* TREE = create_opcode_tree_node();
    if (!TREE)
    {
        result = 1;
        goto END_PROGRAM;
    }
    insert_opcodes(TREE);


    Program* PROGRAM = PROGRAM_DEST;

    {
        uint16_t counter = 0;
        char line[MAX_LINE_LEN];

        Sym TABLE[_MAX_SYMBOLS];
        int SYMBOL_COUNT = 0;

        Symbols SYMBOL_TABLE;
        SYMBOL_TABLE.TABLE = TABLE;
        SYMBOL_TABLE.SYMBOL_COUNT = SYMBOL_COUNT;


        while (fgets(line, MAX_LINE_LEN, src))
        {
            int count = PROGRAM -> INSTRUCTION_COUNT;
            if (parse_line(&SYMBOL_TABLE, line, counter, TREE, PROGRAM))
            {
                result = 1;
                break;
            }
            //printf("INSTRUCTION COUNT: %d\n", PROGRAM -> INSTRUCTION_COUNT);

            if (PROGRAM -> INSTRUCTION_COUNT != count)
            {
                counter+=4;
                //print_instruction(&PROGRAM -> INSTRUCTS[PROGRAM -> INSTRUCTION_COUNT-1]);
            }
            //else
            //{
            //    printf("FOUND DECLARATION OF OBJECT\n");
            //}
            printf("\n");

        }

        //handle unresolved labels
        for (int i = 0; i < PROGRAM -> INSTRUCTION_COUNT; i++)
        {
            Instr* INSTR = &PROGRAM -> INSTRUCTS[i];
            if ((INSTR -> UNIT == UNIT_JMP) && (INSTR -> FIELDS.JMP.UNRESOLVED_LABEL != NULL))
            {
                printf("Attempting to map symbol %s\n", INSTR -> FIELDS.JMP.UNRESOLVED_LABEL);
                if (symbol_lookup(&SYMBOL_TABLE, INSTR -> FIELDS.JMP.UNRESOLVED_LABEL, (uint16_t* )&INSTR -> FIELDS.JMP.IMM))
                {
                    result = 1;
                    printf("USE OF UNDECLARED LABEL: %s\n", INSTR -> FIELDS.JMP.UNRESOLVED_LABEL);
                    break;
                }
                printf("Symbol %s remapped to value %d\n", INSTR -> FIELDS.JMP.UNRESOLVED_LABEL, INSTR -> FIELDS.JMP.IMM);
                INSTR -> FIELDS.JMP.UNRESOLVED_LABEL = NULL;
            }
            hex_instruction(&PROGRAM -> INSTRUCTS[i], dest);
        }

    }

    END_PROGRAM:
        fclose(dest);
    SRC_FILE_CLEANUP:
        fclose(src);
    return result;
}
