`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic        PCEn,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic [ 2:0] LoadSizeMuxSel,
    output logic        busWe,
    output logic [ 1:0] StoreSizeMuxSel,
    output logic [ 2:0] RFWDSrcMuxSel,
    output logic        branch,
    output logic        jal,
    output logic        jalr
);
    wire  [ 6:0] opcode = instrCode[6:0];
    wire  [ 3:0] operator = {instrCode[30], instrCode[14:12]};
    logic [14:0] signals;
    assign {PCEn, regFileWe, aluSrcMuxSel, LoadSizeMuxSel, busWe, StoreSizeMuxSel, RFWDSrcMuxSel, branch, jal, jalr} = signals;

    typedef enum {
        FETCH,
        DECODE,
        R_EXE,
        I_EXE,
        B_EXE,
        LU_EXE,
        AU_EXE,
        J_EXE,
        JL_EXE,
        S_EXE,
        S_MEM,
        L_EXE,
        L_MEM,
        L_WB
    } state_e;
    state_e state, next_state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) state <= FETCH;
        else state <= next_state;
    end

    always_comb begin  //상태 판단만
        next_state = state;
        case (state)
            FETCH:  next_state = DECODE;
            DECODE: begin
                case (opcode)
                    `OP_TYPE_R:  next_state = R_EXE;
                    `OP_TYPE_I:  next_state = I_EXE;
                    `OP_TYPE_B:  next_state = B_EXE;
                    `OP_TYPE_LU: next_state = LU_EXE;
                    `OP_TYPE_AU: next_state = AU_EXE;
                    `OP_TYPE_J:  next_state = J_EXE;
                    `OP_TYPE_JL: next_state = JL_EXE;
                    `OP_TYPE_S:  next_state = S_EXE;
                    `OP_TYPE_L:  next_state = L_EXE;
                endcase
            end
            R_EXE:  next_state = FETCH;
            I_EXE:  next_state = FETCH;
            B_EXE:  next_state = FETCH;
            LU_EXE: next_state = FETCH;
            AU_EXE: next_state = FETCH;
            J_EXE:  next_state = FETCH;
            JL_EXE: next_state = FETCH;
            S_EXE:  next_state = S_MEM;
            S_MEM:  next_state = FETCH;
            L_EXE:  next_state = L_MEM;
            L_MEM:  next_state = L_WB;
            L_WB:   next_state = FETCH;
        endcase
    end

    always_comb begin  //출력신호 제어
        // {PCEn, regFileWe, aluSrcMuxSel, Load_Size_Mux_sel, busWe, Store_Size_Mux_sel, RFWDSrcMuxSel, branch, jal, jalr} = signals
        signals = 15'b0;
        aluControl = `ADD;
        case (state)
            FETCH: signals = 15'b1_0_0_000_0_00_000_0_0_0;
            DECODE: signals = 15'b0_0_0_000_0_00_000_0_0_0;
            R_EXE: begin
                signals = 15'b0_1_0_000_0_00_000_0_0_0;
                aluControl = operator;
            end
            I_EXE: begin
                signals = 15'b0_1_1_000_0_00_000_0_0_0;
                if (operator == 4'b1101) aluControl = operator;
                else aluControl = {1'b0, operator[2:0]};
            end
            B_EXE: begin
                signals = 15'b0_0_0_000_0_00_000_1_0_0;
                aluControl = operator;
            end
            LU_EXE: signals = 15'b0_1_0_000_0_00_010_0_0_0;
            AU_EXE: signals = 15'b0_1_0_000_0_00_011_0_0_0;
            J_EXE: signals = 15'b0_1_0_000_0_00_100_0_1_0;
            JL_EXE: signals = 15'b0_1_0_000_0_00_100_0_1_1;
            S_EXE: signals = 15'b0_0_1_000_0_00_000_0_0_0;
            S_MEM: begin  // Store_Size_Mux_sel on
                case (operator[2:0])
                    3'b000:  signals = 15'b0_0_1_000_1_00_000_0_0_0;
                    3'b001:  signals = 15'b0_0_1_000_1_01_000_0_0_0;
                    3'b010:  signals = 15'b0_0_1_000_1_10_000_0_0_0;
                    default: signals = 15'b0_0_1_000_1_10_000_0_0_0;
                endcase
            end
            L_EXE:
            signals = 15'b0_0_1_000_0_00_001_0_0_0;  // 찾을 주소값 연산
            L_MEM: begin
                case (operator[2:0])
                    3'b000:
                    signals = 15'b0_0_1_000_0_00_001_0_0_0; // 찾은 주소의 메모리에서 데이터를 CPU에 입력
                    3'b001: signals = 15'b0_0_1_000_0_00_001_0_0_0;
                    3'b010: signals = 15'b0_0_1_000_0_00_001_0_0_0;
                    3'b100: signals = 15'b0_0_1_000_0_00_001_0_0_0;
                    3'b101: signals = 15'b0_0_1_000_0_00_001_0_0_0;
                    default: signals = 15'b0_0_1_000_0_00_001_0_0_0;
                endcase
            end
            L_WB: begin  // Load_Size_Mux_sel on
                case (operator[2:0])
                    3'b000:
                    signals = 15'b0_1_1_000_0_00_001_0_0_0; //write back에서 메모리에 load
                    3'b001: signals = 15'b0_1_1_001_0_00_001_0_0_0;
                    3'b010: signals = 15'b0_1_1_010_0_00_001_0_0_0;
                    3'b100: signals = 15'b0_1_1_100_0_00_001_0_0_0;
                    3'b101: signals = 15'b0_1_1_101_0_00_001_0_0_0;
                    default: signals = 15'b0_1_1_010_0_00_001_0_0_0;
                endcase
            end
        endcase
    end

endmodule
