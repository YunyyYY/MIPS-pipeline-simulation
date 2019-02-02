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

/*
module simu_inst;

  reg [4:0] PC;
  wire [31:0] inst;

  InstMem mem(PC, inst);

  initial begin
    $dumpfile("simu_inst.vcd");
    $dumpvars(0, simu_inst);
    #0  PC = 5'b00011;
    #30 PC = 5'b00010;
    #30 PC = 5'b10101;
    #30 PC = 5'b11101;
    end

    initial #150 $finish;

endmodule
*/


module simu_IF_ID;

  parameter half_period = 15;

  reg clock = 1, IF_IDwrite = 1, IF_flush = 0;
  reg [31:0] PCin, instruction;
  wire [31:0] PCout;
  wire [25:0] raJump;
  wire [3:0] PC4;
  wire[15:0] Immi;
  wire [5:0] ControlIn;
  wire [4:0] ReadRegister1, ReadRegister2, Rs, Rt, Rd;

  IF_ID test_ifid(clock, IF_IDwrite, IF_flush, PCin, instruction, PCout, 
          raJump, PC4, ControlIn, Rs, Rt, Rd, Immi); 
  
  initial begin
  $dumpfile("simu_IF_ID.vcd");
  $dumpvars(0, simu_IF_ID);
    #0  PCin = 32'b0100;
        instruction = 32'b10001110010100010000000000000000;  // lw $s1, 0($s2)
    #30 PCin = 32'b1000; //IF_IDwrite = 0;
        instruction = 32'b00000010001100101000000000100000;  // add $s0, $s1, $s2
    #30 PCin = 32'b1100; //IF_flush = 1; IF_IDwrite = 1;
        instruction = 32'b00100000000010010000000000010100;  // addi $t1, $0, 20
    #30 PCin = 32'b10000; //IF_flush = 0;
        instruction = 32'b00100111000010010000000000010100;  // addi $t1, $0, 20
  end
  
  always #half_period clock = ~clock;
  initial #150 $finish;
endmodule



/*
module simu_RegFile;
  parameter half_period = 15;
  wire [31:0]oA,oB;
  reg wt = 0, clock = 1;
  reg [4:0] rA, rB, wR;
  reg [31:0] wd = 32'b0;
  RegFile testReg(clock, wt, wd, rA, rB, wR, oA, oB);
   
  initial begin
  $dumpfile("simu_RegFile.vcd");
  $dumpvars(0, simu_RegFile);
    #0 wd = 32'b00000000000000000000000000000000;wR = 5'b00001;
    #30 wd = 32'b00000000000000000000000000000010;wR = 5'b00011;wt = 1;
    #30 wd = 32'b00000000000000000000000000000011;wR = 5'b11111;
    #30 wt=0;
    #30 wR = 5'b00001;rA = 5'b00000;rB = 5'b11111;
    #30 wt = 1;
    #30 wd = 32'b11111111111111111111111111111111;wR = 5'b00100; wt = 0;
    #30 wt = 1; 
    #30 rA = 5'b00100;rB = 5'b00011; wt=0;
  end

  always #half_period clock = ~clock;
  initial #250 $finish;
endmodule
*/


/*

module simu_ID_EX;

    parameter half_period = 15;
    reg clock = 1;
    reg [7:0] IdEx;
    reg [31:0] ReadIn1, ReadIn2, SignIn;
    reg [4:0] RsIn, RtIn, RdIn;
    wire [3:0] WB_MEM;
    wire [1:0] ALUOp;
    wire ID_EX_MemRead, RegDst, ALUSrc;
    wire [31:0] ReadOut1, ReadOut2, SignOut;
    wire [5:0] ALUControl;
    wire [4:0] RsOut, RtOut, RdOut;

    ID_EX idex(clock, IdEx, ReadIn1, ReadIn2, SignIn, RsIn, RtIn, RdIn, WB_MEM, 
            ALUOp, ID_EX_MemRead, RegDst, ALUSrc, ReadOut1, ReadOut2, 
            SignOut, ALUControl, RsOut, RtOut, RdOut);
  
   initial begin
    $dumpfile("simu_ID_EX.vcd");
    $dumpvars(0, simu_ID_EX);
    #0  IdEx = 8'b10000101;  //add $s2, $s1, $s0
        ReadIn1 = 32'b0011;
        ReadIn2 = 32'b0001;
        SignIn = 16'b1001000000100000;
        RsIn = 5'b10001;
        RtIn = 5'b10000;
        RdIn = 5'b10010;
    #30 IdEx = 8'b10000101;  //add $s2, $s1, $s0
        ReadIn1 = 32'b0001;
        ReadIn2 = 32'b0001;
        SignIn = 16'b1001000000100010;
        RsIn = 5'b00001;
        RtIn = 5'b00000;
        RdIn = 5'b00010;
    #30 IdEx = 8'b10000101;  //add $s2, $s1, $s0
        ReadIn1 = 32'b1011;
        ReadIn2 = 32'b1001;
        SignIn = 16'b1001000000100100;
        RsIn = 5'b10001;
        RtIn = 5'b01000;
        RdIn = 5'b01010;
    end
  
    always #half_period clock = ~clock;
    initial #100 $finish;
endmodule
*/

