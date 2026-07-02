
module VRAI_SYNC_CORE (
    input wire CLK,
    input wire RESET,

    input wire [31:0] INSTR_STREAM,
    output wire [15:0] INSTR_ADDR,

    output wire MAIN_STRH,
    output wire MAIN_STRW,
    output wire MAIN_LDH,
    output wire MAIN_LDW,

    output wire DEVICES_STRH,
    output wire DEVICES_STRW,
    output wire DEVICES_LDH,
    output wire DEVICES_LDW,

    output wire INVALID_MEM,

    output wire [15:0] MEM_STR_DATA,
    output wire [15:0] MEM_ADDR,

    input wire [15:0] MEM_LD_DATA,

    output wire EX_HALT
);

//Registers for Multi-Cycle implementation
reg STALL_EX;
reg [31:0] INSTR;

reg STREAM_WRITE_DEST;

reg JMP_STREAM_COUNT;

reg [3:0] REG_DEST;

reg [15:0] RESULT_SYS;
reg [15:0] RESULT_ALU;
reg [15:0] RESULT_BIT;
reg [15:0] RESULT_MEM;

reg [15:0] JMP_DEST;


reg LOAD;

reg RESULT_SYS_EN;
reg RESULT_ALU_EN;
reg RESULT_MEM_EN;
reg RESULT_BIT_EN;




//Instruction Decoding
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

wire [3:0] RESERVED_JMP; //reserved field for the JUMP unit

wire [3:0] REG_B_ALU;
wire [3:0] REG_B_BIT;

wire [15:0] IMM;

