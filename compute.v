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


module mux(select, s0, s1, out);
    parameter N = 1;
    input select;
    input [N-1:0] s0, s1;
    output reg [N-1:0] out;

    always @ * begin
        if (select == 1) out = s1;
        else out = s0;
    end

endmodule


module mux3(select, s0, s1, s2, out);
    parameter N = 1;
    input [1:0] select;
    input [N-1:0] s0, s1, s2;
    output reg [N-1:0] out;

    always @ * begin
        if (select == 2'b01) out = s1;
        else if (select == 2'b10) out = s2;
        else out = s0;
    end

endmodule


module adder(a, b, s);
    parameter N = 1;
    input [N-1:0] a, b;
    output reg [N-1:0] s;
    //assign s = a + b;

    always @ * begin
    	s = a + b;
    end
endmodule


module compare(a, b, s);
    parameter N = 1;
    input [N-1:0] a, b;
    output s;
    assign s = (a == b);
endmodule

module sl2(a, s);  // this module can only shift 32 bits left two bits
    input [31:0] a;
    output [31:0] s;
    assign s[31:2] = a[29:0];
    assign s[1:0]  = 2'b0;
endmodule

module sl26(a, s);  // this module can only shift 32 bits left two bits
    input [25:0] a;
    output [27:0] s;
    assign s[27:2] = a[25:0];
    assign s[1:0]  = 2'b0;
endmodule

module Branch(
    input [1:0] bch,
    input eq,
    output PCSrc);
    assign PCSrc = (bch[1] & (~bch[0]) & eq) | (bch[1] & bch[0] & (~eq));
endmodule

module Control(
    input [5:0] opcode,
    output jump,
    output [1:0] branch,
    output [7:0] idexControl
    );

    assign jump = opcode[1] & (~opcode[0]);
    assign branch[1] = (~opcode[3]) & opcode[2];
    assign branch[0] = opcode[0];
    assign idexControl[7] = (opcode==0) ||(opcode[5]!=opcode[3]);
    //~(opcode[5] & opcode[3]);
    assign idexControl[6] = opcode[5] & (~opcode[3]);
    assign idexControl[5] = opcode[5] & (~opcode[3]);
    assign idexControl[4] = opcode[5] & opcode[3];
    assign idexControl[3] = opcode[5] | opcode[3];
    assign idexControl[2] = ~(opcode[2] | opcode[0]);
    assign idexControl[1] = (~opcode[5]) & opcode[3];
    assign idexControl[0] = ~(|opcode[3:1]);
endmodule


module ALU(
    input [31:0] a, b,
    input [3:0] ALUctrl,
    output reg [31:0] s
    );

    always @ * begin
        case (ALUctrl)
            4'b0000: s = a & b;
            4'b0001: s = a | b;
            4'b0010: s = a + b;
            4'b0110: s = a - b;
            4'b0111: s = (a<b);
            4'b1100: s = ~(a|b);
            default: s = 4'b0;
        endcase
    end
    
endmodule

module SignExtension(
    input [15:0] Immin,
    output [31:0] Immout 
    );
    
    assign Immout[16] = Immin[15]; assign Immout[17] = Immin[15]; 
    assign Immout[18] = Immin[15]; assign Immout[19] = Immin[15]; 
    assign Immout[20] = Immin[15]; assign Immout[21] = Immin[15];
    assign Immout[22] = Immin[15]; assign Immout[23] = Immin[15]; 
    assign Immout[24] = Immin[15]; assign Immout[25] = Immin[15];
    assign Immout[26] = Immin[15]; assign Immout[27] = Immin[15];
    assign Immout[28] = Immin[15]; assign Immout[29] = Immin[15]; 
    assign Immout[30] = Immin[15]; assign Immout[31] = Immin[15];
    assign Immout[15:0] = Immin;
    
endmodule

module ALUControl(
    input [5:0] funct,
    input [1:0] ALUop,
    output [3:0] ALUctrl
    );

    assign ALUctrl[3] = 0;
    assign ALUctrl[2] = (ALUop == 2'b10) && (funct[1:0] == 2'b10);
    assign ALUctrl[1] = (ALUop[1]==ALUop[0])||((ALUop==2'b10)&&(funct[2]==0));
    assign ALUctrl[0] = (ALUop==2'b10)&&((funct[3]==1)||funct[0]==1);

endmodule


module ExForward(  // ignore lw-sw hazard
    input exmemRegWrite, memwbRegWrite,
    input [4:0] idexRs, idexRt, exmemRd, memwbRd,
    output reg [1:0] forwardA, forwardB
    );
    always @ * begin
        forwardA = 2'b0;
        forwardB = 2'b0;
        if ((exmemRegWrite==1) && (exmemRd!=0) && (exmemRd == idexRs))
            forwardA = 2'b10;  // EX hazard
        if ((exmemRegWrite==1) & (exmemRd!=0) && (exmemRd == idexRt))
            forwardB = 2'b10;  // EX hazard
        if ((memwbRegWrite==1) && (memwbRd!=0) && (memwbRd == idexRs) && 
        ~((exmemRegWrite) && (exmemRd!=0) && (exmemRd == idexRs)))
            forwardA = 2'b01;  // MEM hazard
        if ((memwbRegWrite==1) && (memwbRd!=0) && (memwbRd == idexRt) && 
        ~((exmemRegWrite) && (exmemRd!=0) && (exmemRd == idexRt)))
            forwardB = 2'b01;  // MEM hazard       
    end
    
endmodule



module ID_forward( 
    input ifBch, idexRegWrite, exmemRegWrite, idexMemRead, exmemMemRead,
    input [4:0] ifidRs, ifidRt, idexRd, exmemRd,
    output reg sA, sB
    ); // ifBch detect need of branch comparison, from ctrl branch[1]
    always @ * begin
        sA = 0; 
        sB = 0;
        if (ifBch) begin
        if ((exmemRegWrite) && (exmemRd!=0) && (!exmemMemRead) && (exmemRd==ifidRs))
            sA = 1; // exmem_ALUResult
        if ((exmemRegWrite) && (exmemRd!=0) && (!exmemMemRead) && (exmemRd==ifidRt))
            sB = 1; // exmem_ALUResult
        end     
    end
endmodule


module LoadUse(
    input ALUSrc, ifJ, ifBch, idexRegWrite, idexMemRead, exmemMemRead,
    input [4:0] ifidRs, ifidRt, idexRt, idexRd, exmemRd,
    output reg ifidWrite, PCWrite, ctrlSelect
    );
    
    initial begin
        ifidWrite = 1;
        PCWrite = 1;
        ctrlSelect = 1;
    end
    
    always @ * begin
        ifidWrite = 1;
        PCWrite = 1;
        ctrlSelect  = 1;

        if (!ifJ) begin   
            if ((idexMemRead)&& ((idexRt==ifidRt)||(idexRt==ifidRs)) ) begin
                ifidWrite = 0;
                PCWrite = 0;
                ctrlSelect = 0;  // common load-use hazard
            end
            if ((ifBch)&&(idexRegWrite)&&(idexRd!=0)) begin
                if (((ALUSrc==1) && ((idexRd==ifidRt)||(idexRd==ifidRs)))||
                ((ALUSrc==0)&& ((idexRt==ifidRt)||(idexRt==ifidRs)))) begin
                    ifidWrite = 0;
                    PCWrite = 0;
                    ctrlSelect = 0;  // stall for R-type or I-type + branch 
                end                 
            end
            if ((ifBch)&&(exmemMemRead)&&((exmemRd==ifidRt)||(exmemRd==ifidRs))) begin
                ifidWrite = 0;
                PCWrite = 0;
                ctrlSelect  = 0;  // second stall for lw + branch
            end
        end

    end

endmodule



