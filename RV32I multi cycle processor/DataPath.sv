`timescale 1ns / 1ps
`include "defines.sv"

module DataPath (
    // global signals
    input  logic        clk,
    input  logic        reset,
    // instruction memory side port
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    // control unit side port
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    input  logic        aluSrcMuxSel,
    input  logic [ 2:0] RFWDSrcMuxSel,
    input  logic        branch,
    input  logic        jal,
    input  logic        jalr,
    input  logic        PCEn,
    input  logic [ 1:0] StoreSizeMuxSel,
    input  logic [ 2:0] LoadSizeMuxSel,
    output logic        st_misaligned,
    // data memory side port
    output logic [31:0] busAddr,
    output logic [31:0] busWData,
    input  logic [31:0] busRData,
    output logic [ 3:0] wstrb
);

    //wire list -> 정리할 것
    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCSrcData, PCOutData, PC_Imm_AdderSrcMuxOut;
    logic [31:0] aluSrcMuxOut, immExt, RFWDSrcMuxOut;
    logic [31:0] PC_4_AdderResult, PC_Imm_AdderResult, PCSrcMuxOut;
    logic PCSrcMuxSel;
    logic btaken;
    logic [31:0]
        DecReg_RFData1, DecReg_RFData2, DecReg_ImmExt, ExeReg_aluResult;
    logic [31:0] ExeReg_RFData2, ExeReg_PCSrcMuxOut, MemAccReg_busRData;
    logic [31:0] StoreSize_Muxout, LoadSize_Muxout;
    logic ld_misaligned;
    logic actual_regFileWe;

    assign instrMemAddr = PCOutData;
    assign busAddr = ExeReg_aluResult;
    // assign busWData = ExeReg_RFData2;
    assign busWData = StoreSize_Muxout;
    assign actual_regFileWe = regFileWe & ~ld_misaligned;

    RegisterFile U_RegFile (
        .clk(clk),
        .we (actual_regFileWe),
        .RA1(instrCode[19:15]),
        .RA2(instrCode[24:20]),
        .WA (instrCode[11:7]),
        .WD (RFWDSrcMuxOut),
        .RD1(RFData1),
        .RD2(RFData2)
    );

    register U_DecReg_RFRD1 (
        .clk(clk),
        .reset(reset),
        .d(RFData1),
        .q(DecReg_RFData1)
    );

    register U_DecReg_RFRD2 (
        .clk(clk),
        .reset(reset),
        .d(RFData2),
        .q(DecReg_RFData2)
    );

    store_size_unit u_Store_Size_Mux (
        .sel(StoreSizeMuxSel),
        .addr(ExeReg_aluResult),  // 효과 주소
        .RD2Data(ExeReg_RFData2),     // 저장할 원본 데이터 (레지스터 rs2)
        .WData(StoreSize_Muxout),        // 메모리 쓰기 데이터(정렬된 워드, 바이트 위치 반영)
        .wstrb(wstrb),  // 바이트 쓰기 인에이블
        .o_misaligned(st_misaligned)  // 정렬 위반 플래그
    );

    register U_ExeReg_RFD2 (
        .clk(clk),
        .reset(reset),
        .d(DecReg_RFData2),
        .q(ExeReg_RFData2)
    );

    mux_2x1 U_AluSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (DecReg_RFData2),
        .x1 (DecReg_ImmExt),
        .y  (aluSrcMuxOut)
    );

    register U_MemAccReg_ReadData (
        .clk(clk),
        .reset(reset),
        .d(busRData),
        .q(MemAccReg_busRData)
    );

    load_size_unit U_Load_Size_Mux (
        .sel(LoadSizeMuxSel),  // instrCode[14:12]
        .addr(ExeReg_aluResult),  // 효과 주소 (rs1 + imm)
        .MemData(MemAccReg_busRData),     // 메모리에서 읽은 정렬된 32b 워드
        .RData(LoadSize_Muxout),  // 레지스터에 기록할 32b 데이터
        .o_misaligned(ld_misaligned)  // 정렬 위반 플래그 (상위에서 트랩 처리)
    );

    mux_5x1 U_RFWDSrcMux (
        .sel(RFWDSrcMuxSel),
        .x0 (aluResult),
        .x1 (LoadSize_Muxout),
        // .x1 (MemAccReg_busRData),
        .x2 (DecReg_ImmExt),
        .x3 (PC_Imm_AdderResult),
        .x4 (PC_4_AdderResult),
        .y  (RFWDSrcMuxOut)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a         (DecReg_RFData1),
        .b         (aluSrcMuxOut),
        .result    (aluResult),
        .btaken    (btaken)
    );

    register U_ExeReg_ALU (
        .clk(clk),
        .reset(reset),
        .d(aluResult),
        .q(ExeReg_aluResult)
    );

    immExtend U_ImmExtend (
        .instrCode(instrCode),
        .immExt   (immExt)
    );


    register U_DecReg_ImmExtend (
        .clk(clk),
        .reset(reset),
        .d(immExt),
        .q(DecReg_ImmExt)
    );

    mux_2x1 U_PC_Imm_AdderSrcMux (
        .sel(jalr),
        .x0 (PCOutData),
        .x1 (DecReg_RFData1),
        .y  (PC_Imm_AdderSrcMuxOut)
    );

    adder U_PC_Imm_Adder (
        .a(DecReg_ImmExt),
        .b(PC_Imm_AdderSrcMuxOut),
        .y(PC_Imm_AdderResult)
    );

    adder U_PC_4_Adder (
        .a(32'd4),
        .b(PCOutData),
        .y(PC_4_AdderResult)
    );

    assign PCSrcMuxSel = jal | (btaken & branch);

    mux_2x1 U_PCSrcMux (
        .sel(PCSrcMuxSel),
        .x0 (PC_4_AdderResult),
        .x1 (PC_Imm_AdderResult),
        .y  (PCSrcMuxOut)
    );

    register U_ExeReg (
        .clk(clk),
        .reset(reset),
        .d(PCSrcMuxOut),
        .q(ExeReg_PCSrcMuxOut)
    );

    registerEn U_PC (
        .clk  (clk),
        .reset(reset),
        .en   (PCEn),
        .d    (ExeReg_PCSrcMuxOut),
        .q    (PCOutData)
    );

endmodule

module alu (
    input  logic [ 3:0] aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result,
    output logic        btaken
);

    always_comb begin
        result = 32'bx;
        case (aluControl)
            `ADD:  result = a + b;
            `SUB:  result = a - b;
            `SLL:  result = a << b;
            `SRL:  result = a >> b;
            `SRA:  result = $signed(a) >>> b;
            `SLT:  result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU: result = (a < b) ? 1 : 0;
            `XOR:  result = a ^ b;
            `OR:   result = a | b;
            `AND:  result = a & b;
        endcase
    end

    always_comb begin : branch
        btaken = 1'b0;
        case (aluControl[2:0])
            `BEQ:  btaken = (a == b);
            `BNE:  btaken = (a != b);
            `BLT:  btaken = ($signed(a) < $signed(b));
            `BGE:  btaken = ($signed(a) >= $signed(b));
            `BLTU: btaken = (a < b);
            `BGEU: btaken = (a >= b);
        endcase
    end
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RA1,
    input  logic [ 4:0] RA2,
    input  logic [ 4:0] WA,
    input  logic [31:0] WD,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] mem[0:2**5-1];


    initial begin  // for simulation test
        for (int i = 0; i < 5; i++) begin
            mem[i] = 10 + i;  // 10 ~ 14
        end
        for (int j = 5; j < 10; j++) begin
            mem[j] = -10 - j + 5;  // -10 ~ -14
        end
    end


    always_ff @(posedge clk) begin
        if (we) mem[WA] <= WD;
    end

    assign RD1 = (RA1 != 0) ? mem[RA1] : 32'b0;
    assign RD2 = (RA2 != 0) ? mem[RA2] : 32'b0;
endmodule


module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end
endmodule

module registerEn (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (en) q <= d;
        end
    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);
    always_comb begin
        y = 32'bx;
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
        endcase
    end
endmodule

module mux_5x1 (
    input  logic [ 2:0] sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    input  logic [31:0] x2,
    input  logic [31:0] x3,
    input  logic [31:0] x4,
    output logic [31:0] y
);
    always_comb begin
        y = 32'bx;
        case (sel)
            3'b000: y = x0;
            3'b001: y = x1;
            3'b010: y = x2;
            3'b011: y = x3;
            3'b100: y = x4;
        endcase
    end
endmodule

module immExtend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];
    wire [2:0] func3 = instrCode[14:12];

    always_comb begin
        immExt = 32'bx;
        case (opcode)
            `OP_TYPE_R: immExt = 32'bx;  // R-Type
            `OP_TYPE_L: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
            `OP_TYPE_S:
            immExt = {
                {20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]
            };  // S-Type
            `OP_TYPE_I: begin
                case (func3)
                    3'b001:  immExt = {27'b0, instrCode[24:20]};  // SLLI
                    3'b101:  immExt = {27'b0, instrCode[24:20]};  // SRLI, SRAI
                    3'b011:  immExt = {20'b0, instrCode[31:20]};  // SLTIU
                    default: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
                endcase
            end
            `OP_TYPE_B:
            immExt = {
                {20{instrCode[31]}},
                instrCode[7],
                instrCode[30:25],
                instrCode[11:8],
                1'b0
            };
            `OP_TYPE_LU: immExt = {instrCode[31:12], 12'b0};
            `OP_TYPE_AU: immExt = {instrCode[31:12], 12'b0};
            `OP_TYPE_J:
            immExt = {
                {12{instrCode[31]}},
                instrCode[19:12],
                instrCode[20],
                instrCode[30:21],
                1'b0
            };
            `OP_TYPE_JL: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
        endcase
    end
endmodule

module load_size_unit #(
    parameter ALLOW_LH_INWORD = 1
) (
    input  logic [ 2:0] sel,          // 읽어올 크기 설정
    input  logic [31:0] addr,         // 읽어올 주소
    input  logic [31:0] MemData,      // 읽어올 데이터 원본
    output logic [31:0] RData,
    output logic        o_misaligned
);
    localparam LB = 3'b000;
    localparam LH = 3'b001;
    localparam LW = 3'b010;
    localparam LBU = 3'b100;
    localparam LHU = 3'b101;

    logic [1:0] byte_sel;
    assign byte_sel = addr[1:0];

    // logic [4:0] shamt8;
    // assign shamt8 = {byte_sel, 3'b000};

    always_comb begin
        RData = 32'b0;
        o_misaligned = 1'b0;
        unique case (sel)
            LW: begin
                o_misaligned = |byte_sel;
                if (o_misaligned == 0) begin
                    RData = MemData;
                end
            end
            LB: begin
                o_misaligned = 1'b0;
                unique case (byte_sel)
                    2'b00:
                    RData = {
                        {24{MemData[7]}}, MemData[7:0]
                    };  // 첫번째 byte
                    2'b01:
                    RData = {
                        {24{MemData[15]}}, MemData[15:8]
                    };  // 두번째 byte
                    2'b10:
                    RData = {
                        {24{MemData[23]}}, MemData[23:16]
                    };  // 세번째 byte
                    2'b11:
                    RData = {
                        {24{MemData[31]}}, MemData[31:24]
                    };  // 네번째 byte
                endcase
            end
            LBU: begin
                o_misaligned = 1'b0;
                unique case (byte_sel)
                    2'd0:
                    RData = {{24{1'b0}}, MemData[7:0]};  // 첫번째 byte
                    2'd1:
                    RData = {{24{1'b0}}, MemData[15:8]};  // 두번째 byte
                    2'd2:
                    RData = {{24{1'b0}}, MemData[23:16]};  // 세번째 byte
                    2'd3:
                    RData = {{24{1'b0}}, MemData[31:24]};  // 네번째 byte
                endcase
            end
            LH: begin
                unique case (byte_sel)
                    2'd0: begin
                        o_misaligned = 1'b0;
                        RData = {{16{MemData[15]}}, MemData[15:0]};
                    end
                    2'd2: begin
                        o_misaligned = 1'b0;
                        RData = {{16{MemData[31]}}, MemData[31:16]};
                    end
                    2'd1: begin
                        if (ALLOW_LH_INWORD) begin
                            o_misaligned = 1'b0;
                            RData = {{16{MemData[23]}}, MemData[23:8]};
                        end else o_misaligned = 1'b1;
                    end
                    2'd3: begin
                        o_misaligned = 1'b1;
                    end
                endcase
            end
            LHU: begin
                unique case (byte_sel)
                    2'd0: begin
                        o_misaligned = 1'b0;
                        RData = {{16{1'b0}}, MemData[15:0]};
                    end
                    2'd2: begin
                        o_misaligned = 1'b0;
                        RData = {{16{1'b0}}, MemData[31:16]};
                    end
                    2'd1: begin
                        if (ALLOW_LH_INWORD) begin
                            o_misaligned = 1'b0;
                            RData = {{16{1'b0}}, MemData[23:8]};
                        end else o_misaligned = 1'b1;
                    end
                    2'd3: begin
                        o_misaligned = 1'b1;
                    end
                endcase
            end
        endcase
    end

endmodule

module store_size_unit #(
    parameter ALLOW_SH_INWORD = 1
) (
    input  logic [ 1:0] sel,          //저장할 크기 지정
    input  logic [31:0] addr,         //저장할 주소
    input  logic [31:0] RD2Data,      //저장할 데이터 원본
    output logic [31:0] WData,        //크기에 맞게 잘린 데이터
    output logic [ 3:0] wstrb,        //잘린 데이터가 저장할 위치
    output logic        o_misaligned  //저장을 안할 신호
);

    localparam SB = 2'b00;
    localparam SH = 2'b01;
    localparam SW = 2'b10;

    logic [1:0] byte_sel;
    assign byte_sel = addr[1:0]; // 하위 2비트로 저장할 바이트 위치 설정
    logic [4:0] shamt8;  // 0, 8, 16, 24
    assign shamt8 = {byte_sel, 3'b000};

    always_comb begin
        WData        = 32'h0000_0000;
        wstrb        = 4'b0000;
        o_misaligned = 1'b0;
        unique case (sel)
            SW: begin
                if (byte_sel == 2'b00) begin
                    o_misaligned = 1'b0;  //저장함
                    WData = RD2Data;
                    wstrb = 4'hf;
                end else begin
                    // WData = 32'bx;
                    o_misaligned = 1'b1;  // 저장 안함
                    wstrb = 4'h0;
                end
            end
            //  SW: begin
            //     o_misaligned = |off;      // off!=0이면 미정렬
            //     if (!o_misaligned) begin
            //         WData = RD2Data;
            //         wstrb = 4'b1111;
            //     end
            // end
            SB: begin
                WData = {{24{1'b0}}, RD2Data[7:0]} << shamt8;
                o_misaligned = 1'b0;  //항상 저장
                case (byte_sel)
                    2'b00: wstrb = 4'b0001;  // 첫번째 byte
                    2'b01: wstrb = 4'b0010;  // 두번째 byte     
                    2'b10: wstrb = 4'b0100;  // 세번째 byte
                    2'b11: wstrb = 4'b1000;  // 네번째 byte
                endcase
            end
            SH: begin
                case (byte_sel)
                    2'd0: begin
                        WData = {{16{1'b0}}, RD2Data[15:0]};
                        wstrb = 4'b0011;
                        o_misaligned = 1'b0;
                    end
                    2'd2: begin
                        WData = {RD2Data[15:0], {16{1'b0}}};
                        wstrb = 4'b1100;
                        o_misaligned = 1'b0;
                    end
                    2'd1: begin
                        if (ALLOW_SH_INWORD) begin
                            WData = {8'h00, RD2Data[15:0], 8'h00};
                            wstrb = 4'b0110;
                            o_misaligned = 1'b0;
                        end else begin
                            o_misaligned = 1'b1;
                            wstrb = 4'h0;
                        end
                    end
                    2'd3: begin
                        o_misaligned = 1'b1;
                    end
                endcase
            end
        endcase
    end

endmodule