/*
module simu_exmem;

  parameter half_period = 15;
  reg clock = 1;
  reg [3:0] memwb;
  reg [31:0] ALUResult, wDataIn;
  reg [4:0] RdIn;
  wire [1:0] wb;
  wire EX_MEM_RegWrite, MemRead, MemWrite;
  wire [31:0] Address, wDataOut;
  wire [4:0] EX_MEM_Rd;

  EX_MEM exm(clock, memwb, ALUResult, wDataIn, RdIn, wb, EX_MEM_RegWrite, 
    MemRead, MemWrite, Address, wDataOut, EX_MEM_Rd);

  initial begin
    $dumpfile("simu_EX_MEM.vcd");
    $dumpvars(0, simu_exmem);
    #0  memwb = 4'b0011;
        ALUResult = 32'b0001;
        RdIn = 5'b10010;
    #30 memwb = 4'b0001;
        ALUResult = 32'b0001;
        wDataIn = 32'b1001;
        RdIn = 5'b00010;
    #30 memwb = 4'b0101;
        wDataIn = 32'b1011;
        RdIn = 5'b01010;
    end

    always #half_period clock = ~clock;
    initial #100 $finish;

endmodule
*/

/*
module simu_dtmem;

  parameter half_period = 15;
  reg clock=1, MemWrite=0, MemRead=0;
  reg [31:0] Address, WriteData;
  wire [31:0] ReadData;

  DataMem mem(clock, MemWrite, MemRead, Address, WriteData, ReadData);

  initial begin
    $dumpfile("simu_dtmem.vcd");
    $dumpvars(0, simu_dtmem);
    #0  MemWrite=1; MemRead=0; Address = 32'b10; WriteData = 32'b101;
    #30 MemWrite=0; MemRead=1; Address = 32'b0111;
    #30 MemWrite=1; MemRead=1; Address = 32'b1000; WriteData = 32'b1001;
    #30 MemWrite=0; MemRead=0;
    #30 MemWrite=0; MemRead=1;  Address =32'b11;

    end

    always #half_period clock = ~clock;
    initial #150 $finish;

endmodule
*/

/*
module simu_mwb;

  parameter half_period = 15;
  reg clock = 1;
  reg [1:0] wb;
  reg [31:0] ReadData, ALUResult;
  reg [4:0] RdIn;
  wire MEM_WB_RegWrite, MemtoReg;
  wire [31:0] ReadOut, ALUOut;
  wire [4:0] MEM_WB_Rd;

  MEM_WB mwb(clock, wb, ReadData, ALUResult, RdIn,
    MEM_WB_RegWrite, MemtoReg, ReadOut, ALUOut, MEM_WB_Rd);

  initial begin
    $dumpfile("simu_MEM_WB.vcd");
    $dumpvars(0, simu_mwb);
    #0  wb = 4'b0011;
        ALUResult = 32'b0001;
        RdIn = 5'b10010;
    #30 wb = 4'b0001;
        ALUResult = 32'b0001;
        ReadData = 32'b1001;
        RdIn = 5'b00010;
    #30 wb = 4'b0101;
        ReadData = 32'b1011;
        RdIn = 5'b01010;
    end

    always #half_period clock = ~clock;
    initial #100 $finish;

endmodule
*/

