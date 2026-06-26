`timescale 1ps/1ps
`include "VRAI-VERILOG/VRAI_CORE.v"
module INSTR_MEM (
    input wire [15:0] INSTR_ADDR,

    output wire [31:0] INSTR_STREAM
);

reg [31:0] MEM_INSTR [0:38];

initial begin
    $readmemh("program.hex", MEM_INSTR);
end

assign INSTR_STREAM = MEM_INSTR[INSTR_ADDR >> 2];

endmodule

module VRAI_tb ();

reg CLK;
reg RESET;

wire [31:0] INSTR_STREAM;

always
#1 CLK = ~CLK;

wire[15:0] INSTR_ADDR;

reg [3:0] REQUESTED_TEST_REG;

wire [15:0] TEST_ZR;
wire [15:0] TEST_COND;
wire [15:0] TEST_REG;

wire [15:0] MEM_DATA_IN;
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
VRAI_CORE core (
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
    .MEM_DATA_IN(MEM_DATA_IN)
);

INSTR_MEM instr_mem (
    .INSTR_ADDR(INSTR_ADDR),
    .INSTR_STREAM(INSTR_STREAM)
);

wire [15:0] MAIN_MEM_RESULT;
BASIC_MEM main_mem (
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
BASIC_DEV_MEM devices_mem (
    .CLK(CLK),
    .ADDR({1'b0, MEM_ADDR_OUT[14:0]}),
    .DATA_IN(MEM_DATA_OUT),
    .STRH(DEVICES_STRH),
    .STRW(DEVICES_STRW),
    .LDH(DEVICES_LDH),
    .LDW(DEVICES_LDW),
    .DATA_OUT(DEVICES_MEM_RESULT)
);

assign MEM_DATA_IN = DEVICES_MEM_RESULT | MAIN_MEM_RESULT;

integer tick = 0;
always @(posedge CLK) begin
    tick = tick + 1;
    if (tick > 6000) begin
        $display("Time limit exceeded");
        $finish;
    end
    if (INSTR_STREAM == 32'h000f0000) begin
    $display("PROGRAM SUCCESS");
    $finish;
    end
    //easier way read output values
    if ((DEVICES_STRW) && (MEM_ADDR_OUT == 16'h8012)) begin 
        $display("OUT: %x\n", MEM_DATA_OUT);
    end

end


initial begin

$dumpfile("VRAI_TEST.vcd");
$dumpvars(0, VRAI_tb);
CLK = 0;
RESET = 1;
REQUESTED_TEST_REG = 4'hC; 

#2;
RESET = 0;


end




endmodule