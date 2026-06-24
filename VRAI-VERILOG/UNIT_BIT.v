`include "VRAI-VERILOG/CLZ.v"
`include "VRAI-VERILOG/CTZ.v"
`include "VRAI-VERILOG/POPCNT.v"

module UNIT_BIT (
    input wire [15:0] A,
    input wire [15:0] B,

    input wire [15:0] IMM,

    input wire [3:0] CODE,
    
    output reg [15:0] RESULT
);

localparam [3:0] 
    AND = 4'h0,
    OR = 4'h1,
    NOR = 4'h2,
    XNOR = 4'h3,
    ROL = 4'h4,
    ROR = 4'h5,
    CTZ = 4'h6,
    CLZ = 4'h7,
    ANDI = 4'h8,
    ORI = 4'h9,
    NORI = 4'hA,
    XNORI = 4'hB,
    ROLI = 4'hC,
    RORI = 4'hD,
    POPCNT = 4'hE;


wire [4:0] CTZ_COUNT;
wire [4:0] CLZ_COUNT;
wire [5:0] POPCNT_COUNT;

CTZ_16 ctz_unit (
    .A(A),
    .COUNT(CTZ_COUNT)
);

CLZ_16 clz_unit (
    .A(A),
    .COUNT(CLZ_COUNT)
);

POPCNT_16 popcnt_unit (
    .A(A),
    .COUNT(POPCNT_COUNT)
);

always @(*) begin
    RESULT = 16'h0000;
    case (CODE)
        AND: RESULT = A & B;
        OR: RESULT = A | B;
        NOR: RESULT = ~(A | B);
        XNOR: RESULT = ~(A ^ B);
        ROL: RESULT = (A << B[3:0]) | (A >> (16 - B[3:0]));
        ROR: RESULT = (A >> B[3:0]) | (A << (16 - B[3:0]));
        CTZ: RESULT = CTZ_COUNT;
        CLZ: RESULT = CLZ_COUNT;
        ANDI: RESULT = A & IMM;
        ORI: RESULT = A | IMM;
        NORI: RESULT = ~(A | IMM);
        XNORI: RESULT = ~(A ^ IMM);
        ROLI: RESULT = (A << IMM[3:0]) | (A >> (16 - IMM[3:0]));
        RORI: RESULT = (A >> IMM[3:0]) | (A << (16 - IMM[3:0]));
        POPCNT: RESULT = POPCNT_COUNT;
        default: RESULT = 16'h0000; //DEFAULT TO ZERO FOR UNRECOGNIZED CODES
    endcase

end

endmodule