INSTR_DECODER instr_decoder (
    .INSTR(INSTR), //INSTR is not implemented yet
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


//Unit Decoding
wire UNIT_SYS_EN;
wire UNIT_ALU_EN;
wire UNIT_MEM_EN;
wire UNIT_JMP_EN;
wire UNIT_BIT_EN;

wire UNIT_INVALID;

UNIT_DECODER unit_decoder (
    .UNIT_CODE(UNIT_CODE), //from INSTR Decoding

    .UNIT_SYS_EN(UNIT_SYS_EN),
    .UNIT_ALU_EN(UNIT_ALU_EN),
    .UNIT_MEM_EN(UNIT_MEM_EN),
    .UNIT_JMP_EN(UNIT_JMP_EN),
    .UNIT_BIT_EN(UNIT_BIT_EN),

    .UNIT_INVALID(UNIT_INVALID)
);

//Register File
reg [15:0] REG_FILE [0:15];

//Control Wires to each Register (for debugging)
wire [15:0] REG_ZR;
wire [15:0] REG_Q1;
wire [15:0] REG_Q2;
wire [15:0] REG_Q3;
wire [15:0] REG_Q4;
wire [15:0] REG_Q5;
wire [15:0] REG_Q6;
wire [15:0] REG_Q7;
wire [15:0] REG_Q8;
wire [15:0] REG_Q9;
wire [15:0] REG_QA;
wire [15:0] REG_QB;
wire [15:0] REG_QC;
wire [15:0] REG_QD;
wire [15:0] REG_SP;
wire [15:0] REG_COND;

assign REG_ZR = REG_FILE[0];
assign REG_Q1 = REG_FILE[1];
assign REG_Q2 = REG_FILE[2];
assign REG_Q3 = REG_FILE[3];
assign REG_Q4 = REG_FILE[4];
assign REG_Q5 = REG_FILE[5];
assign REG_Q6 = REG_FILE[6];
assign REG_Q7 = REG_FILE[7];
assign REG_Q8 = REG_FILE[8];
assign REG_Q9 = REG_FILE[9];
assign REG_QA = REG_FILE[10];
assign REG_QB = REG_FILE[11];
assign REG_QC = REG_FILE[12];
assign REG_QD = REG_FILE[13];
assign REG_SP = REG_FILE[14];
assign REG_COND = REG_FILE[15];

//Register Operand (non-destination) Wires (for instructions)
wire [15:0] REG_ALU_A;
wire [15:0] REG_ALU_B;

wire [15:0] REG_BIT_A;
wire [15:0] REG_BIT_B;

wire [15:0] REG_MEM_ADDR;
wire [15:0] REG_MEM_SRC_DEST;

wire [15:0] REG_JMP_INDIRECT;

assign REG_ALU_A = REG_FILE[REG_A_ALU];
assign REG_ALU_B = REG_FILE[REG_B_ALU];

assign REG_BIT_A = REG_FILE[REG_A_BIT];
assign REG_BIT_B = REG_FILE[REG_B_BIT];

assign REG_MEM_ADDR = REG_FILE[REG_ADDR_MEM];
assign REG_MEM_SRC_DEST = REG_FILE[REG_SRC_DEST_MEM];

assign REG_JMP_INDIRECT = REG_FILE[REG_INDIRECT_JMP];


//Unit 3: Jump
wire COND_MET;

UNIT_JMP jump_unit (
    .COND_FLAGS(REG_COND),
    .CODE(MAIN_CODE),

    .COND_MET(COND_MET)
);

wire COUNT_OVERWRITE;
assign COUNT_OVERWRITE = COND_MET & UNIT_JMP_EN;



//Unit 0: System
reg HALT_EX;
assign EX_HALT = HALT_EX;

wire COUNTER_ENABLE;

assign COUNTER_ENABLE = ~(HALT_EX | STALL_EX);


wire [15:0] COUNT_VALUE;
COUNTER counter (
    .CLK(CLK),
    .RESET(RESET),
    
    .OVERWRITE(JMP_STREAM_COUNT), //see Unit 3: Jump
    .OVERWRITE_VALUE(IMM + REG_JMP_INDIRECT),
    
    .ENABLE(COUNTER_ENABLE),

    .COUNT(COUNT_VALUE)
);

assign INSTR_ADDR = COUNT_VALUE; //See Unit 0: System


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

wire [15:0] SYS_COUNT_RESULT;
SWITCH sys_count_ctrl (
    .IN(COUNT_VALUE + IMM),
    .SW_EN(SYS_COUNT),
    .OUT(SYS_COUNT_RESULT)
);

wire [15:0] SW_SYS_RESULT;

wire [15:0] SYS_RESULT;

assign SYS_RESULT = SYS_COUNT_RESULT;

SWITCH sys_result_ctrl (
    .IN(RESULT_SYS),
    .SW_EN(UNIT_SYS_EN),
    .OUT(SW_SYS_RESULT)
);

wire [3:0] SW_SYS_DEST;
SWITCH #(4) sys_dest_ctrl (
    .IN(REG_DEST_SYS),
    .SW_EN(UNIT_SYS_EN),
    .OUT(SW_SYS_DEST)
);

wire SYS_INVALID;
assign SYS_INVALID = (UNIT_SYS_EN) & (SYS_ACCESS_INVALID | 
                                      SYS_EX_CTRL_INVALID | 
                                      SYS_CATEGORY_INVALID);

//Unit 1: ALU
wire [15:0] ALU_RESULT;

UNIT_ALU alu (
    .A(REG_ALU_A),
    .B(REG_ALU_B),
    .IMM(IMM),

    .CODE(MAIN_CODE),
    .RESULT(ALU_RESULT)
);

wire [15:0] SW_ALU_RESULT;

SWITCH alu_result_ctrl (
    .IN(RESULT_ALU),
    .SW_EN(UNIT_ALU_EN),
    .OUT(SW_ALU_RESULT)
);

wire [3:0] SW_ALU_DEST;
SWITCH #(4) alu_dest_ctrl (
    .IN(REG_DEST_ALU),
    .SW_EN(UNIT_ALU_EN),
    .OUT(SW_ALU_DEST)
);

//Unit 2: Memory
wire [15:0] DEST_ADDR_MEM;
wire [15:0] MEM_DATA_STR;

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
    .VALUE_FOUND(MEM_DATA_STR),

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

