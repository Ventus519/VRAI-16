//
// Created by Ven on 6/11/26.
//

#include "AsciiTree.h"

void print_opcode_info(const OpcodeInfo* opcode)
{
    if (!opcode)
    {
        printf("Bad Opcode Provided \n");
        return;
    }
    char* unit_name;
    char* code_name;
    char* subcode_name;

    switch (opcode -> UNIT_TYPE)
    {
        case UNIT_SYS:
            {
                unit_name = "sys";
                switch (opcode -> OPCODE_FIELDS.SYS_CODES.CATEGORY)
                {
                case 0:
                    {
                        code_name = "execution";
                        switch (opcode -> OPCODE_FIELDS.SYS_CODES.CODE)
                        {
                        case 0: subcode_name = "nop"; break;
                        case 0xF: subcode_name = "HALT"; break;
                        default: subcode_name = "n/a"; break;
                        }

                        break;
                    }
                case 1:
                    {
                        code_name = "access";
                        switch (opcode -> OPCODE_FIELDS.SYS_CODES.CODE)
                        {
                        case 0: subcode_name = "count"; break;
                        default: subcode_name = "n/a"; break;
                        }

                        break;
                    }
                default: code_name = "n/a"; subcode_name = "n/a"; break;
                }

                break;
            }
        case UNIT_ALU:
            {
                unit_name = "alu";
                subcode_name = "n/a";

                switch (opcode -> OPCODE_FIELDS.NON_SYS_CODES.CODE)
                {
                case ALU_CMP: code_name = "cmp"; break;
                case ALU_ASR: code_name = "asr"; break;
                case ALU_ADD: code_name = "add"; break;
                case ALU_SUB: code_name = "sub"; break;
                case ALU_LSR: code_name = "lsr"; break;
                case ALU_LSL: code_name = "lsl"; break;
                case ALU_NAND: code_name = "nand"; break;
                case ALU_XOR: code_name = "xor"; break;
                case ALU_CMPI: code_name = "cmpi"; break;
                case ALU_ASRI: code_name = "asri"; break;
                case ALU_ADDI: code_name = "addi"; break;
                case ALU_SUBI: code_name = "subi"; break;
                case ALU_LSRI: code_name = "lsri"; break;
                case ALU_LSLI: code_name = "lsli"; break;
                case ALU_NANDI: code_name = "nandi"; break;
                case ALU_XORI: code_name = "xori"; break;
                default: code_name = "n/a"; break;
                }

                break;
            }
        case UNIT_MEM: unit_name = "mem"; code_name = "n/a"; subcode_name = "n/a"; break;
        case UNIT_JMP: unit_name = "jmp"; code_name = "n/a"; subcode_name = "n/a"; break;
        case UNIT_NULL: unit_name = "n/a"; code_name = "n/a"; subcode_name = "n/a"; break;
        default: unit_name = NULL; code_name = NULL; subcode_name = NULL; break;
    }

    if (!unit_name || !code_name || !subcode_name)
    {
        return;
    }

    printf("UNIT: %s, CODE: %s, SUBCODE: %s, USES IMMEDIATE?: %d\n",
        unit_name, code_name, subcode_name, opcode -> USE_IMMEDIATE);

}

OpcodeNode* create_opcode_tree_node()
{
    OpcodeNode* node = malloc(sizeof(OpcodeNode));
    if (!node)
    {
        return NULL;
    }

    for (int i = 0; i < 128; i++)
    {
        node -> possible_attachment[i] = NULL;
    }
    node -> valid_end = false;
    node -> opcode = NULL;

    return node;
}

int insert_opcode(OpcodeNode* root, const char* str_name, const Unit unit, const int8_t code, const int8_t subcode, bool USE_IMMEDIATE)
{
    if (!root || !str_name)
    {
        return EXIT_FAILURE;
    }

    OpcodeInfo* info = malloc(sizeof(OpcodeInfo));
    if (!info)
    {
        return EXIT_FAILURE;
    }
    info -> UNIT_TYPE = unit;
    switch (unit)
    {
    case UNIT_SYS:
        {
            info -> OPCODE_FIELDS.SYS_CODES.CATEGORY = code;
            info -> OPCODE_FIELDS.SYS_CODES.CODE = subcode;
            break;
        }
    case UNIT_NULL:
        {
            break;
        }
    default:
        {
            info -> OPCODE_FIELDS.NON_SYS_CODES.CODE = code;
            break;
        }
    }
    info -> USE_IMMEDIATE = USE_IMMEDIATE;

    OpcodeNode* current = root;
    for (int i = 0; str_name[i] != '\0'; i++)
    {
        const char c = str_name[i];
        if (!current -> possible_attachment[c])
        {
            OpcodeNode* child = create_opcode_tree_node();
            if (!child)
            {
                free(child);
                free(info);
                return EXIT_FAILURE;
            }
            current -> possible_attachment[c] = child;
        }
        current = current -> possible_attachment[c];
    }
    current -> valid_end = true;
    current -> opcode = info;

    return EXIT_SUCCESS;
}

