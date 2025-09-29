`timescale 1ns / 1ps

module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData,
    input  logic [ 3:0] wstrb,
    input  logic        st_misaligned
);
    localparam DEPTH_WORDS = 64;  // 64 words = 256 bytes
    localparam ADDR_LSB = 2;  // word align
    localparam ADDR_MSB = ADDR_LSB + $clog2(DEPTH_WORDS) - 1;  // = 7

    logic [31:0] mem[0:DEPTH_WORDS-1];
    wire [$clog2(DEPTH_WORDS)-1:0] word_idx = addr[ADDR_MSB:ADDR_LSB];  // addr[7:2]
    //0x00 ~ 0x3f, 0x40 x 4 = 0x100
    
    always_ff @(posedge clk) begin
        if (we & !st_misaligned) begin
            if (wstrb[0]) mem[word_idx][7:0] <= wData[7:0];
            if (wstrb[1]) mem[word_idx][15:8] <= wData[15:8];
            if (wstrb[2]) mem[word_idx][23:16] <= wData[23:16];
            if (wstrb[3]) mem[word_idx][31:24] <= wData[31:24];
        end
    end


    assign rData = mem[addr[31:2]];
endmodule
