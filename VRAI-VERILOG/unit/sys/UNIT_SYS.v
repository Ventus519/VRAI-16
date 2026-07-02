//SYS CATEGORY DECODER

module SYS_CATEGORY_DECODER (
    input wire [3:0] CODE,
    input wire UNIT_SYS_EN,

    output reg SYS_EX_CTRL,
    output reg SYS_ACCESS,
    output reg SYS_INVALID
);

localparam EX_CTRL = 4'h0,
           ACCESS = 4'h1;

always @(*) begin
    SYS_EX_CTRL = 0;
    SYS_ACCESS = 0;
    SYS_INVALID = 0;
    if (UNIT_SYS_EN) begin
        case (CODE)
            EX_CTRL: SYS_EX_CTRL = 1;
            ACCESS: SYS_ACCESS = 1;
            default: SYS_INVALID = 1;
        endcase
    end
end


endmodule

//SYS CODE DECODERS
module SYS_EX_CTRL_DECODER (
    input wire [3:0] CODE,
    input wire SYS_EX_CTRL,

    output reg SYS_NOP,
    output reg SYS_HALT,
    output reg SYS_EX_CTRL_INVALID
);

localparam NOP = 4'h0,
           HALT = 4'hF;

always @(*) begin
    SYS_NOP = 0;
    SYS_HALT = 0;
    SYS_EX_CTRL_INVALID = 0;
    if (SYS_EX_CTRL) begin
        case (CODE)
            NOP: SYS_NOP = 1;
            HALT: SYS_HALT = 1;
            default: SYS_EX_CTRL_INVALID = 1;
        endcase
    end
end


endmodule

module SYS_ACCESS_DECODER (
    input wire [3:0] CODE,
    input wire SYS_ACCESS,

    output reg SYS_COUNT,
    output reg SYS_ACCESS_INVALID
);

localparam COUNT = 4'h0;

always @(*) begin
    SYS_COUNT = 0;
    SYS_ACCESS_INVALID = 0;
    if (SYS_ACCESS) begin
        case (CODE)
            COUNT: SYS_COUNT = 1;
            default: SYS_ACCESS_INVALID = 1; 
        endcase
    end
end

endmodule