int insert_opcode_from_info(OpcodeNode* root, const char* str_name, const OpcodeInfo* opcode)
{
    if (!root || !opcode || !str_name)
    {
        return EXIT_FAILURE;
    }

    OpcodeInfo* info = malloc(sizeof(OpcodeInfo));
    if (!info)
    {
        return EXIT_FAILURE;
    }

    const Unit unit = opcode -> UNIT_TYPE;
    const int8_t category = opcode -> OPCODE_FIELDS.SYS_CODES.CATEGORY;
    const int8_t subcode = opcode -> OPCODE_FIELDS.SYS_CODES.CODE;
    const int8_t code = opcode -> OPCODE_FIELDS.NON_SYS_CODES.CODE;
    const bool USE_IMMEDIATE = opcode -> USE_IMMEDIATE;

    info -> UNIT_TYPE = unit;
    switch (unit)
    {
    case UNIT_SYS:
        {
            info -> OPCODE_FIELDS.SYS_CODES.CATEGORY = category;
            info -> OPCODE_FIELDS.SYS_CODES.CODE = subcode;
            break;
        }
    case UNIT_NULL:
        {
            break;
        }
    default:
        {
            info -> OPCODE_FIELDS.NON_SYS_CODES.CODE = code;
            break;
        }
    }
    info -> USE_IMMEDIATE = USE_IMMEDIATE;

    OpcodeNode* current = root;
    for (int i = 0; str_name[i] != '\0'; i++)
    {
        const char c = str_name[i];
        if (!current -> possible_attachment[c])
        {
            OpcodeNode* child = create_opcode_tree_node();
            if (!child)
            {
                free(child);
                free(info);
                return EXIT_FAILURE;
            }
            current -> possible_attachment[c] = child;
        }
        current = current -> possible_attachment[c];
    }
    current -> valid_end = true;
    current -> opcode = info;

    return EXIT_SUCCESS;

}

OpcodeInfo* search_opcode_in_tree(OpcodeNode* root, const char* str_name)
{
    if (!root || !str_name)
    {
        return NULL;
    }

    OpcodeNode* current = root;
    for (int i = 0; str_name[i] != '\0'; i++)
    {
        const char c = str_name[i];
        if (!current -> possible_attachment[c])
        {
            printf("%c was not a valid next character. ", c);
            printf("%s was not a valid code. ", str_name);
            return NULL;
        }
        current = current -> possible_attachment[c];
    }

    if (current -> valid_end == false)
    {
        printf("%s was not a valid code. ", str_name);
        return NULL;
    }

    return current -> opcode;
}

static void insert_sys_opcodes(OpcodeNode* root)
{
    if (!root)
    {
        return;
    }
    OpcodeInfo base;

    base.UNIT_TYPE = UNIT_SYS;
    base.OPCODE_FIELDS.SYS_CODES.CATEGORY = 0x0;
    base.OPCODE_FIELDS.SYS_CODES.CODE = 0x0;
    base.USE_IMMEDIATE = false;
    insert_opcode_from_info(root, "nop", &base);

    base.OPCODE_FIELDS.SYS_CODES.CODE = 0xF;
    insert_opcode_from_info(root, "HALT", &base);

    base.OPCODE_FIELDS.SYS_CODES.CATEGORY = 0x1;
    base.OPCODE_FIELDS.SYS_CODES.CODE = 0x0;
    base.USE_IMMEDIATE = true;
    insert_opcode_from_info(root, "count", &base);
}

static void insert_alu_opcodes(OpcodeNode* root)
{
    if (!root)
    {
        return;
    }
    OpcodeInfo base;
    base.UNIT_TYPE = UNIT_ALU;

    base.USE_IMMEDIATE = false;
    for (op_alu op = ALU_CMP; op <= ALU_XOR; op++)
    {
        base.OPCODE_FIELDS.NON_SYS_CODES.CODE = op;
        char* name;
        switch (op)
        {
        case ALU_CMP: name = "cmp"; break;
        case ALU_ASR: name = "asr"; break;
        case ALU_ADD: name = "add"; break;
        case ALU_SUB: name = "sub"; break;
        case ALU_LSL: name = "lsl"; break;
        case ALU_LSR: name = "lsr"; break;
        case ALU_NAND: name = "nand"; break;
        case ALU_XOR: name = "xor"; break;
        default: name = "unknown"; break;
        }
        insert_opcode_from_info(root, name, &base);
    }

    base.USE_IMMEDIATE = true;
    for (op_alu op = ALU_CMPI; op <= ALU_XORI; op++)
    {
        base.OPCODE_FIELDS.NON_SYS_CODES.CODE = op;
        char* name;
        switch (op)
        {
        case ALU_CMPI: name = "cmpi"; break;
        case ALU_ASRI: name = "asri"; break;
        case ALU_ADDI: name = "addi"; break;
        case ALU_SUBI: name = "subi"; break;
        case ALU_LSLI: name = "lsli"; break;
        case ALU_LSRI: name = "lsri"; break;
        case ALU_NANDI: name = "nandi"; break;
        case ALU_XORI: name = "xori"; break;
        default: name = "unknown"; break;
        }
        insert_opcode_from_info(root, name, &base);
    }
}

