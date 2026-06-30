//This file is still in progress, nowhere near done

`timescale 1ps/1ps
`include "VRAI-VERILOG/VRAI_CORE-sync_mem.v"
module SYNC_INSTR_MEM (
  input wire CLK,

  input wire [15:0] INSTR_ADDR,

  output reg [31:0] INSTR_STREAM  
);

reg [31:0] MEM_INSTR [0:16383];

initial begin
    $readmemh("program_alpha.hex", MEM_INSTR);
end

always @(posedge CLK) begin
    INSTR_STREAM <= MEM_INSTR[INSTR_ADDR >> 2];
end

endmodule

module VRAI_sync_tb ();
reg CLK;
reg RESET;

wire [31:0] INSTR_STREAM;

always
#1 CLK = ~CLK;

wire [15:0] INSTR_ADDR;

SYNC_INSTR_MEM sync_instr_mem (
    .CLK(CLK),
    .INSTR_ADDR(INSTR_ADDR),
    .INSTR_STREAM(INSTR_STREAM)  
);


reg [3:0] REQUESTED_TEST_REG;

wire [15:0] TEST_ZR;
wire [15:0] TEST_COND;
wire [15:0] TEST_REG;

wire MAIN_STRH;
wire MAIN_STRW;
wire MAIN_LDH;
wire MAIN_LDW;

wire DEVICES_STRH;
wire DEVICES_STRW;
wire DEVICES_LDH;
wire DEVICES_LDW;

wire INVALID_MEM;

wire [15:0] MEM_DATA_OUT;
wire [15:0] MEM_ADDR_OUT;
wire [15:0] MEM_DATA_IN;

wire HALT;

//not complete port descriptions
VRAI_SYNC_CORE vrai_sync_core (
    .CLK(CLK),
    .RESET(RESET),

    .INSTR_STREAM(INSTR_STREAM),
    .INSTR_ADDR(INSTR_ADDR),

    .REQUESTED_TEST_REG(REQUESTED_TEST_REG),

    .TEST_ZR(TEST_ZR),
    .TEST_COND(TEST_COND),
    .TEST_VAR_REG(TEST_REG),

    .MAIN_STRH(MAIN_STRH),
    .MAIN_STRW(MAIN_STRW),
    .MAIN_LDH(MAIN_LDH),
    .MAIN_LDW(MAIN_LDW),

    .DEVICES_STRH(DEVICES_STRH),
    .DEVICES_STRW(DEVICES_STRW),
    .DEVICES_LDH(DEVICES_LDH),
    .DEVICES_LDW(DEVICES_LDW),

    .INVALID_MEM(INVALID_MEM),

    .MEM_DATA_OUT(MEM_DATA_OUT),
    .MEM_ADDR_OUT(MEM_ADDR_OUT),
    .MEM_DATA_IN(MEM_DATA_IN),

    .EX_HALT(HALT)
);

SYNC_INSTR_MEM instr_mem (
    .CLK(CLK),
    .INSTR_ADDR(INSTR_ADDR),
    .INSTR_STREAM(INSTR_STREAM)
);

wire [15:0] MAIN_MEM_RESULT;
MAIN_SYNC_MEM main_sync_mem (
    .CLK(CLK),
    .ADDR({1'b0, MEM_ADDR_OUT[14:0]}),
    .DATA_IN(MEM_DATA_OUT),
    .STRH(MAIN_STRH),
    .STRW(MAIN_STRW),
    .LDH(MAIN_LDH),
    .LDW(MAIN_LDW),

    .DATA_OUT(MAIN_MEM_RESULT)
);


wire [15:0] DEVICES_MEM_RESULT;
DEVICE_SYNC_MEM device_sync_mem (
    .CLK(CLK),
    .ADDR({1'b0, MEM_ADDR_OUT[14:0]}),
    .DATA_IN(MEM_DATA_OUT),
    .STRH(DEVICES_STRH),
    .STRW(DEVICES_STRW),
    .LDH(DEVICES_LDH),
    .LDW(DEVICES_LDW),

    .DATA_OUT(DEVICES_MEM_RESULT)
);

wire [15:0] MEM_RESULT;
assign MEM_RESULT = MAIN_MEM_RESULT | DEVICES_MEM_RESULT;
assign MEM_DATA_IN = MEM_RESULT;
integer tick = 0;

always @(posedge CLK) begin
    tick = tick + 1;
    if (tick > 1000000) begin
        $display("Time limit exceeded");
        $finish;
    end
    if (HALT) begin
        $display("PROGRAM SUCCESS");
        $finish;
    end
    if (DEVICES_STRW && (MEM_ADDR_OUT == 16'h8012)) begin
        $display("STREAMING %x to OUT\n", MEM_DATA_OUT);
    end
end


//no progress made on this portion
initial begin
    $dumpfile("VRAI_SYNC_TEST.vcd");
    $dumpvars(0, VRAI_sync_tb);
    CLK = 0;
    RESET = 1;
    REQUESTED_TEST_REG = 4'hA;

    #12;
    RESET = 0;
end

endmodule