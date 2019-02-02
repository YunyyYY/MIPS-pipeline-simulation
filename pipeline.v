`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/16 21:35:00
// Design Name: 
// Module Name: Structure
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "structure.v"
`include "compute.v"

module pipeline(
	input clock, reset,
	output [31:0] PCins

	//output wire [31:0] RegInfo [0:31]
	);

	wire [31:0] pcplus, pcbrch, jumpin, pc1_out, pc2_out, inst,
				PCout, rd1, rd2, Immo, Immox4, 
				data1, data2, ReadOut1, ReadOut2, SignOut,
				wbData, memData, alu1, alu2, alu3, aluRst, memAddr,
				ReadData, wbReadData, wbALU;
				
	wire [25:0] raJump;
	wire [15:0] Immi;
	wire [7:0] idctrl, idexctrl;
	wire [5:0] ControlIn, funct;
	wire [4:0] ifid_Rs, ifid_Rt, ifid_Rd, idex_Rs, idex_Rt, idex_Rd,
				meminRd, exmem_Rd, memwb_Rd;
	wire [3:0] PC4, wbmemCtrl, ALUctrl;
	wire [1:0] branch, ALUOp, fwd1, fwd2, wbCtrl;
	wire PCSrc, ifFlush, PCWrite, ifidWrite, idsa, idsb, sctrl, jump, 
		ifeq, idexMemRead, RegDst, ALUSrc, exmemRegWrite, 
		exmemMemRead, memWrite, memwbRegWrite, MemtoReg;

	

	assign ifFlush = (PCSrc | jump);

// ---------------- IF parts ------------------
	mux #(32) pc1(PCSrc, pcplus, pcbrch, pc1_out);
	mux #(32) pc2(jump, pc1_out, jumpin, pc2_out);
	PCReg PC(clock, reset, PCWrite, pc2_out, PCins);
	adder  #(32) pcAdd(PCins, 32'b100, pcplus);
	InstMem instruction(PCins, inst);

	IF_ID ifid(clock, ifidWrite, ifFlush, pcplus, inst, 
				PCout, raJump, PC4, ControlIn, ifid_Rs, ifid_Rt, ifid_Rd, Immi);
	sl26 sljump(raJump, jumpin[27:0]);
	assign jumpin[31:28] = PC4;

// ------------------ ID parts -------------------
	
	RegFile regs(clock, memwbRegWrite, wbData, PCout, ifid_Rs, ifid_Rt, memwb_Rd,
			rd1, rd2);
	SignExtension signex(Immi, Immo);
	sl2 slbch(Immo, Immox4);
	adder  #(32) bchAdd(Immox4, PCout, pcbrch);

	mux #(32) ida(idsa, rd1, memAddr, data1);
	mux #(32) idb(idsb, rd2, memAddr, data2);
	compare #(32) bcheq(data1, data2, ifeq);
	Control ctrl(ControlIn, jump, branch, idctrl);
	mux #(8) ctrlMux(sctrl, 8'b0, idctrl, idexctrl);
	Branch beqbne(branch, ifeq, PCSrc);

// ----------------- EX parts -----------------------

	ID_EX idex(clock, idexctrl, data1, data2, Immo, ifid_Rs, ifid_Rt, ifid_Rd,
			wbmemCtrl, ALUOp, idexMemRead, RegDst, ALUSrc, ReadOut1, ReadOut2,
			SignOut, funct, idex_Rs, idex_Rt, idex_Rd);

	mux #(5) regMux(RegDst, idex_Rd, idex_Rt, meminRd);
	mux3 #(32) ALUmuxa(fwd1, ReadOut1, wbData, memAddr, alu1);
	mux3 #(32) ALUmuxb(fwd2, ReadOut2, wbData, memAddr, alu2);
	mux #(32) ALUmuxc(ALUSrc, SignOut, alu2, alu3);
	ALUControl ctrlALU(funct, ALUOp, ALUctrl);
	ALU exALU(alu1, alu3, ALUctrl, aluRst);

// ---------------- MEM parts ------------------------
	
	EX_MEM exmem(clock, wbmemCtrl, aluRst, alu2, meminRd, wbCtrl, 
		exmemRegWrite, exmemMemRead, memWrite, memAddr, memData, exmem_Rd);
	DataMem datas(clock, memWrite, exmemMemRead, memAddr, memData, ReadData);

// ---------------- WB parts ------------------------

	MEM_WB memwb(clock, wbCtrl, ReadData, memAddr, exmem_Rd, 
		memwbRegWrite, MemtoReg, wbReadData, wbALU, memwb_Rd);
	mux #(32) wbMux(MemtoReg, wbALU, wbReadData, wbData);
    

// ---------------- hazard and forward -----------------

	wire ifBch, idexRegWrite;
	assign ifBch = branch[1];
	assign idexRegWrite = wbmemCtrl[3];
	ExForward exfwd(exmemRegWrite, memwbRegWrite, idex_Rs, idex_Rt, 
		exmem_Rd, memwb_Rd, fwd1, fwd2);
	ID_forward idfwd(ifBch, idexRegWrite, exmemRegWrite, idexMemRead, 
		exmemMemRead, ifid_Rs, ifid_Rt, idex_Rd, exmem_Rd, idsa, idsb);
	LoadUse lduse(ALUSrc, jump, ifBch, idexRegWrite, idexMemRead, exmemMemRead,
		ifid_Rs, ifid_Rt, idex_Rt, idex_Rd, exmem_Rd, 
		ifidWrite, PCWrite, sctrl);

endmodule