static void insert_mem_opcodes(OpcodeNode* root)
{
    if (!root)
    {
        return;
    }

    OpcodeInfo base;
    base.UNIT_TYPE = UNIT_MEM;
    base.USE_IMMEDIATE = true;

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = MEM_LD_H;
    insert_opcode_from_info(root, "ld_h", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = MEM_LD_W;
    insert_opcode_from_info(root, "ld_w", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = MEM_STR_H;
    insert_opcode_from_info(root, "str_h", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = MEM_STR_W;
    insert_opcode_from_info(root, "str_w", &base);

}

static void insert_jmp_opcodes(OpcodeNode* root)
{
    if (!root)
    {
        return;
    }
    OpcodeInfo base;
    base.UNIT_TYPE = UNIT_JMP;
    base.USE_IMMEDIATE = true;

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JE;
    insert_opcode_from_info(root, "je", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JL;
    insert_opcode_from_info(root, "jl", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JLE;
    insert_opcode_from_info(root, "jle", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JB;
    insert_opcode_from_info(root, "jb", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JBE;
    insert_opcode_from_info(root, "jbe", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JMP;
    insert_opcode_from_info(root, "jmp", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JNE;
    insert_opcode_from_info(root, "jne", &base);


    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JGE;
    insert_opcode_from_info(root, "jge", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JG;
    insert_opcode_from_info(root, "jg", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JAE;
    insert_opcode_from_info(root, "jae", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JA;
    insert_opcode_from_info(root, "ja", &base);

    base.USE_IMMEDIATE = false;
    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JE;
    insert_opcode_from_info(root, "jer", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JL;
    insert_opcode_from_info(root, "jlr", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JLE;
    insert_opcode_from_info(root, "jler", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JB;
    insert_opcode_from_info(root, "jbr", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JBE;
    insert_opcode_from_info(root, "jber", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JMP;
    insert_opcode_from_info(root, "jmpr", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JNE;
    insert_opcode_from_info(root, "jner", &base);


    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JGE;
    insert_opcode_from_info(root, "jger", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JG;
    insert_opcode_from_info(root, "jgr", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JAE;
    insert_opcode_from_info(root, "jaer", &base);

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = JA;
    insert_opcode_from_info(root, "jar", &base);
}

static void insert_bit_opcodes(OpcodeNode* root)
{
    if (!root)
    {
        return;
    }

    OpcodeInfo base;

    base.UNIT_TYPE = UNIT_BIT;
    base.USE_IMMEDIATE = false;

    for (op_bit op = BIT_AND; op <= BIT_CLZ; op++)
    {
        base.OPCODE_FIELDS.NON_SYS_CODES.CODE = op;
        char* name;
        switch (op)
        {
        case BIT_AND: name = "and"; break;
        case BIT_OR: name = "or"; break;
        case BIT_NOR: name = "nor"; break;
        case BIT_XNOR: name = "xnor"; break;
        case BIT_ROL: name = "rol"; break;
        case BIT_ROR: name = "ror"; break;
        case BIT_CTZ: name = "ctz"; break;
        case BIT_CLZ: name = "clz"; break;
        default: name = "unknown"; break;
        }
        insert_opcode_from_info(root, name, &base);
    }

    base.OPCODE_FIELDS.NON_SYS_CODES.CODE = BIT_POPCNT;
    insert_opcode_from_info(root, "popcnt", &base);

    base.USE_IMMEDIATE = true;
    for (op_bit op = BIT_ANDI; op < BIT_POPCNT; op++)
    {
        base.OPCODE_FIELDS.NON_SYS_CODES.CODE = op;
        char* name;
        switch (op)
        {
        case BIT_ANDI: name = "andi"; break;
        case BIT_ORI: name = "ori"; break;
        case BIT_NORI: name = "nori"; break;
        case BIT_XNORI: name = "xnori"; break;
        case BIT_ROLI: name = "roli"; break;
        case BIT_RORI: name = "rori"; break;
        default: name = "unknown"; break;
        }
        insert_opcode_from_info(root, name, &base);
    }

}

void insert_opcodes(OpcodeNode* tree)
{
    insert_sys_opcodes(tree);
    insert_alu_opcodes(tree);
    insert_mem_opcodes(tree);
    insert_jmp_opcodes(tree);
    insert_bit_opcodes(tree);
}
