#include "Instructions.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int add_symbol(Symbols* SYMBOL_TABLE, int TABLE_MAX_SIZE,  char* name, uint16_t value)
{
   if (!SYMBOL_TABLE || !(SYMBOL_TABLE -> TABLE) || !name )
   {
      return 1;
   }

   for (int i = 0; i < TABLE_MAX_SIZE; i++)
   {
      if (strcmp(name, SYMBOL_TABLE -> TABLE[i].name) == 0)
      {
         SYMBOL_TABLE -> TABLE[i].value = value;
         return 0;
      }
   }

   if (SYMBOL_TABLE -> SYMBOL_COUNT == TABLE_MAX_SIZE)
   {
      return 2;
   }

   strcpy(SYMBOL_TABLE -> TABLE[SYMBOL_TABLE -> SYMBOL_COUNT].name, name);
   SYMBOL_TABLE -> TABLE[SYMBOL_TABLE -> SYMBOL_COUNT].value = value;
   SYMBOL_TABLE -> SYMBOL_COUNT++;

   return 0;
}

static int symbol_reg_lookup(const char* name, uint16_t* value)
{
   if (strcmp(name, "zr") == 0)
   {
      *value = (uint16_t) REG_ZR;
      return 0;
   }
   if (strcmp(name, "sp") == 0)
   {
      *value = (uint16_t) REG_SP;
      return 0;
   }
   if (strcmp(name, "COND") == 0)
   {
      *value = (uint16_t) REG_COND;
      return 0;
   }

   if ((name[0] == 'q') && (name[1] != '\0'))
   {
      char* end;
      const long reg_offset = strtol(&name[1], &end, 0);
      if ((*end == '\0') && (reg_offset <= 15) && (reg_offset >= 0))
      {
         *value = (uint16_t) (REG_ZR + reg_offset);
         return 0;
      }
   }

   return 1;
}


int symbol_lookup(Symbols* SYMBOL_TABLE, const char* name, uint16_t* value)
{
   if (!SYMBOL_TABLE || !(SYMBOL_TABLE -> TABLE) ||!name)
   {
      return 1;
   }

   if (symbol_reg_lookup(name, value) == 0)
   {
      return 0;
   }
    //look through the symbol table
   for (int i = 0; i < SYMBOL_TABLE -> SYMBOL_COUNT; i++)
   {
      if (strcmp(name, SYMBOL_TABLE -> TABLE[i].name) == 0)
      {
         *value = (uint16_t) SYMBOL_TABLE -> TABLE[i].value;
         return 0;
      }
   }

   //determine if the value is purely numeric
   char* end;
   const long val = strtol(name, &end, 0);
   if (*end == '\0')
   {
      *value = (uint16_t) val;
      return 0;
   }

   return 1;
}

Program* create_program()
{
   Program* PROGRAM = malloc(sizeof(Program));
   if (!PROGRAM)
   {
      goto BAD_PROGRAM;
   }
   Instr* INSTRUCTIONS = malloc(sizeof(Instr) * 16);
   if (!INSTRUCTIONS)
   {
      goto BAD_INSTRUCTIONS;
   }
   PROGRAM -> INSTRUCTS = INSTRUCTIONS;

   PROGRAM -> INSTRUCTION_COUNT = 0;
   PROGRAM -> MAX_INSTRUCTIONS = 16;

   return PROGRAM;

   BAD_INSTRUCTIONS:
      free(INSTRUCTIONS);
   BAD_PROGRAM:
      free(PROGRAM);
   return NULL;

}

int queue_instruction(Program* PROGRAM, Instr* INSTRUCTION)
{
   if (!PROGRAM || !(PROGRAM -> INSTRUCTS) || !INSTRUCTION)
   {
      return 1;
   }
   if (PROGRAM -> INSTRUCTION_COUNT == PROGRAM -> MAX_INSTRUCTIONS)
   {
      if (resize_program(PROGRAM))
      {
         return 1;
      }
   }
   memcpy(PROGRAM -> INSTRUCTS + PROGRAM -> INSTRUCTION_COUNT, INSTRUCTION, sizeof(Instr));
   PROGRAM -> INSTRUCTION_COUNT++;
   return 0;
}


