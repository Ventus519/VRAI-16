//This file is still in progress, nowhere near done

`timescale 1ps/1ps
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

wire MAIN_STRH;
wire MAIN_STRW;
wire MAIN_LDH;
wire MAIN_LDW;

wire DEVICES_STRH;
wire DEVICES_STRW;
wire DEVICES_LDH;
wire DEVICES_LDW;

wire INVALID_MEM;

wire [15:0] MEM_STR_DATA;
wire [15:0] MEM_ADDR;
wire [15:0] MEM_LD_DATA;

wire HALT;

//not complete port descriptions
VRAI_SYNC_CORE vrai_sync_core (
    .CLK(CLK),
    .RESET(RESET),
    
    .INSTR_STREAM(INSTR_STREAM),
    .INSTR_ADDR(INSTR_ADDR),
    
    .MAIN_STRH(MAIN_STRH),
    .MAIN_STRW(MAIN_STRW),
    .MAIN_LDH(MAIN_LDH),
    .MAIN_LDW(MAIN_LDW),

    .DEVICES_STRH(DEVICES_STRH),
    .DEVICES_STRW(DEVICES_STRW),
    .DEVICES_LDH(DEVICES_LDH),
    .DEVICES_LDW(DEVICES_LDW),

    .MEM_STR_DATA(MEM_STR_DATA),
    .MEM_ADDR(MEM_ADDR),
    .MEM_LD_DATA(MEM_LD_DATA),
    
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
    .ADDR({1'b0, MEM_ADDR[14:0]}),
    .DATA_IN(MEM_STR_DATA),
    .STRH(MAIN_STRH),
    .STRW(MAIN_STRW),
    .LDH(MAIN_LDH),
    .LDW(MAIN_LDW),

    .DATA_OUT(MAIN_MEM_RESULT)
);


wire [15:0] DEVICES_MEM_RESULT;
DEVICE_SYNC_MEM device_sync_mem (
    .CLK(CLK),
    .ADDR({1'b0, MEM_ADDR[14:0]}),
    .DATA_IN(MEM_STR_DATA),
    .STRH(DEVICES_STRH),
    .STRW(DEVICES_STRW),
    .LDH(DEVICES_LDH),
    .LDW(DEVICES_LDW),

    .DATA_OUT(DEVICES_MEM_RESULT)
);

wire [15:0] MEM_RESULT;
assign MEM_RESULT = MAIN_MEM_RESULT | DEVICES_MEM_RESULT;
assign MEM_LD_DATA = MEM_RESULT;
integer tick = 0;
integer count = 0;

always @(posedge CLK) begin
    tick = tick + 1;
    if (tick > 100000000) begin
        $display("Time limit exceeded");
        $finish;
    end
    if (HALT) begin
        $display("PROGRAM SUCCESS");
        $finish;
    end

    if (count != 0) begin
        count = (count + 1)%6;
    end
    else if (DEVICES_STRW && (MEM_ADDR == 16'h8012)) begin
        count = 1;
        $display("STREAMING %x to OUT\n", MEM_STR_DATA);
    end
end


//no progress made on this portion
initial begin
    $dumpfile("build/VRAI_SYNC_TEST.vcd");
    $dumpvars(0, VRAI_sync_tb);
    CLK = 0;
    RESET = 1;

    #12;
    RESET = 0;
end

endmodule



/*
4494
a3b2
7879
82e0
85bd
36f8
5c05
5e02
0918
360a
ab15
6145
26cc
19ab
e116
ee21
*/