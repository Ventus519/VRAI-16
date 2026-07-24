module POPCNT_4
(
    input wire [3:0] A,
    output wire [2:0] COUNT
);

wire A0, A1, A2, A3;
assign A0 = A[0];
assign A1 = A[1];
assign A2 = A[2];
assign A3 = A[3];


wire A01, A02, A03, A12, A13, A23;
assign A01 = A0 & A1;
assign A02 = A0 & A2;
assign A03 = A0 & A3;
assign A12 = A1 & A2;
assign A13 = A1 & A3;
assign A23 = A2 & A3;


wire nA03, nA12;
assign nA03 = ~A0 & ~A3;
assign nA12 = ~A1 & ~A2;

assign COUNT[2] = A03 & A12;
assign COUNT[1] = ~COUNT[2] & (A01 | A02 | A03 | A12 | A13 | A23);
assign COUNT[0] = (~A03 & ~nA03) ^ (~A12 & ~nA12); //functionally just an XOR of all the bits

endmodule

module POPCNT_16
(
    input wire [15:0] A,
    output wire [4:0] COUNT
);

wire [3:0] A_HI0, A_HI1, A_LO0, A_LO1;

assign A_HI0 = A[7:4];
assign A_HI1 = A[11:8];
assign A_LO0 = A[3:0];
assign A_LO1 = A[15:12];

wire [4:0] COUNT_HI0, COUNT_HI1, COUNT_LO0, COUNT_LO1;

assign COUNT_HI0[4] = 0;
assign COUNT_HI0[3] = 0;

assign COUNT_HI1[4] = 0;
assign COUNT_HI1[3] = 0;

assign COUNT_LO0[4] = 0;
assign COUNT_LO0[3] = 0;

assign COUNT_LO1[4] = 0;
assign COUNT_LO1[3] = 0;

POPCNT_4 popcnt_hi0 (
    .A(A_HI0),
    .COUNT(COUNT_HI0[2:0])
);
POPCNT_4 popcnt_hi1 (
    .A(A_HI1),
    .COUNT(COUNT_HI1[2:0])
);
POPCNT_4 popcnt_lo0 (
    .A(A_LO0),
    .COUNT(COUNT_LO0[2:0])
);
POPCNT_4 popcnt_lo1 (
    .A(A_LO1),
    .COUNT(COUNT_LO1[2:0])
);

assign COUNT = COUNT_HI1 + COUNT_HI0 + COUNT_LO1 + COUNT_LO0;


endmodule