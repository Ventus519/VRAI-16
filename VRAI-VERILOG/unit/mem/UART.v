module UART_8(
    input wire CLK,

    input wire [7:0] DATA_IN,

    input wire [7:0] CTRL,

    output wire [7:0] WRITE_DATA_OUT,
    output wire [7:0] READ_DATA_OUT,
    output wire [7:0] STATUS
);

reg [7:0] UART_STATUS;
reg [15:0] READ_INDEX;
reg [15:0] ARTIFICIAL_READ_WAIT;
reg [15:0] ARTIFICIAL_WRITE_WAIT;

reg [7:0] HELD_DATA;
reg [7:0] WRITE_DATA_HOLD;
reg [7:0] WRITE_DATA;

reg [7:0] ARTIFICIAL_INPUT_DATA [0:32767];

initial begin
    $readmemh("memories/input.hex", ARTIFICIAL_INPUT_DATA); //eventually going to be serialized first before actually reading. 
    UART_STATUS <= 8'h00;
    ARTIFICIAL_READ_WAIT <= 16'h0000;
    ARTIFICIAL_WRITE_WAIT <= 16'hFFFF;
    READ_INDEX <= 16'h0000;
    HELD_DATA <= 8'h00;
    WRITE_DATA <= 8'h00;
    WRITE_DATA_HOLD <= 8'h00;
end

assign STATUS = UART_STATUS;
assign READ_DATA_OUT = HELD_DATA;
assign WRITE_DATA_OUT = WRITE_DATA;

always @(posedge CLK) begin

    if (ARTIFICIAL_READ_WAIT == 16'hFFFF) begin
        if (~UART_STATUS[1]) begin
            UART_STATUS[1] <= 1;
        end
        UART_STATUS[1] <= 1;
        HELD_DATA <= ARTIFICIAL_INPUT_DATA[READ_INDEX];
    end else begin
        ARTIFICIAL_READ_WAIT <= ARTIFICIAL_READ_WAIT + 1;
        UART_STATUS[1] <= 0;
    end

    if (ARTIFICIAL_WRITE_WAIT == 16'hFFFF) begin
        if (~UART_STATUS[0]) begin
            UART_STATUS[0] <= 1;
        end
        WRITE_DATA <= WRITE_DATA_HOLD;
    end else begin
        ARTIFICIAL_WRITE_WAIT <= ARTIFICIAL_WRITE_WAIT + 1;
        UART_STATUS[0] <= 0;
    end


    if (CTRL[0]) begin
        //requested a write
        if (UART_STATUS[0]) begin
            ARTIFICIAL_WRITE_WAIT <= 16'h0000;
            WRITE_DATA_HOLD <= DATA_IN;
            UART_STATUS[0] <= 0;
        end

    end
    if (CTRL[1]) begin 
        //acknowledge the read
        if (UART_STATUS[1]) begin
            ARTIFICIAL_READ_WAIT <= 16'h0000;
            READ_INDEX <= READ_INDEX + 1;
            UART_STATUS[1] <= 0;
        end

    end
        
end


endmodule