wire MEM_LOAD;
wire MEM_STORE;

assign MAIN_STRH = UNIT_MEM_EN & MEM_MAIN_STRH;
assign MAIN_STRW = UNIT_MEM_EN & MEM_MAIN_STRW;
assign MAIN_LDH = UNIT_MEM_EN & MEM_MAIN_LDH;
assign MAIN_LDW = UNIT_MEM_EN & MEM_MAIN_LDW;

assign DEVICES_STRH = UNIT_MEM_EN & MEM_DEVICES_STRH;
assign DEVICES_STRW = UNIT_MEM_EN & MEM_DEVICES_STRW;
assign DEVICES_LDH = UNIT_MEM_EN & MEM_DEVICES_LDH;
assign DEVICES_LDW = UNIT_MEM_EN & MEM_DEVICES_LDW;

assign INVALID_MEM = UNIT_MEM_EN & MEM_INVALID;

assign MEM_STORE = (UNIT_MEM_EN) & (MEM_MAIN_STRH |
                                    MEM_MAIN_STRW | 
                                    MEM_DEVICES_STRH |
                                    MEM_DEVICES_STRW);

assign MEM_LOAD = (UNIT_MEM_EN) & (MEM_MAIN_LDH |
                                   MEM_MAIN_LDW |
                                   MEM_DEVICES_LDH |
                                   MEM_DEVICES_LDW);

SWITCH mem_str_data_ctrl (
    .IN(MEM_DATA_STR),
    .SW_EN(MEM_STORE),
    .OUT(MEM_STR_DATA)
);

SWITCH mem_addr_ctrl (
    .IN(DEST_ADDR_MEM),
    .SW_EN(UNIT_MEM_EN),
    .OUT(MEM_ADDR)
);

wire [15:0] SW_MEM_RESULT;

SWITCH mem_ld_data_ctrl (
    .IN(RESULT_MEM),
    .SW_EN(MEM_LOAD),
    .OUT(SW_MEM_RESULT)
);

wire [3:0] SW_MEM_DEST;
SWITCH #(4) mem_dest_ctrl (
    .IN(REG_SRC_DEST_MEM),
    .SW_EN(MEM_LOAD),
    .OUT(SW_MEM_DEST)
);



//Unit 4: Bit
wire [15:0] BIT_RESULT;

UNIT_BIT bit_unit (
    .A(REG_BIT_A),
    .B(REG_BIT_B),
    .IMM(IMM),

    .CODE(MAIN_CODE),
    .RESULT(BIT_RESULT)
);

wire [15:0] SW_BIT_RESULT;
SWITCH bit_result_ctrl (
    .IN(RESULT_BIT),
    .SW_EN(UNIT_BIT_EN),
    .OUT(SW_BIT_RESULT)
);

wire [3:0] SW_BIT_DEST;
SWITCH #(4) bit_dest_ctrl (
    .IN(REG_DEST_BIT),
    .SW_EN(RESULT_BIT_EN),
    .OUT(SW_BIT_DEST)
);

//Final Streaming
wire [15:0] RESULT;
wire [3:0] DEST;
wire WRITE_DEST;

assign RESULT = SW_SYS_RESULT |
                SW_ALU_RESULT |
                SW_MEM_RESULT |
                SW_BIT_RESULT;

assign DEST = SW_SYS_DEST |
              SW_ALU_DEST |
              SW_MEM_DEST |
              SW_BIT_DEST;


wire SYS_WRITE_DEST;
assign SYS_WRITE_DEST = UNIT_SYS_EN & SYS_ACCESS & ~SYS_ACCESS_INVALID;
assign WRITE_DEST = (DEST != 4'h0) & (UNIT_ALU_EN |
                                      UNIT_BIT_EN |
                                      SYS_WRITE_DEST |
                                      MEM_LOAD);



localparam STATE_COUNTER_UPDATE = 0,
           STATE_FETCH_REQ = 1,
           STATE_FETCH_END = 2,
           STATE_EXECUTE = 3,
           STATE_MEM = 4,
           STATE_STREAM = 5,
           STATE_INVALID = 6;

