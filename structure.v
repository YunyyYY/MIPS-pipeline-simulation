`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/09 09:30:00
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

module InstMem(
    input [31:0] PC,
    output [31:0] inst
    );

    reg [31:0] memory[0:31]; //Registers is a 32 bits array
    assign inst = memory[PC[6:2]];
    
    initial begin
        memory[0] = 32'b00100000000010000000000000100000; //addi $t0, $zero, 0x20
        memory[1] = 32'b00100000000010010000000000110111; //addi $t1, $zero, 0x37
        memory[2] = 32'b00000001000010011000000000100100; //and $s0, $t0, $t1
        memory[3] = 32'b00000001000010011000000000100101; //or $s0, $t0, $t1
        memory[4] = 32'b10101100000100000000000000000100; //sw $s0, 4($zero)
        memory[5] = 32'b10101100000010000000000000001000; //sw $t0, 8($zero)
        memory[6] = 32'b00000001000010011000100000100000; //add $s1, $t0, $t1
        memory[7] = 32'b00000001000010011001000000100010; //sub $s2, $t0, $t1
        memory[8] = 32'b00010010001100100000000000001001; //beq $s1, $s2, error0
        memory[9] = 32'b10001100000100010000000000000100; //lw $s1, 4($zero)
        memory[10]= 32'b00110010001100100000000001001000; //andi $s2, $s1, 0x48
        memory[11] =32'b00010010001100100000000000001001; //beq $s1, $s2, error1
        memory[12] =32'b10001100000100110000000000001000; //lw $s3, 8($zero)
        memory[13] =32'b00010010000100110000000000001010; //beq $s0, $s3, error2
        memory[14] =32'b00000010010100011010000000101010; //slt $s4, $s2, $s1 (Last)
        memory[15] =32'b00010010100000000000000000001111; //beq $s4, $0, EXIT
        memory[16] =32'b00000010001000001001000000100000; //add $s2, $s1, $0
        memory[17] =32'b00001000000000000000000000001110; //j Last
        memory[18] =32'b00100000000010000000000000000000; //addi $t0, $0, 0(error0)
        memory[19] =32'b00100000000010010000000000000000; //addi $t1, $0, 0
        memory[20] =32'b00001000000000000000000000011111; //j EXIT
        memory[21] =32'b00100000000010000000000000000001; //addi $t0, $0, 1(error1)
        memory[22] =32'b00100000000010010000000000000001; //addi $t1, $0, 1
        memory[23] =32'b00001000000000000000000000011111; //j EXIT
        memory[24] =32'b00100000000010000000000000000010; //addi $t0, $0, 2(error2)
        memory[25] =32'b00100000000010010000000000000010; //addi $t1, $0, 2
        memory[26] =32'b00001000000000000000000000011111; //j EXIT
        memory[27] =32'b00100000000010000000000000000011; //addi $t0, $0, 3(error3)
        memory[28] =32'b00100000000010010000000000000011; //addi $t1, $0, 3
        memory[29] =32'b00001000000000000000000000011111; //j EXIT
        memory[30] =32'b0;
        memory[31] =32'b0;
    end

endmodule


module IF_ID(
    input clock, IF_IDwrite, IF_flush,
    input [31:0] PCin, instruction,
    output reg [31:0] PCout,
    output wire [25:0] raJump,
    output wire [3:0] PC4,
    output wire [5:0] ControlIn,
    output wire [4:0] IF_ID_Rs, IF_ID_Rt, IF_ID_Rd,
    output wire [15:0] Immi
    );

    reg [31:0] IF_ID_Reg, PC_Reg; //assign PCout = PC_Reg;
    assign raJump = IF_ID_Reg[25:0];
    assign PC4 = PCout[31:28];
    assign ControlIn = IF_ID_Reg[31:26];
    assign IF_ID_Rs = IF_ID_Reg[25:21];
    assign IF_ID_Rt = IF_ID_Reg[20:16];
    assign IF_ID_Rd = IF_ID_Reg[15:11];
    assign Immi = IF_ID_Reg[15:0];

    always @ (posedge clock) begin
        if (IF_IDwrite) begin
            PCout <= PCin;
            IF_ID_Reg <= instruction;
            if (IF_flush == 1) begin
                IF_ID_Reg <= 32'b0;
                PCout <= 32'b0;
            end/*
            else begin
                PCout <= PCin;
                IF_ID_Reg <= instruction;
            end*/
        end
    end

endmodule


module PCReg(
    input clock, rst, PCWrite,
    input [31:0] PCin,
    output wire [31:0] PCout
    );
    reg [31:0] newPC;
    assign PCout = newPC;

    always @(posedge rst) begin
        newPC = 32'b0;
    end
  
    always @(posedge clock) begin
        if (PCWrite) newPC = PCin;
    end
endmodule


module RegFile(
    input clock, RegWrite,
    input [31:0] WriteData, PCaddress, 
    input [4:0] ReadReg1, ReadReg2, WriteReg,
    output wire [31:0] ReadData1, ReadData2
    //output reg [31:0] Registers [0:31]
    );

    reg [31:0] Registers [0:31]; //Registers is a 32 bits array
    assign ReadData1 = Registers[ReadReg1];
    assign ReadData2 = Registers[ReadReg2];

    initial begin  // initialize registers to 0.
        Registers[0] = 32'b0; 
        Registers[1] = 32'b0; Registers[2] = 32'b0; Registers[3] = 32'b0;
        Registers[4] = 32'b0; Registers[5] = 32'b0; Registers[6] = 32'b0;
        Registers[7] = 32'b0; Registers[8] = 32'b0; Registers[9] = 32'b0;
        Registers[10] = 32'b0;
        Registers[11] = 32'b0; Registers[12] = 32'b0; Registers[13] = 32'b0;
        Registers[14] = 32'b0; Registers[15] = 32'b0; Registers[16] = 32'b0;
        Registers[17] = 32'b0; Registers[18] = 32'b0; Registers[19] = 32'b0;
        Registers[20] = 32'b0;
        Registers[21] = 32'b0; Registers[22] = 32'b0; Registers[23] = 32'b0;
        Registers[24] = 32'b0; Registers[25] = 32'b0; Registers[26] = 32'b0;
        Registers[27] = 32'b0; Registers[28] = 32'b0; Registers[29] = 32'b0;
        Registers[30] = 32'b0; Registers[31] = 32'b0;

    end
    
    always @ (posedge clock) begin
        Registers[31] <= PCaddress;
        if (RegWrite == 1)
            Registers[WriteReg] <= WriteData;
    end
    
endmodule


module ID_EX(
    input clock,
    input [7:0] IdEx_Control,
    input [31:0] ReadIn1, ReadIn2, SignIn,
    input [4:0] RsIn, RtIn, RdIn, 
    output reg [3:0] WB_MEM,
    output reg [1:0] ALUOp,
    output reg ID_EX_MemRead, RegDst, ALUSrc,
    output reg [31:0] ReadOut1, ReadOut2, SignOut,
    output reg [5:0] funct,  // to ALUControl
    output reg [4:0] ID_EX_Rs, ID_EX_Rt, ID_EX_Rd
    );

    always @ (posedge clock) begin
        WB_MEM <= IdEx_Control[7:4];
        ID_EX_MemRead <= IdEx_Control[5];
        RegDst <= IdEx_Control[3];
        ALUOp <= IdEx_Control[2:1];
        ALUSrc <= IdEx_Control[0];
        ReadOut1 <= ReadIn1;
        ReadOut2 <= ReadIn2;
        SignOut <= SignIn;
        funct <= SignIn[5:0];
        ID_EX_Rs <= RsIn;
        ID_EX_Rt <= RtIn;
        ID_EX_Rd <= RdIn; 
    end

endmodule


module EX_MEM(
    input clock,
    input [3:0] memwb,
    input [31:0] ALUResult, wDataIn, 
    input [4:0] RdIn,
    output reg [1:0] wb,
    output reg EX_MEM_RegWrite, MemRead, MemWrite,
    output reg [31:0] Address, wDataOut,
    output reg [4:0] EX_MEM_Rd
    );

    always @ (posedge clock) begin
        wb <= memwb[3:2];
        EX_MEM_RegWrite <= memwb[3];
        MemRead <= memwb[1];
        MemWrite <= memwb[0];
        Address <= ALUResult;
        wDataOut <= wDataIn;
        EX_MEM_Rd <= RdIn;
    end

endmodule


module DataMem(
    input clock, MemWrite, MemRead, 
    input [31:0] Address, WriteData,
    output [31:0] ReadData
    );

    reg [31:0] Registers [0:31]; //Registers is a 32 bits array
    reg [4:0] addr = 5'b11111;
    assign ReadData = Registers[addr];

    initial begin  // initialize registers to 0.
        Registers[0] = 32'b0; 
        Registers[1] = 32'b0; Registers[2] = 32'b10; Registers[3] = 32'b11;
        Registers[4] = 32'b0; Registers[5] = 32'b0; Registers[6] = 32'b0;
        Registers[7] = 32'b111; Registers[8] = 32'b0; Registers[9] = 32'b0;
        Registers[10] = 32'b0;
        Registers[11] = 32'b0; Registers[12] = 32'b0; Registers[13] = 32'b0;
        Registers[14] = 32'b0; Registers[15] = 32'b0; Registers[16] = 32'b0;
        Registers[17] = 32'b0; Registers[18] = 32'b0; Registers[19] = 32'b0;
        Registers[20] = 32'b0;
        Registers[21] = 32'b0; Registers[22] = 32'b0; Registers[23] = 32'b0;
        Registers[24] = 32'b0; Registers[25] = 32'b0; Registers[26] = 32'b0;
        Registers[27] = 32'b0; Registers[28] = 32'b0; Registers[29] = 32'b0;
        Registers[30] = 32'b0; Registers[31] = 32'bz;

    end
    
    always @ (posedge clock) begin
        if (MemWrite == 1)
            Registers[Address[6:2]] <= WriteData;
    end

    always @ (negedge clock) begin
        if (MemRead == 1)
            addr <= Address[6:2];
        else
            addr <= 5'b11111;
    end


endmodule

module MEM_WB(
    input clock,
    input [1:0] wb,
    input [31:0] ReadData, ALUResult,
    input [4:0] RdIn,
    output reg MEM_WB_RegWrite, MemtoReg,
    output reg [31:0] ReadOut, ALUOut,
    output reg [4:0] MEM_WB_Rd
    );

    always @ (posedge clock) begin
        MEM_WB_RegWrite <= wb[1];
        MemtoReg <= wb[0];
        ReadOut <= ReadData;
        ALUOut <= ALUResult; 
        MEM_WB_Rd <= RdIn;
    end

endmodule








