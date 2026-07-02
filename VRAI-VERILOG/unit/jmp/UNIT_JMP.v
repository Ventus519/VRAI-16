module UNIT_JMP (
    input wire [15:0] COND_FLAGS,
    input wire [3:0] CODE,

    output wire COND_MET
);

/*
localparam [3:0] 
    NJMP = 4'h0, //never jump
    JE = 4'h1,   //jmp if COND_FLAGS recorded "equal"
    JL = 4'h2,   //jmp if COND_FLAGS recorded "signed less than"
    JLE = 4'h3,  //jmp if COND_FLAGS recorded "signed less than" or "equal"
    JB = 4'h4,   //jmp if COND_FLAGS recorded "below (unsigned less than)"
    JBE = 4'h5,  //jmp if COND_FLAGS recorded "below (unsigned less than)" or "equal"
    
    JMP = 4'h8,  //jmp always (unconditional jump)
    JNE = 4'h9,  //jmp if COND_FLAGS did NOT record "equal"
    JGE = 4'hA;  //jmp if COND_FLAGS did NOT record "signed less than"
    JG = 4'hB;   //jmp if COND_FLAGS did NOT record "signed less than" nor "equal"
    JAE = 4'hC;  //jmp if COND_FLAGS did NOT record "below (unsigned less than)"
    JA = 4'hD;   //jmp if COND_FLAGS did NOT record "below (unsigned less than)" nor "equal"

    //ALL OTHER JUMP CODES ARE RESERVED FOR FUTURE USE


Recall that the condition flags in the COND register were generated using CMP/CMPI with the following logic:
            RESULT[0] = (A == B); //Equal
            RESULT[1] = (A < B); //Unsigned BELOW
            RESULT[2] = ($signed(A) < $signed(B)); //Signed LESS
*/

assign COND_MET = ((CODE[0] & COND_FLAGS[0]) | //JE CONDITION
           (CODE[1] & COND_FLAGS[2]) | //JL CONDITION
           (CODE[2] & COND_FLAGS[1]) //JB CONDITION
           ) ^ (CODE[3]); //INVERT CONDITION 


endmodule