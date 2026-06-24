module UNIT_DECODER (
    input wire [3:0] UNIT_CODE,

    output reg UNIT_SYS_EN,
    output reg UNIT_ALU_EN,
    output reg UNIT_MEM_EN,
    output reg UNIT_JMP_EN,
    output reg UNIT_BIT_EN,

    output reg UNIT_INVALID
);

localparam [3:0] 
    UNIT_SYS = 4'h0,
    UNIT_ALU = 4'h1,
    UNIT_MEM = 4'h2,
    UNIT_JMP = 4'h3,
    UNIT_BIT = 4'h4;

always @(*) begin
    UNIT_SYS_EN = 0;
    UNIT_ALU_EN = 0;
    UNIT_MEM_EN = 0;
    UNIT_JMP_EN = 0;
    UNIT_BIT_EN = 0;
    UNIT_INVALID = 0;

    case (UNIT_CODE)
        UNIT_SYS: UNIT_SYS_EN = 1;
        UNIT_ALU: UNIT_ALU_EN = 1;
        UNIT_MEM: UNIT_MEM_EN = 1;
        UNIT_JMP: UNIT_JMP_EN = 1;
        UNIT_BIT: UNIT_BIT_EN = 1;

        default: UNIT_INVALID = 1; //INVALID INSTRUCTION IF UNIT_CODE IS NOT RECOGNIZED
    endcase
end

endmodule