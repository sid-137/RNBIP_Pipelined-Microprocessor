`timescale 1ns / 1ps

module topmodule(
    input clk
);

// Control Signals
wire RD,  WR;             //Data Memory
wire I_PC, L_PC;          //PC
wire D_SP, I_SP;          //SP    (and MUX7)
wire S_AL, L_R0, L_RN;    //Register Array
wire S11, S10;            //MUX1 - PC
wire S20;                 //MUX2 - DM (address selector)
wire S30, S40;            //MUX3, MUX4 - ALU inputs A, B
wire S50;                 //MUX5 - DM (input for write)
wire S82, S81, S80;       //MUX8 - Register Array

assign I_PC = 1'b1;

// reg - Buffers
reg [7:0] OR1, OR2;
reg [7:0] OC_R, OC_E;
reg [7:0] NPC;
reg [2:0] RS;
reg [3:0] AF;

// Hard-coded wires
wire [7:0] PM_OC;
wire [7:0] opcodeR, opcodeE, operand;
wire [7:0] dataOut;
wire [7:0] R0_out, RN_out;
wire [7:0] OR2_out, NPC_out;
wire [7:0] ALU_out;
wire [7:0] SP_out;
wire [7:0] PC_out;
wire [3:0] ALU_FR;
wire       ALU_FR_C, FL, flagCheck;

//For debugging
wire [7:0] R0, R1, R2, R3, R4, R5, R6, R7;

// Buffer Code
always @ (posedge clk) begin
    OR2 <= OR1;
    OR1 <= operand;
end

always @ (posedge clk) begin
    OC_E <= OC_R;
    OC_R <= PM_OC;
end
assign opcodeE = OC_E;
assign opcodeR = OC_R;

always @ (posedge clk) begin
    NPC = PC_out + 8'h01;
end

always @ (opcodeE) begin
    RS <= opcodeE[2:0];
    AF <= opcodeE[7:4];
end

assign OR2_out = OR2;
assign NPC_out = NPC;
// end Buffers

ProgramCounter myPC(
    .I_PC(I_PC),
    .L_PC(L_PC),
	.S11(S11), .S10(S10),
    .CLK(clk),
    .OR2_in(OR2),
	.R0_in(R0_out),
	.DM_in(dataOut),
    .PC_out(PC_out)
);

ProgramMemory myPM(
    .address(PC_out),
    .opcode(PM_OC),
    .operand(operand)
);

InstructionRegister myIR(
    .CLK(clk),
    .PM_in(PM_OC),
    .OC_out(opcodeR)
);

RegisterArray myRA(
	.R0_out(R0_out),
	.RN_out(RN_out),
	.ALU_in(ALU_out),
	.OR2_in(OR2_out),
	.DM_in(dataOut),
	.SP_in(SP_out),
	.RN_Reg_Sel(RS),
	.Control_in({L_RN,L_R0}),
	.S8({S82,S81,S80}),
	.clk(clk),
    //Used for debugging only
    .R0(R0),
	.R1(R1),
	.R2(R2),
	.R3(R3),
	.R4(R4),
	.R5(R5),
	.R6(R6),
	.R7(R7)
);

ALUbasic myALU(
    .Out(ALU_out),          // Output 8 bit
	.flagArray(ALU_FR),    // not holding only driving EDI
	.Cin(ALU_FR_C),          // Carry input bit
    .R0_in(R0_out),
	.RN_in(RN_out),
	.OR2_in(OR2_out),
    .S_AF(AF),         // Most significant 4 bits of the op code
	.S3(S30),
    .S4(S40)
);

FlagRegister myFR(
    .clk(clk),
    .OC_fl(opcodeR[2:0]),   //From IR
    .inArray(ALU_FR),       //From ALU
    .S_AL(S_AL),            //Control bit, meaningful operation
    .carry(ALU_FR_C),       //Output to ALU
    .FL(FL)                 //Output to Control Code Generator
);

StackPointer mySP(
    .I_SP(I_SP),
    .D_SP(D_SP),
    .clk(clk),
    .R0_in(R0_out),
    .SP_address(SP_out)
);

DataMemory myDM(
    .SP_in(SP_out),
    .R0_in(R0_out),
    .RN_in(RN_out),
    .NPC_in(NPC_out),
    .dataOut(dataOut),
    .RD(RD),
    .WR(WR),
    .S2(S20),
    .S5(S50),
    .clk(clk)
);

CCG1 myCTRLR(
    .opcode_in(opcodeR),
    .FL(FL),
    //.opcode_out(opcodeE),
    .flagCheck(flagCheck),
    .clk(clk)
);

CCG2 myCTRLE(
    .clk(clk),
    .opcode(opcodeE),
    .flagCheck(flagCheck),
    .RD(RD),  .WR(WR),                          //Data Memory
    .L_PC(L_PC),                                //PC
    .D_SP(D_SP), .I_SP(I_SP),                   //SP    (and MUX7)
    .S_AL(S_AL), .L_R0(L_R0), .L_RN(L_RN),      //Register Array
    .S11(S11), .S10(S10),                       //MUX1 - PC
    .S20(S20),                                  //MUX2 - DM (address selector)
    .S30(S30), .S40(S40),                       //MUX3, MUX4 - ALU inputs A, B
    .S50(S50),                                  //MUX5 - DM (input for write)
    .S82(S82), .S81(S81), .S80(S80)             //MUX8 - Register Array
);

endmodule // topmodule