reg [2:0] STATE;




localparam INSTR_NOP = 32'h0000_0000;
//RESET to default state
integer i;
always @(posedge CLK) begin
    if (RESET) begin

        for (i = 0; i < 16; i = i + 1) begin
            REG_FILE[i] <= 16'h0000;
        end
        HALT_EX <= 0;
        STALL_EX <= 1;
        STATE <= STATE_FETCH_REQ;
        INSTR <= INSTR_NOP;

        STREAM_WRITE_DEST <= 0;

        JMP_STREAM_COUNT <= 0;
        JMP_DEST <= 16'h0000;

        REG_DEST <= 4'h0;

        RESULT_SYS <= 16'h0000;
        RESULT_ALU <= 16'h0000;
        RESULT_MEM <= 16'h0000;
        RESULT_BIT <= 16'h0000;

        LOAD <= 0;

        RESULT_SYS_EN <= 0;
        RESULT_ALU_EN <= 0;
        RESULT_MEM_EN <= 0;
        RESULT_BIT_EN <= 0;
        
    end
end

//Normal Execution
always @(posedge CLK) begin

    if (!RESET) begin
        //Assumes Synchronous Memory Access
        case (STATE)
            STATE_COUNTER_UPDATE: begin
                STALL_EX <= 1;
                STATE <= STATE_FETCH_REQ;
            end
            STATE_FETCH_REQ: begin
                STATE <= STATE_FETCH_END;
            end
            STATE_FETCH_END: begin
                INSTR <= INSTR_STREAM;
                STATE <= STATE_EXECUTE;
            end
            STATE_EXECUTE: begin
                if (UNIT_INVALID | INVALID_MEM | SYS_INVALID) begin
                    STATE <= STATE_INVALID;
                    INSTR <= INSTR_NOP;
                end else begin
                    STREAM_WRITE_DEST <= WRITE_DEST;
                    LOAD <= MEM_LOAD;
                    JMP_STREAM_COUNT <= COUNT_OVERWRITE; //go back to counter and edit the OVERWRITE port

                    REG_DEST <= DEST;
                    
                    RESULT_ALU <= ALU_RESULT;
                    RESULT_BIT <= BIT_RESULT;
                    RESULT_SYS <= SYS_RESULT;

                    RESULT_MEM_EN <= 0;
                    RESULT_SYS_EN <= UNIT_SYS_EN;
                    RESULT_ALU_EN <= UNIT_ALU_EN;
                    RESULT_BIT_EN <= UNIT_BIT_EN;

                    JMP_DEST <= IMM + REG_JMP_INDIRECT;
                    if (UNIT_MEM_EN) begin
                        STATE <= STATE_MEM;
                        //MEM_INSTRUCTIONS
                    end else begin
                        STATE <= STATE_STREAM;
                        //NON-MEM instructions
                    end
                end
                
            end
            STATE_MEM: begin
                if (LOAD) begin
                    RESULT_MEM <= MEM_LD_DATA;
                    RESULT_MEM_EN <= 1;
                end
                STATE <= STATE_STREAM;
            end
            STATE_STREAM: begin

                if (STREAM_WRITE_DEST) begin
                    REG_FILE[REG_DEST] <= RESULT;
                end

                if (SYS_HALT) begin
                    HALT_EX <= 1;
                end

                STATE <= STATE_COUNTER_UPDATE;
                STALL_EX <= 0;

            end
            STATE_INVALID: begin
                STATE <= STATE_INVALID;
                INSTR <= INSTR_NOP;
                HALT_EX <= 1;
            end
            default: begin
                STATE <= STATE_INVALID;
                INSTR <= INSTR_NOP;
            end
        endcase


        /* //Assumes Combinational Memory access
        if (WRITE_DEST) begin
            REG_FILE[DEST] <= RESULT;
        end

        if (SYS_HALT) begin
            HALT_EX <= 1;
        end
        */
    end
end




endmodule