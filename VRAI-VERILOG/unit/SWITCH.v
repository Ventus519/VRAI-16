module SWITCH #(parameter size = 16)
(
    input wire [size-1:0] IN,
    input wire SW_EN,
    
    output wire [size-1:0] OUT
);

assign OUT = (SW_EN)? IN : 0;

endmodule