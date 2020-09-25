`timescale 1ns / 1ps

module CCG1(
    input   [7:0]   opcode_in,
    input           FL,
    output          flagCheck,
    output          branch_neg,
    input           clk
);

reg FL_reg, Branch, BR_reg;

initial begin
    FL_reg = 1'b0;
    Branch = 1'b1;
    BR_reg = 1'b1;
end

always @ (posedge clk)
begin
    FL_reg <= FL;
    BR_reg <= Branch;
end

always @ (negedge clk)
begin
    casex (opcode_in)
    8'b0000_0_011 : Branch = 1'b0;  //JUD_od
    8'b0000_0_100 : Branch = 1'b0;  //JUA
    8'b0000_0_101 : Branch = 1'b0;  //CUD_od
    8'b0000_0_110 : Branch = 1'b0;  //CUA
    8'b0000_0_111 : Branch = 1'b0;  //RTU
    8'b0000_1_xxx : begin           //JCD_fl_od
        if (FL) begin
            Branch = 1'b0;
        end else begin
            Branch = 1'b1;
        end
    end
    8'b0010_1_xxx : begin           //JCA_fl
        if (FL) begin
            Branch = 1'b0;
        end else begin
            Branch = 1'b1;
        end
    end
    8'b0011_0_xxx : begin           //CCD_fl_od
        if (FL) begin
            Branch = 1'b0;
        end else begin
            Branch = 1'b1;
        end
    end
    8'b0011_1_xxx : begin           //CCA_fl
        if (FL) begin
            Branch = 1'b0;
        end else begin
            Branch = 1'b1;
        end
    end
    8'b0100_1_xxx : begin           //RTC_fl
        if (FL) begin
            Branch = 1'b0;
        end else begin
            Branch = 1'b1;
        end
    end
    default: Branch = 1'b1;
    endcase
end

assign flagCheck = FL_reg;
assign branch_neg = BR_reg;

endmodule // CCG1


module CCG2(
    input   [7:0]   opcode,
    input           flagCheck,
    input           branch_neg,
    output RD,  WR,             //Data Memory
    output L_PC,                //PC
    output D_SP, I_SP,          //SP    (and MUX7)
    output S_AL, L_R0, L_RN,    //Register Array
    output S11, S10,            //MUX1 - PC
    output S20,                 //MUX2 - DM (address selector)
    output S30, S40,            //MUX3, MUX4 - ALU inputs A, B
    output S50,                 //MUX5 - DM (input for write)
    output S82, S81, S80,       //MUX8 - Register Array
    input clk
);


reg [7:0] controlBits;
reg [8:0] muxBits;

wire [7:0] OC_FSM;
wire flush;
reg FH1, FH2;
always @ (posedge clk) begin
    FH2 <= FH1;
    FH1 <= (branch_neg & flush) | (~flush);
end

assign flush = FH1 & FH2;
assign OC_FSM = opcode & {8{flush}};

assign {RD, WR, L_R0, L_RN, S_AL, I_SP, D_SP, L_PC} = controlBits;
assign {S11, S10, S20, S30, S40, S50, S82, S81, S80} = muxBits;

initial begin
    controlBits = 8'h00;
    muxBits = 9'b000000000;
    FH1 = 1'b1;
    FH2 = 1'b1;
end

always @ (negedge clk)
begin
    casex (OC_FSM)
    8'b0000_0_000 : begin           //NOP
        controlBits <= 8'b00000000;
        muxBits <= 9'b00_0000_000;
    end
    8'b0000_0_001 : begin           //CLR
        controlBits <= 8'b00111000;
        muxBits <= 9'b00_0000_001;
    end
    8'b0000_0_010 : begin           //CLC
        controlBits <= 8'b00001000;
        muxBits <= 9'b00_0000_000;
    end
    8'b0000_0_011 : begin           //JUD_od
        controlBits <= 8'b00000001;
        muxBits <= 9'b01_0000_000;
    end
    8'b0000_0_100 : begin           //JUA
        controlBits <= 8'b00000001;
        muxBits <= 9'b11_0000_000;
    end
    8'b0000_0_101 : begin           //CUD_od
        controlBits <= 8'b01000011;
        muxBits <= 9'b01_1000_000;
    end
    8'b0000_0_110 : begin           //CUA
        controlBits <= 8'b01000011;
        muxBits <= 9'b11_1000_000;
    end
    8'b0000_0_111 : begin           //RTU
        controlBits <= 8'b10000101;
        muxBits <= 9'b10_1000_000;
    end
    8'b0000_1_xxx : begin           //JCD_fl_od
        if (flagCheck) begin
            controlBits <= 8'b00000001;
            muxBits <= 9'b01_0000_000;
        end else begin
            controlBits <= 8'b00000000;
            muxBits <= 9'b00_0000_000;
        end
    end
    8'b0001_0_000 : begin           //LSP
        controlBits <= 8'b00000110;
        muxBits <= 9'b00_0000_000;
    end
    8'b0001_0_xxx : begin           //MVD_rn*
        controlBits <= 8'b00010000;
        muxBits <= 9'b00_0000_101;
    end
    8'b0001_1_000 : begin           //RSP
        controlBits <= 8'b00100000;
        muxBits <= 9'b00_0000_011;
    end
    8'b0001_1_xxx : begin           //MVS_rn*
        controlBits <= 8'b00100000;
        muxBits <= 9'b00_0000_110;
    end
    8'b0010_0_xxx : begin           //NOT_rn
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0100_001;
    end
    8'b0010_1_xxx : begin           //JCA_fl
        if (flagCheck) begin
            controlBits <= 8'b00000001;
            muxBits <= 9'b11_0000_000;
        end else begin
            controlBits <= 8'b00000000;
            muxBits <= 9'b00_0000_000;
        end
    end
    8'b0011_0_xxx : begin           //CCD_fl_od
        if (flagCheck) begin
            controlBits <= 8'b01000011;
            muxBits <= 9'b01_1000_000;
        end else begin
            controlBits <= 8'b00000000;
            muxBits <= 9'b00_0000_000;
        end
    end
    8'b0011_1_xxx : begin           //CCA_fl
        if (flagCheck) begin
            controlBits <= 8'b01000011;
            muxBits <= 9'b11_1000_000;
        end else begin
            controlBits <= 8'b00000000;
            muxBits <= 9'b00_0000_000;
        end
    end
    8'b0100_0_xxx : begin           //INC_rn
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0100_001;
    end
    8'b0100_1_xxx : begin           //RTC_fl
        if (flagCheck) begin
            controlBits <= 8'b10000101;
            muxBits <= 9'b10_1000_000;
        end else begin
            controlBits <= 8'b00000000;
            muxBits <= 9'b00_0000_000;
        end
    end
    8'b0101_0_xxx : begin           //DCR_rn
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0100_001;
    end
    8'b0101_1_xxx : begin           //MVI_rn_od
        controlBits <= 8'b00010000;
        muxBits <= 9'b00_0000_010;
    end
    8'b0110_0_000 : begin           //RLA
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0000_001;
    end
    8'b0110_0_xxx : begin           //STA_rn*
        controlBits <= 8'b01010000;
        muxBits <= 9'b00_0001_000;
    end
    8'b0110_1_xxx : begin           //PSH_rn
        controlBits <= 8'b01000010;
        muxBits <= 9'b00_1001_000;
    end
    8'b0111_0_000 : begin           //RRA
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0000_001;
    end
    8'b0111_0_xxx : begin           //LDA_rn*
        controlBits <= 8'b10010000;
        muxBits <= 9'b00_0000_100;
    end
    8'b0111_1_xxx : begin           //POP_rn
        controlBits <= 8'b10010100;
        muxBits <= 9'b00_1000_100;
    end
    8'b1000_0_xxx : begin           //ADA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1000_1_xxx : begin           //ADI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    8'b1001_0_xxx : begin           //SBA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1001_1_xxx : begin           //SBI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    8'b1010_0_xxx : begin           //ACA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1010_1_xxx : begin           //ACI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    8'b1011_0_xxx : begin           //SCA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1011_1_xxx : begin           //SCI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    8'b1100_0_xxx : begin           //ANA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1100_1_xxx : begin           //ANI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    8'b1101_0_xxx : begin           //ORA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1101_1_xxx : begin           //ORI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    8'b1110_0_xxx : begin           //XRA_rn
        controlBits <= 8'b00101000;
        muxBits <= 9'b00_0000_001;
    end
    8'b1110_1_xxx : begin           //XRI_rn_od
        controlBits <= 8'b00011000;
        muxBits <= 9'b00_0110_000;
    end
    //8'b1111_0_xxx :               //INA_pn
    //8'b1111_1_xxx :               //OUT_pn
    endcase
end

endmodule // CCG2
