`include "VRAI-VERILOG/COUNTER.v"

`include "VRAI-VERILOG/UNIT_DECODER.v"
`include "VRAI-VERILOG/UNIT_ALU.v"
`include "VRAI-VERILOG/UNIT_BIT.v"
`include "VRAI-VERILOG/UNIT_JMP.v"
`include "VRAI-VERILOG/UNIT_MEM.v"
`include "VRAI-VERILOG/UNIT_SYS.v"


`include "VRAI-VERILOG/SWITCH.v"
`include "VRAI-VERILOG/INSTR_DECODER.v"

module VRAI_CORE (
    input wire CLK,
    input wire RESET,

    input wire [31:0] INSTR_STREAM,
    output wire [15:0] INSTR_ADDR,

    input wire [3:0] REQUESTED_TEST_REG,

    output wire [15:0] TEST_ZR,
    output wire [15:0] TEST_COND,
    output wire [15:0] TEST_VAR_REG,

    output wire MAIN_STRH,
    output wire MAIN_STRW,
    output wire MAIN_LDH,
    output wire MAIN_LDW,

    output wire DEVICES_STRH,
    output wire DEVICES_STRW,
    output wire DEVICES_LDH,
    output wire DEVICES_LDW,

    output wire INVALID_MEM,

    output wire [15:0] MEM_DATA_OUT,
    output wire [15:0] MEM_ADDR_OUT,
    input wire  [15:0] MEM_DATA_IN
);

reg HALT_EXECUTION;

wire [3:0] UNIT_CODE;
wire [3:0] MAIN_CODE;
wire [3:0] REG_DEST_SYS;
wire [3:0] REG_DEST_ALU;
wire [3:0] REG_DEST_BIT;
wire [3:0] REG_SRC_DEST_MEM;
wire [3:0] REG_INDIRECT_JMP;
wire [3:0] SUBCODE_SYS;
wire [3:0] REG_A_ALU;
wire [3:0] REG_A_BIT;
wire [3:0] REG_ADDR_MEM;
wire [3:0] RESERVED_JMP;
wire [3:0] REG_B_ALU;
wire [3:0] REG_B_BIT;
wire [15:0] IMM;

INSTR_DECODER instr_decoder (
    .INSTR(INSTR_STREAM),
    .UNIT_CODE(UNIT_CODE),
    .MAIN_CODE(MAIN_CODE),
    .REG_DEST_SYS(REG_DEST_SYS),
    .REG_DEST_ALU(REG_DEST_ALU),
    .REG_DEST_BIT(REG_DEST_BIT),
    .REG_SRC_DEST_MEM(REG_SRC_DEST_MEM),
    .REG_INDIRECT_JMP(REG_INDIRECT_JMP),
    .SUBCODE_SYS(SUBCODE_SYS),
    .REG_A_ALU(REG_A_ALU),
    .REG_A_BIT(REG_A_BIT),
    .REG_ADDR_MEM(REG_ADDR_MEM),
    .RESERVED_JMP(RESERVED_JMP),
    .REG_B_ALU(REG_B_ALU),
    .REG_B_BIT(REG_B_BIT),
    .IMM(IMM)
);

wire UNIT_SYS_EN;
wire UNIT_ALU_EN;
wire UNIT_MEM_EN;
wire UNIT_JMP_EN;
wire UNIT_BIT_EN;

wire UNIT_INVALID;

UNIT_DECODER unit_decoder (
    .UNIT_CODE(UNIT_CODE),
    .UNIT_SYS_EN(UNIT_SYS_EN),
    .UNIT_ALU_EN(UNIT_ALU_EN),
    .UNIT_MEM_EN(UNIT_MEM_EN),
    .UNIT_JMP_EN(UNIT_JMP_EN),
    .UNIT_BIT_EN(UNIT_BIT_EN),
    .UNIT_INVALID(UNIT_INVALID)
);


//send register encoded operands to the register file to get data

reg [15:0] REG_FILE [0:15];

wire [15:0] REG_ALU_A;
wire [15:0] REG_ALU_B;
wire [15:0] REG_BIT_A;
wire [15:0] REG_BIT_B;
wire [15:0] REG_MEM_ADDR;
wire [15:0] REG_MEM_SRC_DEST;
wire [15:0] REG_JMP_COND;
wire [15:0] REG_JMP_INDIRECT;

assign REG_ALU_A = REG_FILE[REG_A_ALU];
assign REG_ALU_B = REG_FILE[REG_B_ALU];

assign REG_BIT_A = REG_FILE[REG_A_BIT];
assign REG_BIT_B = REG_FILE[REG_B_BIT];

assign REG_MEM_ADDR = REG_FILE[REG_ADDR_MEM];
assign REG_MEM_SRC_DEST = REG_FILE[REG_SRC_DEST_MEM];

assign REG_JMP_COND = REG_FILE[15];
assign REG_JMP_INDIRECT = REG_FILE[REG_INDIRECT_JMP];

wire [15:0] ALU_RESULT;

UNIT_ALU alu_unit (
    .A(REG_ALU_A),
    .B(REG_ALU_B),
    .IMM(IMM),
    .CODE(MAIN_CODE),
    .RESULT(ALU_RESULT)
);

wire [15:0] BIT_RESULT;

UNIT_BIT bit_unit (
    .A(REG_BIT_A),
    .B(REG_BIT_B),
    .IMM(IMM),
    .CODE(MAIN_CODE),
    .RESULT(BIT_RESULT)
);

wire COND_MET;

UNIT_JMP jmp_unit (
    .COND_FLAGS(REG_JMP_COND),
    .CODE(MAIN_CODE),
    .COND_MET(COND_MET)
);

//system unit stuff


//memory unit saved for later

wire [15:0] DEST_ADDR_MEM;
wire [15:0] MEM_VALUE_STREAM;

wire MEM_MAIN_STRH;
wire MEM_MAIN_STRW;
wire MEM_MAIN_LDH;
wire MEM_MAIN_LDW;

wire MEM_DEVICES_STRH;
wire MEM_DEVICES_STRW;
wire MEM_DEVICES_LDH;
wire MEM_DEVICES_LDW;

wire MEM_INVALID;
UNIT_MEM mem_unit (
    .BASE_ADDR(REG_MEM_ADDR),
    .OFFSET(IMM),
    .VALUE_IN(REG_MEM_SRC_DEST),
    .CODE(MAIN_CODE),
    .DEST_ADDR(DEST_ADDR_MEM),
    .VALUE_FOUND(MEM_VALUE_STREAM),
    .MEM_MAIN_STRH(MEM_MAIN_STRH),
    .MEM_MAIN_STRW(MEM_MAIN_STRW),
    .MEM_MAIN_LDH(MEM_MAIN_LDH),
    .MEM_MAIN_LDW(MEM_MAIN_LDW),
    .MEM_DEVICES_STRH(MEM_DEVICES_STRH),
    .MEM_DEVICES_STRW(MEM_DEVICES_STRW),
    .MEM_DEVICES_LDH(MEM_DEVICES_LDH),
    .MEM_DEVICES_LDW(MEM_DEVICES_LDW),
    .MEM_INVALID(MEM_INVALID)
);

assign MAIN_STRH = MEM_MAIN_STRH & UNIT_MEM_EN;
assign MAIN_STRW = MEM_MAIN_STRW & UNIT_MEM_EN;
assign MAIN_LDH = MEM_MAIN_LDH & UNIT_MEM_EN;
assign MAIN_LDW = MEM_MAIN_LDW & UNIT_MEM_EN;

assign DEVICES_STRH = MEM_DEVICES_STRH & UNIT_MEM_EN;
assign DEVICES_STRW = MEM_DEVICES_STRW & UNIT_MEM_EN;
assign DEVICES_LDH = MEM_DEVICES_LDH & UNIT_MEM_EN;
assign DEVICES_LDW = MEM_DEVICES_LDW & UNIT_MEM_EN;

assign INVALID_MEM = MEM_INVALID & UNIT_MEM_EN;

SWITCH mem_data_out_ctrl (
    .IN(MEM_VALUE_STREAM),
    .SW_EN(UNIT_MEM_EN),
    .OUT(MEM_DATA_OUT)
);

SWITCH mem_addr_out_ctrl (
    .IN(DEST_ADDR_MEM),
    .SW_EN(UNIT_MEM_EN),
    .OUT(MEM_ADDR_OUT)
);


//Counter
wire [15:0] COUNT_VALUE;
COUNTER counter (
    .CLK(CLK),
    .RESET(RESET),
    .OVERWRITE(UNIT_JMP_EN & COND_MET),
    .ENABLE(~HALT_EXECUTION),
    .OVERWRITE_VALUE(REG_JMP_INDIRECT + IMM),
    .COUNT(COUNT_VALUE)
);
assign INSTR_ADDR = COUNT_VALUE;

//SYSTEM Unit stuff

wire SYS_EX_CTRL;
wire SYS_ACCESS;
wire SYS_CATEGORY_INVALID;
SYS_CATEGORY_DECODER sys_category (
    .CODE(MAIN_CODE),
    .UNIT_SYS_EN(UNIT_SYS_EN),
    
    .SYS_EX_CTRL(SYS_EX_CTRL),
    .SYS_ACCESS(SYS_ACCESS),
    .SYS_INVALID(SYS_CATEGORY_INVALID)
);

wire SYS_NOP;
wire SYS_HALT;
wire SYS_EX_CTRL_INVALID;

SYS_EX_CTRL_DECODER sys_ex_ctrl_dec (
    .CODE(SUBCODE_SYS),
    .SYS_EX_CTRL(SYS_EX_CTRL),

    .SYS_NOP(SYS_NOP),
    .SYS_HALT(SYS_HALT),
    .SYS_EX_CTRL_INVALID(SYS_EX_CTRL_INVALID)
);

wire SYS_COUNT;
wire SYS_ACCESS_INVALID;

SYS_ACCESS_DECODER sys_access_dec (
    .CODE(SUBCODE_SYS),
    .SYS_ACCESS(SYS_ACCESS),
    
    .SYS_COUNT(SYS_COUNT),
    .SYS_ACCESS_INVALID(SYS_ACCESS_INVALID)
);




wire [3:0] SW_ALU_DEST;
wire [3:0] SW_SYS_DEST; //doesnt do anything yet
wire [3:0] SW_BIT_DEST;
wire [3:0] SW_MEM_DEST;
wire [3:0] DEST;

SWITCH #(4) alu_dest_ctrl (
    .IN(REG_DEST_ALU),
    .SW_EN(UNIT_ALU_EN),
    .OUT(SW_ALU_DEST)
);

SWITCH #(4) sys_dest_ctrl (
    .IN(REG_DEST_SYS),
    .SW_EN(UNIT_SYS_EN),
    .OUT(SW_SYS_DEST)
);

SWITCH #(4) bit_dest_ctrl (
    .IN(REG_DEST_BIT),
    .SW_EN(UNIT_BIT_EN),
    .OUT(SW_BIT_DEST)
);

SWITCH #(4) mem_dest_ctrl (
    .IN(REG_SRC_DEST_MEM),
    .SW_EN(UNIT_MEM_EN),
    .OUT(SW_MEM_DEST)
);

assign DEST = SW_SYS_DEST | SW_ALU_DEST | SW_BIT_DEST | SW_MEM_DEST;


wire [15:0] SYS_COUNT_RESULT;

SWITCH sys_count_ctrl (
    .IN(COUNT_VALUE + IMM),
    .SW_EN(SYS_COUNT),
    .OUT(SYS_COUNT_RESULT)
);

wire [15:0] SW_SYS_RESULT;

assign SW_SYS_RESULT = SYS_COUNT_RESULT; //expands into an or tree as more sys results are implemented

wire [15:0] SW_ALU_RESULT;
wire [15:0] SW_BIT_RESULT;
wire [15:0] SW_MEM_RESULT;


SWITCH alu_result_ctrl (
    .IN(ALU_RESULT),
    .SW_EN(UNIT_ALU_EN),
    .OUT(SW_ALU_RESULT)
);

SWITCH bit_result_ctrl (
    .IN(BIT_RESULT),
    .SW_EN(UNIT_BIT_EN),
    .OUT(SW_BIT_RESULT)
);

SWITCH mem_result_ctrl (
    .IN(MEM_DATA_IN),
    .SW_EN(UNIT_MEM_EN),
    .OUT(SW_MEM_RESULT)
);

wire [15:0] RESULT;

assign RESULT = SW_ALU_RESULT | SW_BIT_RESULT | SW_MEM_RESULT | SW_SYS_RESULT;


assign TEST_ZR = REG_FILE[0];
assign TEST_COND = REG_FILE[15];

assign TEST_VAR_REG = REG_FILE[REQUESTED_TEST_REG];


wire WRITE_DEST;
wire MEM_WRITE_DEST;

assign MEM_WRITE_DEST = UNIT_MEM_EN & (MEM_MAIN_LDH | MEM_MAIN_LDW |
                                    MEM_DEVICES_LDH | MEM_DEVICES_LDW);

wire SYS_WRITE_DEST;
assign SYS_WRITE_DEST = UNIT_SYS_EN & SYS_ACCESS & ~SYS_ACCESS_INVALID;

assign WRITE_DEST = (UNIT_ALU_EN | UNIT_BIT_EN | MEM_WRITE_DEST | SYS_WRITE_DEST) & (DEST != 4'h0);

integer i;
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        //initialize the register file to all 0
        for (i = 0; i < 16; i = i + 1) begin
            REG_FILE[i] <= 16'h0000;
        end
        HALT_EXECUTION <= 0;
    end else begin
        //The main area for streaming the actual interesting parts 
        if (WRITE_DEST) begin
            REG_FILE[DEST] <= RESULT;
        end

        if (SYS_HALT) begin
            HALT_EXECUTION <= 1;
        end
    end
end

endmodule