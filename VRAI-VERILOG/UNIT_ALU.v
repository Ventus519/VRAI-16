module UNIT_ALU (
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [15:0] IMM,

    input wire [3:0] CODE,
    
    output reg [15:0] RESULT
);

localparam [3:0] 
    CMP = 4'h0,
    ASR = 4'h1,
    ADD = 4'h2,
    SUB = 4'h3,
    LSL = 4'h4,
    LSR = 4'h5,
    NAND = 4'h6,
    XOR = 4'h7,
    CMPI = 4'h8,
    ASRI = 4'h9,
    ADDI = 4'hA,
    SUBI = 4'hB,
    LSLI = 4'hC,
    LSRI = 4'hD,
    NANDI = 4'hE,
    XORI = 4'hF;


always @(*) begin
    RESULT = 16'h0000;
    case (CODE)
        CMP: 
        begin
            RESULT[0] = (A == B);
            RESULT[1] = (A < B);
            RESULT[2] = ($signed(A) < $signed(B));
        end
        ASR: RESULT = $signed(A) >>> B[3:0]; 
        ADD: RESULT = A + B; 
        SUB: RESULT = A - B;
        LSL: RESULT = A << B[3:0];
        LSR: RESULT = A >> B[3:0];
        NAND: RESULT = ~(A & B);
        XOR: RESULT = A ^ B;

        CMPI:
        begin
            RESULT[0] = (A == IMM);
            RESULT[1] = (A < IMM);
            RESULT[2] = ($signed(A) < $signed(IMM));
        end
        ASRI: RESULT = $signed(A) >>> IMM[3:0];
        ADDI: RESULT = A + IMM;
        SUBI: RESULT = A - IMM;
        LSLI: RESULT = A << IMM[3:0];
        LSRI: RESULT = A >> IMM[3:0];
        NANDI: RESULT = ~(A & IMM);
        XORI: RESULT = A ^ IMM;

        default: RESULT = 16'h0000;
    endcase
end

endmodule