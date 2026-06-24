module INSTR_DECODER (
    input wire [31:0] INSTR,

    output wire [3:0] UNIT_CODE,
    
    output wire [3:0] MAIN_CODE,

    output wire [3:0] REG_DEST_SYS,
    output wire [3:0] REG_DEST_ALU,
    output wire [3:0] REG_DEST_BIT,
    output wire [3:0] REG_SRC_DEST_MEM,
    output wire [3:0] REG_INDIRECT_JMP,

    output wire [3:0] SUBCODE_SYS,
    output wire [3:0] REG_A_ALU,
    output wire [3:0] REG_A_BIT,
    output wire [3:0] REG_ADDR_MEM,
    output wire [3:0] RESERVED_JMP,

    output wire [3:0] REG_B_ALU,
    output wire [3:0] REG_B_BIT,

    output wire [15:0] IMM
);

assign UNIT_CODE = INSTR[31:28];
assign MAIN_CODE = INSTR[27:24];

assign REG_DEST_SYS = INSTR[23:20];
assign REG_DEST_ALU = INSTR[23:20];
assign REG_DEST_BIT = INSTR[23:20];
assign REG_SRC_DEST_MEM = INSTR[23:20];
assign REG_INDIRECT_JMP = INSTR[23:20];

assign SUBCODE_SYS = INSTR[19:16];
assign REG_A_ALU = INSTR[19:16];
assign REG_A_BIT = INSTR[19:16];
assign REG_ADDR_MEM = INSTR[19:16];
assign RESERVED_JMP = INSTR[19:16];

assign REG_B_ALU = INSTR[15:12];
assign REG_B_BIT = INSTR[15:12];

assign IMM = INSTR[15:0];

endmodule