int resize_program(Program* PROGRAM)
{
   if (!PROGRAM || !PROGRAM -> INSTRUCTS)
   {
      return 1;
   }

   Instr* NEW_INSTRUCTS = malloc(sizeof(Instr) * (PROGRAM -> MAX_INSTRUCTIONS) * 2);
   if (!NEW_INSTRUCTS)
   {
      return 1;
   }
   for (int i = 0; i < PROGRAM -> INSTRUCTION_COUNT; i++)
   {
      memcpy(NEW_INSTRUCTS, PROGRAM -> INSTRUCTS, PROGRAM -> INSTRUCTION_COUNT * sizeof(Instr));
   }

   free(PROGRAM -> INSTRUCTS);
   PROGRAM -> INSTRUCTS = NEW_INSTRUCTS;
   PROGRAM -> MAX_INSTRUCTIONS *= 2;

   return 0;
}

static void print_sys_instruction(const Instr* INSTRUCTION)
{
   printf("UNIT: SYS\n");
   switch (INSTRUCTION -> FIELDS.SYS.CATEGORY)
   {
   case 0x0:
      {
         printf("CODE: EXECUTION\n");
         switch (INSTRUCTION -> FIELDS.SYS.CODE)
         {
         case 0x0: printf("SUBCODE: NOP"); break;
         case 0xF: printf("SUBCODE: HALT"); break;
         default: printf("SUBCODE: UNKNOWN"); break;
         }
         break;
      }
   case 0x1:
      {
         printf("CODE: ACCESS\n");
         switch (INSTRUCTION -> FIELDS.SYS.CODE)
         {
         case 0x0: printf("SUBCODE: COUNT\n"); break;
         default: printf("SUBCODE: UNKNOWN\n"); break;
         }
         printf("OFFSET: %d\n", INSTRUCTION -> FIELDS.SYS.IMM);
         break;
      }
   default: printf("CODE: UNKNOWN\n"); break;
   }
}

static void print_alu_instruction(const Instr* INSTRUCTION)
{

   printf("UNIT: ALU\n");
   switch (INSTRUCTION -> FIELDS.ALU.CODE)
   {
      case ALU_CMP: printf("CODE: COMPARE\n"); break;
      case ALU_ASR: printf("CODE: ARITHMETIC SHIFT RIGHT\n"); break;
      case ALU_ADD: printf("CODE: ADD\n"); break;
      case ALU_SUB: printf("CODE: SUB\n"); break;
      case ALU_LSL: printf("CODE: LOGICAL SHIFT LEFT\n"); break;
      case ALU_LSR: printf("CODE: LOGICAL SHIFT RIGHT\n"); break;
      case ALU_NAND: printf("CODE: NAND\n"); break;
      case ALU_XOR: printf("CODE: XOR\n"); break;
      case ALU_CMPI: printf("CODE: COMPARE IMMEDIATE\n"); break;
      case ALU_ASRI: printf("CODE: ARITHMETIC SHIFT RIGHT IMMEDIATE\n"); break;
      case ALU_ADDI: printf("CODE: ADD IMMEDIATE\n"); break;
      case ALU_SUBI: printf("CODE: SUB IMMEDIATE\n"); break;
      case ALU_LSLI: printf("CODE: LOGICAL SHIFT LEFT IMMEDIATE\n"); break;
      case ALU_LSRI: printf("CODE: LOGICAL SHIFT RIGHT IMMEDIATE\n"); break;
      case ALU_NANDI: printf("CODE: NAND IMMEDIATE\n"); break;
      case ALU_XORI: printf("CODE: XOR IMMEDIATE\n"); break;
      default: printf("CODE: UNKNOWN\n"); break;
   }

   printf("DESTINATION: %x\n", INSTRUCTION -> FIELDS.ALU.DEST);
   printf("SRC A: %x\n", INSTRUCTION -> FIELDS.ALU.SRC_A);
   printf("SRC B: ");
   if (INSTRUCTION -> FIELDS.ALU.USE_IMM)
   {
      printf("%d (IMMEDIATE)\n", INSTRUCTION -> FIELDS.ALU.IMM);
   }
   else
   {
      printf("%d (REGISTER)\n", INSTRUCTION -> FIELDS.ALU.SRC_B);
   }
}

