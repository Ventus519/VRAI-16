module formal_top ();

(* gclk *) wire CLK;
reg RESET = 1'b1;
reg [3:0] RESET_CYCLE_COUNT = 4'h0;

(* anyseq *) wire [31:0] INSTR_STREAM;
wire [15:0] INSTR_ADDR;

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

(* anyseq *) wire [15:0] MEM_LD_DATA;

wire HALT;

VRAI_SYNC_CORE vrai_core (
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

    .INVALID_MEM(INVALID_MEM),

    .MEM_STR_DATA(MEM_STR_DATA),
    .MEM_ADDR(MEM_ADDR),

    .MEM_LD_DATA(MEM_LD_DATA),
    
    .EX_HALT(HALT)
);


always @(posedge CLK) begin
    if (RESET_CYCLE_COUNT == 4'h2) begin
        RESET <= 1'b0;
    end else begin
        RESET_CYCLE_COUNT <= RESET_CYCLE_COUNT + 4'h1;
    end
end

endmodule