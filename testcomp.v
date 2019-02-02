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

`include "compute.v"

/*
module simu_add;

  parameter n = 32;
  reg [n-1:0] a, b;
  wire [n-1:0] s;

  adder #(n) test_mux(a, b, s);
  
  initial begin
  $dumpfile("simu_add.vcd");
  $dumpvars(0, simu_add);
    #0  a = 32'hffffffff;
        b = 32'hffffffff;
    #30 a = 32'b1;
        b = 32'b0;
    #30 a = 32'h0000ffff;
        b = 32'h1;
  end
  
  initial #100 $finish;
endmodule
*/

/*
module simu_cmp;

  parameter n = 32;
  reg [n-1:0] a, b;
  wire s;

  compare #(n) test_cmp(a, b, s);
  
  initial begin
  $dumpfile("simu_cmp.vcd");
  $dumpvars(0, simu_cmp);
    #0  a = 32'hffffffff;
        b = 32'hffffffff;
    #30 a = 32'b1;
        b = 32'b0;
    #30 a = 32'h0000ffff;
        b = 32'hffff0000;
  end
  
  initial #100 $finish;
endmodule
*/

/*
module simu_sh2;

  reg [31:0] a;
  wire [31:0] s;

  sl2 #(n) test_sh2(a, s);
  
  initial begin
  $dumpfile("simu_sh2.vcd");
  $dumpvars(0, simu_sh2);
    #0  a = 32'hffffffff;
    #30 a = 32'b1;
    #30 a = 32'h0000ffff;
  end
  
  initial #100 $finish;
endmodule
*/

/*
module simu_bch;
    reg [1:0] bch;
    reg eq;
    wire PCSrc;
    Branch test_bch(bch, eq,PCSrc);
    initial begin
      $dumpfile("simu_bch.vcd");
      $dumpvars(0, simu_bch);
      #0 bch = 2'b10; //s0 = 1; s1 = 0;
          eq= 1;
      #20 bch = 2'b11; 
          eq = 1;
      #20 bch = 2'b10; 
          eq = 0;
      #20 bch = 2'b11;
          eq = 0;
    end
  
  initial #100 $finish;
endmodule
*/


/*
module simu_bslct;
    parameter half_period = 10;
    reg ifBch = 1, idexRegWrite, exmemRegWrite, idexMemRead, exmemMemRead;
    reg [4:0] ifidRs, ifidRt, idexRd, exmemRd;
    wire [1:0] sA, sB;
    //wire nop;

    ID_forward testslct(ifBch, idexRegWrite, exmemRegWrite, 
      idexMemRead, exmemMemRead, ifidRs, ifidRt, idexRd, exmemRd, sA, sB);

    initial begin
      $dumpfile("simu_bslct.vcd");
      $dumpvars(0, simu_bslct);
      #0  idexRegWrite = 1;
          ifidRs = 5'b10000;
          idexRd = 5'b10000;
          idexMemRead = 1;
      #20 idexRegWrite = 0;
          exmemRegWrite = 1;
          ifidRs = 5'b10000;
          idexRd = 5'b00000;
          exmemRd = 5'b10000;
      #20 ifBch = 0;
          idexRegWrite = 0;
          exmemRegWrite = 0;
          ifidRs = 5'b10000;
          idexRd = 5'b10000;
          exmemRd = 5'b00000;
      #20 ifBch = 1;
          idexRegWrite = 0;
          exmemRegWrite = 0;
          ifidRs = 5'b10000;
          idexRd = 5'b10000;
          exmemRd = 5'b00000;
    end
  initial #100 $finish;
endmodule
*/

/*
module simu_alu;
  reg [31:0] a=32'b0, b=32'b0;
  reg [3:0] ALUctrl=4'b0000;
  wire [31:0] s;

  ALU alu(a, b,  ALUctrl, s);

  initial begin
  $dumpfile("simu_alu.vcd");
  $dumpvars(0, simu_alu);
    #0  ALUctrl=4'b0000;
    #30 a = 32'b0110;
        b = 32'b1111;
        ALUctrl=4'b0110; // sub
    #30 a = 32'b0110;
        b = 32'b1111;
        ALUctrl=4'b0000; // and
    #30 ALUctrl=4'b0001; // or
    #30 ALUctrl=4'b0010; // add
    #30 ALUctrl=4'b0111; // slt
    #30 ALUctrl=4'b1100; // nor
  end
  
  initial #240 $finish;

endmodule
*/

/*
module simu_mux;

  //parameter half_period = 15;
  parameter n = 32;

  reg PCSrc;
  reg [n-1:0] s0, s1;
  wire [n-1:0] out;

  mux #(n) test_mux(PCSrc, s0, s1, out);
  
  initial begin
  $dumpfile("simu_mux.vcd");
  $dumpvars(0, simu_mux);
    #0  PCSrc = 1; //s0 = 1; s1 = 0;
        s0 = 32'b0011;
        s1 = 32'b11000011;
    #30 PCSrc = 0; 
        s0 = 32'b0011;
        s1 = 32'b1111;
    #30 PCSrc = 1; 
        s0 = 32'b1011;
        s1 = 32'b1001;
  end
  
  //always #half_period clock = ~clock;
  initial #100 $finish;
endmodule
*/



module simu_ctrl;

  //parameter half_period = 15;
  //parameter n = 32;

  reg [5:0] opcdoe;
  wire jump;
  wire [1:0] branch;
  wire [7:0] idexControl;
  
  Control ctrl(opcdoe, jump, branch, idexControl);

  initial begin
  $dumpfile("simu_ctrl.vcd");
  $dumpvars(0, simu_ctrl);
    #0  opcdoe = 6'b0;
    #10 opcdoe = 6'b100011;   // lw
    #10 opcdoe = 6'b101011;   // sw
    #10 opcdoe = 6'b001000;   // addi
    #10 opcdoe = 6'b001100;   // andi
    #10 opcdoe = 6'b000100;   // beq
    #10 opcdoe = 6'b000101;   // bne
    #10 opcdoe = 6'b000010;   // jc
        
  end
  
  //always #half_period clock = ~clock;
  initial #100 $finish;
endmodule



/*
module simu_sign;

  //parameter half_period = 15;
  //parameter n = 32;

  reg [15:0] Immin;
  wire [31:0] Immout;
  
  SignExtension sign(Immin, Immout);

  initial begin
  $dumpfile("simu_sign.vcd");
  $dumpvars(0, simu_sign);
    #0  Immin = 16'b1111111100000000;
    #20 Immin = 16'b1111111110100011; 
    #20 Immin = 16'b001011; 
    #20 Immin = 16'b001000; 
  end
  
  //always #half_period clock = ~clock;
  initial #100 $finish;
endmodule
*/


/*
module simu_ALUctrl;

  //parameter half_period = 15;
  //parameter n = 32;

  reg [5:0] funct;
  reg [1:0] ALUop;
  wire [3:0] ALUctrl;
  
  ALUControl ctrl(funct, ALUop, ALUctrl);

  initial begin
  $dumpfile("simu_ALUctrl.vcd");
  $dumpvars(0, simu_ALUctrl);
    #0  funct = 6'b101010;
        ALUop = 2'b10;
    #20 funct = 6'b100000;
        ALUop = 2'b10;
    #20 funct = 6'b100010;
        ALUop = 2'b11;
    #20 funct = 6'b100100;
        ALUop = 2'b01;
    #20 funct = 6'b100101;
        ALUop = 2'b00;
  end
  
  //always #half_period clock = ~clock;
  initial #120 $finish;
endmodule
*/






