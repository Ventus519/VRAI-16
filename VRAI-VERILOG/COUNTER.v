module COUNTER (
    input wire CLK,
    input wire RESET,
    input wire OVERWRITE,
    input wire ENABLE,

    input wire [15:0] OVERWRITE_VALUE,
    
    output reg [15:0] COUNT
);

//uses increments of 4 since each instruction is 4 bytes wide.

always @(posedge CLK) begin
    if (RESET)
        COUNT <= 16'h0000;

    else if (ENABLE) begin
        if (OVERWRITE)
            COUNT <= OVERWRITE_VALUE;
        else
            COUNT <= COUNT + 4;
    end
end

endmodule