`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/13 23:55:30
// Design Name: 
// Module Name: simu
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


module simu;

  parameter half_period = 25;
  // parameter n = 32;

  // IF_ID
  reg clock = 1, IF_IDwrite = 1, IF_flush = 0;  // input
  reg [31:0] PCin, instruction;  // input

  wire [31:0] PCout; // to adder
  wire [25:0] raJump;
  wire [3:0] PC4;
  wire [5:0] ControlIn; // to control
  wire [4:0] IF_ID_Rs, IF_ID_Rt, IF_ID_Rd;  // to RegFile and ID/EX
  wire [15:0] Immi; // to ID/EX

  // RegFile
  // clock is the same
  reg RegWrite = 1; // from stage WB, **** TEMP reg here ****
  reg [31:0] WriteData = 32'b11110000; // from stage WB, **** TEMP reg here ****
  reg [4:0] WriteReg = 5'b10000; // from stage WB, **** TEMP reg here ****

  wire [31:0] ReadData1, ReadData2; // to ID/EX

  // ID/EX
  // clock is the same
  reg [7:0] IdEx = 8'b00001100; // from Control, **** TEMP reg here ****
  reg [31:0] ID_EX_SignIn = 32'b100000;
  //wire [4:0] RsIn, RtIn, RdIn;

  wire [3:0] WB_MEM;
  wire [1:0] ALUOp;
  wire ID_EX_MemRead, RegDst, ALUSrc;
  wire [31:0] ID_EX_ReadOut1, ID_EX_ReadOut2, ID_EX_SignOut;
  wire [5:0] ALUControl;
  wire [4:0] ID_EX_Rs, ID_EX_Rt, ID_EX_Rd;

  IF_ID ifid(clock, IF_IDwrite, IF_flush, PCin, instruction, 
    PCout, raJump, PC4, ControlIn, IF_ID_Rs, IF_ID_Rt, IF_ID_Rd, Immi);

  RegFile register(clock, RegWrite, WriteData, IF_ID_Rs, IF_ID_Rt, WriteReg,
    ReadData1, ReadData2);

  ID_EX idex(clock, IdEx, ReadData1, ReadData2, ID_EX_SignIn, 
    IF_ID_Rs, IF_ID_Rt, IF_ID_Rd,
    WB_MEM, ALUOp, ID_EX_MemRead, RegDst, ALUSrc, ID_EX_ReadOut1, 
    ID_EX_ReadOut2, ID_EX_SignOut, ALUControl, ID_EX_Rs, ID_EX_Rt, ID_EX_Rd);

  //mux #(n) test_mux(out, PCSrc, s0, s1);
  
  initial begin
  $dumpfile("simu.vcd");
  $dumpvars(0, simu);
    #0  PCin = 32'b0; //s0 = 1; s1 = 0;
        instruction = 32'b00100000000010000000000000100000;
    #50 PCin = 32'b0100; 
        instruction = 32'b00100000000010010000000000100111;
    #50 PCin = 32'b1000; 
        instruction = 32'b00000001000010011000000000100100;
    #50 PCin = 32'b1100; 
        instruction = 32'b00000001000010011000000000100101;
    #50 PCin = 1; 
        instruction = 32'b10101100000100000000000000000100;
  end
  
  always #half_period clock = ~clock;
  initial #250 $finish;
endmodule
