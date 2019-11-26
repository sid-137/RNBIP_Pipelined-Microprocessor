`timescale 1ns / 1ps

module RegisterArray(
	output	[7:0]	R0_out,
	output	[7:0]	RN_out,
	input	[7:0]	ALU_in,
	input	[7:0]	OR2_in,
	input	[7:0]	DM_in,
	input	[7:0]	SP_in,
	input	[2:0]	RN_Reg_Sel,
	input	[1:0]	Control_in,	// LR0, LRN
	input	[2:0]	S8,
	input			clk,
	// Use following for debugging
	output	[7:0]	R0,
	output	[7:0]	R1,
	output	[7:0]	R2,
	output	[7:0]	R3,
	output	[7:0]	R4,
	output	[7:0]	R5,
	output	[7:0]	R6,
	output	[7:0]	R7
	);

reg	[7:0] Reg_Array [7:0];
wire [7:0] RA_in;
wire L_R0, L_RN;

	initial
	begin
		Reg_Array[0] = 0;
		Reg_Array[1] = 1;
		Reg_Array[2] = 2;
		Reg_Array[3] = 3;
		Reg_Array[4] = 4;
		Reg_Array[5] = 5;
		Reg_Array[6] = 6;
		Reg_Array[7] = 7;
	end

assign L_RN = Control_in[1];
assign L_R0 = Control_in[0];

assign R0_out = Reg_Array[0];
assign RN_out = Reg_Array[RN_Reg_Sel];

// ---- MUX 8 ----
parameter [2:0] Reg_ALU = 3'b001;
parameter [2:0] Reg_OD = 3'b010;
parameter [2:0] Reg_DM = 3'b100;
parameter [2:0] Reg_RN = 3'b110;
parameter [2:0] Reg_R0 = 3'b101;
parameter [2:0] Reg_SP = 3'b011;

assign RA_in =	(S8 == Reg_SP)	?	SP_in	: (
				(S8 == Reg_DM)	?	DM_in	: (
				(S8 == Reg_OD)	?	OR2_in	: (
				(S8 == Reg_R0)	?	R0_out	: (
				(S8 == Reg_RN)	?	RN_out	: (
				(S8 == Reg_ALU)	?	ALU_in	: 8'h00 )))));
// end MUX8

always @ (posedge clk)
begin
    if(L_R0 & L_RN) begin
       Reg_Array[0] <= RA_in;
       Reg_Array[1] <= RA_in;
       Reg_Array[2] <= RA_in;
       Reg_Array[3] <= RA_in;
       Reg_Array[4] <= RA_in;
       Reg_Array[5] <= RA_in;
       Reg_Array[6] <= RA_in;
       Reg_Array[7] <= RA_in;
    end
	
   	else if (L_R0)
	begin
		Reg_Array[0] = RA_in;
	end

	else if (L_RN)
	begin
		Reg_Array[RN_Reg_Sel] = RA_in;
	end
end

//Debug Register Array
assign R0 = Reg_Array[0];
assign R1 = Reg_Array[1];
assign R2 = Reg_Array[2];
assign R3 = Reg_Array[3];
assign R4 = Reg_Array[4];
assign R5 = Reg_Array[5];
assign R6 = Reg_Array[6];
assign R7 = Reg_Array[7];

endmodule