static void print_mem_instruction(const Instr* INSTRUCTION)
{
   printf("UNIT: MEM\n");
   switch (INSTRUCTION -> FIELDS.MEM.CODE)
   {
      case MEM_STR_H: printf("CODE: STORE HALF\n"); break;
      case MEM_STR_W: printf("CODE: STORE WORD\n"); break;
      case MEM_LD_H: printf("CODE: LOAD HALF\n"); break;
      case MEM_LD_W: printf("CODE: LOAD WORD\n"); break;
      default: printf("CODE: UNKNOWN\n"); break;
   }

   printf("DEST/SRC: %x\n", INSTRUCTION -> FIELDS.MEM.DEST_SRC);
   printf("ADDR SRC: %x\n", INSTRUCTION -> FIELDS.MEM.ADDR_SRC);
   printf("ADDR OFFSET: %d\n", INSTRUCTION -> FIELDS.MEM.IMM);
}

static void print_jmp_instruction(const Instr* INSTRUCTION)
{
   printf("UNIT: JMP\n");
   switch (INSTRUCTION -> FIELDS.JMP.CODE)
   {
   case JE: printf("CODE: JMP EQ\n"); break;
   case JNE: printf("CODE: JMP NE\n"); break;
   case JL: printf("CODE: JMP LT\n"); break;
   case JGE: printf("CODE: JMP GE\n"); break;
   case JLE: printf("CODE: JMP LE\n"); break;
   case JG: printf("CODE: JMP GT\n"); break;
   case JB: printf("CODE: JMP BE\n"); break;
   case JAE: printf("CODE: JMP AE\n"); break;
   case JBE: printf("CODE: JMP BE\n"); break;
   case JA: printf("CODE: JMP AE\n"); break;
   case JMP: printf("CODE: JMP (UNCONDITIONAL)\n"); break;
   default: printf("CODE: UNKNOWN\n"); break;
   }
   if (INSTRUCTION -> FIELDS.JMP.USE_REG)
   {
      printf("INDIRECT TARGET: %x\n", INSTRUCTION -> FIELDS.JMP.INDIRECT);
      return;
   }

   if (INSTRUCTION -> FIELDS.JMP.UNRESOLVED_LABEL != NULL)
   {
      printf("LABEL IS UNRESOLVED, NAME IS: %s\n", INSTRUCTION -> FIELDS.JMP.UNRESOLVED_LABEL);
      return;
   }

   printf("IMMEDIATE TARGET: %x\n", INSTRUCTION -> FIELDS.JMP.IMM);


}

static void print_bit_instruction(const Instr* INSTRUCTION)
{

   printf("UNIT: BIT\n");
   switch (INSTRUCTION -> FIELDS.BIT.CODE)
   {
   case BIT_AND: printf("CODE: AND\n"); break;
   case BIT_OR: printf("CODE: OR\n"); break;
   case BIT_NOR: printf("CODE: NOR\n"); break;
   case BIT_XNOR: printf("CODE: XNOR\n"); break;
   case BIT_ROL: printf("CODE: ROTATE LEFT\n"); break;
   case BIT_ROR: printf("CODE: ROTATE RIGHT\n"); break;
   case BIT_CTZ: printf("CODE: CTZ(A)\n"); break;
   case BIT_CLZ: printf("CODE: CLZ(A)\n"); break;
   case BIT_ANDI: printf("CODE: AND IMMEDIATE\n"); break;
   case BIT_ORI: printf("CODE: OR IMMEDIATE\n"); break;
   case BIT_NORI: printf("CODE: NOR IMMEDIATE\n"); break;
   case BIT_XNORI: printf("CODE: XNOR IMMEDIATE\n"); break;
   case BIT_ROLI: printf("CODE: ROTATE LEFT IMMEDIATE\n"); break;
   case BIT_RORI: printf("CODE: ROTATE RIGHT IMMEDIATE\n"); break;
   case BIT_POPCNT: printf("CODE: POPCOUNT(A)\n"); break;
   default: printf("CODE: UNKNOWN\n"); break;
   }

   printf("DESTINATION: %x\n", INSTRUCTION -> FIELDS.BIT.DEST);
   printf("SRC A: %x\n", INSTRUCTION -> FIELDS.BIT.SRC_A);
   printf("SRC B: ");
   if (INSTRUCTION -> FIELDS.BIT.USE_IMM)
   {
      printf("%d (IMMEDIATE)\n", INSTRUCTION -> FIELDS.BIT.IMM);
   }
   else
   {
      printf("%d (REGISTER)\n", INSTRUCTION -> FIELDS.BIT.SRC_B);
   }
}



