`timescale 1ns / 1ps

module APB_Master (
    // global signals
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic        PENABLE,
    output logic        PSEL0,
    output logic        PSEL1,
    output logic        PSEL2,
    output logic        PSEL3,
    output logic [31:0] PWDATA,
    input  logic [31:0] PRDATA0,
    input  logic [31:0] PRDATA1,
    input  logic [31:0] PRDATA2,
    input  logic [31:0] PRDATA3,
    input  logic        PREADY0,
    input  logic        PREADY1,
    input  logic        PREADY2,
    input  logic        PREADY3,
    // Internal intergace signals
    input  logic        transfer,
    output logic        ready,
    input  logic        write,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [3:0] pselx;
    logic [1:0] mux_sel;
    logic       decoder_en;
    logic [31:0] temp_addr, temp_addr_next, temp_wdata, temp_wdata_next;
    logic temp_write, temp_write_next;

    assign PSEL0 = pselx[0];
    assign PSEL1 = pselx[1];
    assign PSEL2 = pselx[2];
    assign PSEL3 = pselx[3];

    // APB FSM
    typedef enum {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;
    apb_state_e state, state_next;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            state <= IDLE;
            temp_addr <= 0;
            temp_wdata <= 0;
            temp_write <= 0;
        end else begin
            state <= state_next;
            temp_addr <= temp_addr_next;
            temp_wdata <= temp_wdata_next;
            temp_write <= temp_write_next;
        end
    end


    always_comb begin
        state_next      = state;
        decoder_en      = 1'b0;
        temp_addr_next  = temp_addr;
        temp_wdata_next = temp_wdata;
        temp_write_next = temp_write;
        PADDR           = temp_addr;
        PWDATA          = temp_wdata;
        PWRITE          = temp_write;
        case (state)
            IDLE: begin
                decoder_en = 1'b0;
                if (transfer) begin
                    temp_addr_next = addr;
                    temp_wdata_next = wdata;
                    temp_write_next = write; // 기존 값을 유지해야 하므로 따로 임시 저장
                    state_next = SETUP;
                end
            end
            SETUP: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b0;
                PADDR      = temp_addr;
                PWRITE     = temp_write;
                state_next = ACCESS;
                if (temp_write) begin
                    PWDATA = temp_wdata;
                end
            end
            ACCESS: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b1;
                if (ready) begin
                    state_next = IDLE;
                end
            end
        endcase
    end

    APB_Decoder U_APB_Decoder (
        .en(decoder_en),
        .sel(temp_addr),
        .y(pselx),
        .mux_sel(mux_sel)
    );

    APB_MUX u_APB_MUX (
        .sel   (mux_sel),
        .rdata0(PRDATA0),
        .rdata1(PRDATA1),
        .rdata2(PRDATA2),
        .rdata3(PRDATA3),
        .ready0(PREADY0),
        .ready1(PREADY1),
        .ready2(PREADY2),
        .ready3(PREADY3),
        .rdata (rdata),
        .ready (ready)
    );

endmodule

module APB_Decoder (
    input logic en,
    input logic [31:0] sel,
    output logic [3:0] y,
    output logic [1:0] mux_sel
);

    always_comb begin
        y = 4'b0000;
        if (en) begin
            casex (sel)
                32'h1000_0xxx: y = 4'b0001;
                32'h1000_1xxx: y = 4'b0010;
                32'h1000_2xxx: y = 4'b0100;
                32'h1000_3xxx: y = 4'b1000;
            endcase
        end
    end

    always_comb begin
        mux_sel = 2'dx;
        if (en) begin
            casex (sel)
                32'h1000_0xxx: mux_sel = 2'd0;
                32'h1000_1xxx: mux_sel = 2'd1;
                32'h1000_2xxx: mux_sel = 2'd2;
                32'h1000_3xxx: mux_sel = 2'd3;
            endcase
        end
    end
endmodule

module APB_MUX (
    input logic [1:0] sel,
    input logic [31:0] rdata0,
    input logic [31:0] rdata1,
    input logic [31:0] rdata2,
    input logic [31:0] rdata3,
    input logic ready0,
    input logic ready1,
    input logic ready2,
    input logic ready3,
    output logic [31:0] rdata,
    output logic ready
);

    always_comb begin
        rdata = 32'b0;
        ready = 1'b0;
        case (sel)
            2'd0: begin
                rdata = rdata0;
                ready = ready0;
            end
            2'd1: begin
                rdata = rdata1;
                ready = ready1;
            end
            2'd2: begin
                rdata = rdata2;
                ready = ready2;
            end
            2'd3: begin
                rdata = rdata3;
                ready = ready3;
            end
        endcase
    end
endmodule
