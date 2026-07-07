module ADDR_CALC (
    input wire [15:0] BASE_ADDR,
    input wire [15:0] OFFSET,

    output wire MEM_MAIN,
    output wire MEM_DEVICES,

    output wire [15:0] RESULT_ADDR
);

assign RESULT_ADDR = BASE_ADDR + OFFSET;
assign MEM_MAIN = (RESULT_ADDR < 16'h8000) ? 1'b1 : 1'b0;
assign MEM_DEVICES = (RESULT_ADDR >= 16'h8000) ? 1'b1 : 1'b0;


endmodule

module BASIC_MEM(
    input wire CLK,

    input wire [15:0] ADDR,
    input wire [15:0] DATA_IN,
    input wire STRH,
    input wire STRW,
    input wire LDH,
    input wire LDW,

    output reg [15:0] DATA_OUT
);



reg [7:0] MEM [0:32767];

initial begin
    $readmemh("mem_init.hex", MEM);
end

always @(*) begin
    DATA_OUT = 16'h0000;
    if (LDH) begin
        DATA_OUT = {8'h00, MEM[ADDR]};
    end
    else if (LDW && (ADDR < 16'h7FFF)) begin
        DATA_OUT = {MEM[ADDR], MEM[ADDR+1]};
    end
end

always @(posedge CLK)
begin
    if (STRH) begin
        MEM[ADDR] <= DATA_IN[7:0];
    end
    else if (STRW && (ADDR < 16'h7FFF)) begin
        MEM[ADDR] <= DATA_IN[15:8];
        MEM[ADDR+1] <= DATA_IN[7:0];
    end        
end

endmodule

module BASIC_DEV_MEM(
    input wire CLK,

    input wire [15:0] ADDR,
    input wire [15:0] DATA_IN,
    input wire STRH,
    input wire STRW,
    input wire LDH,
    input wire LDW,

    output reg [15:0] DATA_OUT
);



reg [7:0] MEM [0:32767];

initial begin
    $readmemh("mem_device_init.hex", MEM);
end

always @(*) begin
    DATA_OUT = 16'h0000;
    if (LDH) begin
        DATA_OUT = {8'h00, MEM[ADDR]};
    end
    else if (LDW && (ADDR < 16'h7FFF)) begin
        DATA_OUT = {MEM[ADDR], MEM[ADDR+1]};
    end
end

always @(posedge CLK)
begin
    if (STRH) begin
        MEM[ADDR] <= DATA_IN[7:0];
    end
    else if (STRW && (ADDR < 16'h7FFF)) begin
        MEM[ADDR] <= DATA_IN[15:8];
        MEM[ADDR+1] <= DATA_IN[7:0];
    end        
end

endmodule






module MAIN_SYNC_MEM (
    input wire CLK,

    input wire [15:0] ADDR,
    input wire [15:0] DATA_IN,
    input wire STRH,
    input wire STRW,
    input wire LDH,
    input wire LDW,

    output reg [15:0] DATA_OUT
);



reg [7:0] MEM [0:32767];

initial begin
    $readmemh("memories/mem_init.hex", MEM);
end

always @(posedge CLK) begin
    DATA_OUT <= 16'h0000;
    if (STRH) begin
        MEM[ADDR] <= DATA_IN[7:0];
    end
    else if (STRW && (ADDR < 16'h7FFF)) begin
        MEM[ADDR] <= DATA_IN[15:8];
        MEM[ADDR+1] <= DATA_IN[7:0];
    end
    else if (LDH) begin
        DATA_OUT <= {8'h00, MEM[ADDR]};
    end
    else if (LDW && (ADDR < 16'h7FFF)) begin
        DATA_OUT <= {MEM[ADDR], MEM[ADDR+1]};
    end
end

endmodule


module DEVICE_SYNC_MEM (
    input wire CLK,

    input wire [15:0] ADDR,
    input wire [15:0] DATA_IN,
    input wire STRH,
    input wire STRW,
    input wire LDH,
    input wire LDW,

    output reg [15:0] DATA_OUT
);
/*

    STD::IN - 0x8000 ~ 0x800F
    STD::OUT - 0x8010 ~ 0x801F

*/

localparam STD_IN_DATA_ADDR = 16'h0002,
           STD_IN_EN_ADDR = 16'h0000;

reg [16:0] STD_IN_INDEX;

reg [7:0] MEM [0:32767];

reg READ_STD_IN;

reg [16:0] STD_IN [0:32767];

initial begin
    $readmemh("memories/mem_device_init.hex", MEM);
    $readmemh("memories/input.hex", STD_IN);
    STD_IN_INDEX <= 16'h0000;
    READ_STD_IN <= 0;
end

always @(posedge CLK) begin
    DATA_OUT <= 16'h0000;
    if (STRH) begin
        MEM[ADDR] <= DATA_IN[7:0];
        if ((ADDR == STD_IN_EN_ADDR) && (DATA_IN != 8'h00)) begin

            if (~READ_STD_IN) begin
                MEM[STD_IN_DATA_ADDR] <= STD_IN[STD_IN_INDEX][15:8];
                MEM[STD_IN_DATA_ADDR+1] <= STD_IN[STD_IN_INDEX][7:0];
                STD_IN_INDEX <= STD_IN_INDEX + 1;
                READ_STD_IN <= 1;
            end

        end
        else begin
            READ_STD_IN <= 0;
        end
    end
    else if (STRW && (ADDR < 16'h7FFF)) begin
        READ_STD_IN <= 0;
        MEM[ADDR] <= DATA_IN[15:8];
        MEM[ADDR+1] <= DATA_IN[7:0];
    end
    else if (LDH) begin
        READ_STD_IN <= 0;
        DATA_OUT <= {8'h00, MEM[ADDR]};
    end
    else if (LDW && (ADDR < 16'h7FFF)) begin
        READ_STD_IN <= 0;
        DATA_OUT <= {MEM[ADDR], MEM[ADDR+1]};
    end
end

endmodule





module UNIT_MEM (
    input wire [15:0] BASE_ADDR,
    input wire [15:0] OFFSET,

    input wire [15:0] VALUE_IN,
    
    input wire [3:0] CODE,

    output wire [15:0] DEST_ADDR,
    output wire [15:0] VALUE_FOUND,
    
    output wire MEM_MAIN_STRH,
    output wire MEM_MAIN_STRW,
    output wire MEM_MAIN_LDH,
    output wire MEM_MAIN_LDW,

    output wire MEM_DEVICES_STRH,
    output wire MEM_DEVICES_STRW,
    output wire MEM_DEVICES_LDH,
    output wire MEM_DEVICES_LDW,

    output wire MEM_INVALID
);

wire MEM_MAIN;
wire MEM_DEVICES;
wire [15:0] DEST;

ADDR_CALC addr(
    .BASE_ADDR(BASE_ADDR),
    .OFFSET(OFFSET),
    .RESULT_ADDR(DEST),
    .MEM_MAIN(MEM_MAIN),
    .MEM_DEVICES(MEM_DEVICES)
);

assign DEST_ADDR = DEST;

localparam STR_H = 4'h9,
           STR_W = 4'hA,
           LD_H = 4'h1,
           LD_W = 4'h2;


reg STRH;
reg STRW;
reg LDH;
reg LDW;
reg INVALID;

always @(*) begin
    STRH = 0;
    STRW = 0;
    LDH = 0;
    LDW = 0;
    INVALID = 0;
    case (CODE)
        STR_H: STRH = 1;
        STR_W: STRW = 1;
        LD_H: LDH = 1;
        LD_W: LDW = 1;
        default: INVALID = 1;
    endcase
end

assign MEM_MAIN_STRH = MEM_MAIN & STRH;
assign MEM_MAIN_STRW = MEM_MAIN & STRW;
assign MEM_MAIN_LDH = MEM_MAIN & LDH;
assign MEM_MAIN_LDW = MEM_MAIN & LDW;

assign MEM_DEVICES_STRH = MEM_DEVICES & STRH;
assign MEM_DEVICES_STRW = MEM_DEVICES & STRW;
assign MEM_DEVICES_LDH = MEM_DEVICES & LDH;
assign MEM_DEVICES_LDW = MEM_DEVICES & LDW;

assign MEM_INVALID = INVALID;

assign VALUE_FOUND = VALUE_IN;

endmodule
