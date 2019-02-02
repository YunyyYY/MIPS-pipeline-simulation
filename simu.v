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

`include "pipeline.v"


module simu;

	parameter half_period = 5;

	integer Time = 0;

	reg clock = 1;
	reg reset  = 1;
	wire[31:0] PC;
	//wire [31:0] dreg [0:31]  = test.regs.Registers;
	
	pipeline test(clock, reset, PC);

	initial begin
    	$dumpfile("simu.vcd");
    	$dumpvars(0, simu);
    	#1 reset = 0;
    end

    always #half_period begin   //posedge clock or negedge clock
    	if(clock == 1)Time = Time + 1;
    	$display("\n==========================================================");
    	$write("\nTime = %d, clock =          %d, ", Time, clock);
    	$write("PC =    0x%h\n", PC);
    	$display("[$s0] = 0x%h, [$s1] = 0x%h, [$s2] = 0x%h", 
    		test.regs.Registers[16], test.regs.Registers[17], test.regs.Registers[18]);
    	$display("[$s3] = 0x%h, [$s4] = 0x%h, [$s5] = 0x%h", 
    		test.regs.Registers[19], test.regs.Registers[20], test.regs.Registers[21]);
    	$display("[$s6] = 0x%h, [$s7] = 0x%h, [$t0] = 0x%h", 
    		test.regs.Registers[22], test.regs.Registers[23], test.regs.Registers[8]);
    	$display("[$t1] = 0x%h, [$t2] = 0x%h, [$t3] = 0x%h", 
    		test.regs.Registers[9], test.regs.Registers[10], test.regs.Registers[11]);
    	$display("[$t4] = 0x%h, [$t5] = 0x%h, [$t6] = 0x%h", 
    		test.regs.Registers[12], test.regs.Registers[13], test.regs.Registers[14]);
    	$display("[$t7] = 0x%h, [$t8] = 0x%h, [$t9] = 0x%h", 
    		test.regs.Registers[15], test.regs.Registers[24], test.regs.Registers[25]);
        // $display("[$ra] = 0x%h", test.regs.Registers[31]);
    	 clock = ~clock;
    end

	// always #half_period clock = ~clock;
    initial #400 $finish;

endmodule


/*
module simu;

	parameter half_period = 2;
	reg clock = 1, reset  = 1, PCWrite = 1, ifidwrite=1, ifFlush=0;
	wire[31:0] inst, pcplus, PCout, PCins;
	wire [25:0] raJump;
	wire [15:0] Immi;
	wire [5:0] ControlIn;
	wire [4:0] ifid_Rs, ifid_Rt, ifid_Rd;
	wire [3:0] PC4;

	PCReg PC(clock, reset, PCWrite, pcplus, PCins);
	adder  #(32) pcAdd(PCins, 32'b100, pcplus);
	InstMem instruction(PCins, inst);
	IF_ID ifid(clock, ifidwrite, ifFlush, pcplus, inst, 
				PCout, raJump, PC4, ControlIn, ifid_Rs, ifid_Rt, ifid_Rd, Immi);

	initial begin
    	$dumpfile("simu.vcd");
    	$dumpvars(0, simu);
    	#1 reset = 0;
    end

	always #half_period clock = ~clock;
    initial #15 $finish;

endmodule


*/




