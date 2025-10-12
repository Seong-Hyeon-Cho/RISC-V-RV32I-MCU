`timescale 1ns / 1ps

module FND_Periph (
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 2:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA, // numer 받음
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // External Port
    output logic [ 3:0] fndCom,
    output logic [ 7:0] fndFont
);

    // wire list
    logic tick_1khz;
    logic [1:0] count;
    logic [3:0] digit_1, digit_10, digit_100, digit_1000, digit;

    logic [7:0] cr, odr, gpo;
    
    APB_SlaveIntf_GPO u_APB_SlaveIntf_GPO (.*);
    GPO u_GPO (.*);

    clk_div_1khz u_clk_div_1khz (
        .clk      (PCLK),
        .reset    (PRESET),
        .tick_1khz(tick_1khz)
    );
    counter_2bit U_Counter_2bit (
        .clk  (PCLK),
        .reset(PRESET),
        .tick (tick_1khz),
        .count(count)
    );

    decoder_2x4 U_Decoder_2x4 (
        .x(count),
        .y(fndCom)
    );

    digitSplitter U_DigitSplitter (
        .number    (gpo),
        .digit_1   (digit_1),
        .digit_10  (digit_10),
        .digit_100 (digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 U_Mux_4x1 (
        .sel(count),
        .x0 (digit_1),
        .x1 (digit_10),
        .x2 (digit_100),
        .x3 (digit_1000),
        .y  (digit)
    );

    BCDtoFND_Decoder U_BCDtoFND (
        .bcd(digit),
        .fnd(fndFont)
    );

endmodule