void print_instruction(const Instr* INSTRUCTION)
{
   if (!INSTRUCTION)
   {
      return;
   }

   printf("ADDRESS: %x\n", INSTRUCTION -> ADDR);
   printf("UNIT CODE: %x\n", INSTRUCTION -> UNIT);
   switch (INSTRUCTION -> UNIT)
   {
   case UNIT_SYS:
      {
         print_sys_instruction(INSTRUCTION);
         break;
      }
   case UNIT_ALU:
      {
         print_alu_instruction(INSTRUCTION);
         break;
      }
   case UNIT_MEM:
      {
         print_mem_instruction(INSTRUCTION);
         break;
      }
   case UNIT_JMP:
      {
         print_jmp_instruction(INSTRUCTION);
         break;
      }
   case UNIT_BIT:
      {
         print_bit_instruction(INSTRUCTION);
         break;
      }
   default: break;
   }

}

static void hex_sys_instruction(const Instr* INSTRUCTION, FILE* DEST)
{
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.SYS.CATEGORY);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.SYS.DEST);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.SYS.CODE);
   if (INSTRUCTION -> FIELDS.SYS.USE_IMM)
   {
      fprintf(DEST, "%04x", INSTRUCTION -> FIELDS.SYS.IMM);
      return;
   }
   fprintf(DEST, "%04x", 0);
}

static void hex_alu_instruction(const Instr* INSTRUCTION, FILE* DEST)
{
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.ALU.CODE);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.ALU.DEST);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.ALU.SRC_A);

   if (INSTRUCTION -> FIELDS.ALU.USE_IMM)
   {
      fprintf(DEST, "%04x", INSTRUCTION -> FIELDS.ALU.IMM);
      return;
   }
   fprintf(DEST, "%01x%03x", INSTRUCTION -> FIELDS.ALU.SRC_B, 0);

}

static void hex_mem_instruction(const Instr* INSTRUCTION, FILE* DEST)
{
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.MEM.CODE);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.MEM.DEST_SRC);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.MEM.ADDR_SRC);
   fprintf(DEST, "%04x", INSTRUCTION -> FIELDS.MEM.IMM);
}

static void hex_jmp_instruction(const Instr* INSTRUCTION, FILE* DEST)
{
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.JMP.CODE);
   if (INSTRUCTION -> FIELDS.JMP.USE_REG)
   {
      fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.JMP.INDIRECT);
      fprintf(DEST, "%01x", 0);
      fprintf(DEST, "%04x", 0);
   }
   else
   {
      fprintf(DEST, "%01x", 0);
      fprintf(DEST, "%01x", 0);
      fprintf(DEST, "%04x", INSTRUCTION -> FIELDS.JMP.IMM);
   }
}

static void hex_bit_instruction(const Instr* INSTRUCTION, FILE* DEST)
{
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.BIT.CODE);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.BIT.DEST);
   fprintf(DEST, "%01x", INSTRUCTION -> FIELDS.BIT.SRC_A);

   if (INSTRUCTION -> FIELDS.BIT.USE_IMM)
   {
      fprintf(DEST, "%04x", INSTRUCTION -> FIELDS.BIT.IMM);
      return;
   }
   fprintf(DEST, "%01x%03x", INSTRUCTION -> FIELDS.BIT.SRC_B, 0);

}

int hex_instruction(const Instr* INSTRUCTION, FILE* DEST)
{
   if (!INSTRUCTION || !DEST)
   {
      return 1;
   }

   //fprintf(DEST, "U32 0x"); //for Turing Complete ease of use

   fprintf(DEST, "%01x", INSTRUCTION -> UNIT);
   switch (INSTRUCTION -> UNIT)
   {
      case UNIT_SYS: hex_sys_instruction(INSTRUCTION, DEST); break;
      case UNIT_ALU: hex_alu_instruction(INSTRUCTION, DEST); break;
      case UNIT_MEM: hex_mem_instruction(INSTRUCTION, DEST); break;
      case UNIT_JMP: hex_jmp_instruction(INSTRUCTION, DEST); break;
      case UNIT_BIT: hex_bit_instruction(INSTRUCTION, DEST); break;
      default: break;
   }

   fprintf(DEST, "\n");
   return 0;
}