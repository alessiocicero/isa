//Project: RISC-V 32 bit Architecture
//Module: HDU Test bench
//Author: Filippo Carastro
//Updated: 05/02/2022
//Updates:

`timescale 1ns/1ns
module tb_hdu();

reg regWrite,branch_sel;
reg [4:0] Rd_prev,Rs1,Rs2;
reg [6:0] opcode;
wire stall;

hazard_detection_unit DUT(regWrite, branch_sel, opcode, Rd_prev, Rs1, Rs2, stall);

initial

begin
	
regWrite = 1'b0; branch_sel = 1'b0; opcode = 7'b0011000; Rd_prev = 5'b00000; Rs1 = 5'b00000; Rs2 = 5'b00000; #10;
regWrite = 1'b1; branch_sel = 1'b0; opcode = 7'b0011000; Rd_prev = 5'b00100; Rs1 = 5'b00100; Rs2 = 5'b00000; #10;	//Stall
regWrite = 1'b1; branch_sel = 1'b0; opcode = 7'b0011000; Rd_prev = 5'b00100; Rs1 = 5'b00000; Rs2 = 5'b00000; #10;

regWrite = 1'b0; branch_sel = 1'b0; opcode = 7'b1100011; Rd_prev = 5'b00000; Rs1 = 5'b00000; Rs2 = 5'b00000; #10;	//Stall
regWrite = 1'b0; branch_sel = 1'b0; opcode = 7'b0000011; Rd_prev = 5'b00000; Rs1 = 5'b00000; Rs2 = 5'b00000; #10;	//Stall
regWrite = 1'b0; branch_sel = 1'b0; opcode = 7'b1000011; Rd_prev = 5'b00000; Rs1 = 5'b00000; Rs2 = 5'b00000; #10;	//Stall
regWrite = 1'b0; branch_sel = 1'b1; opcode = 7'b1000011; Rd_prev = 5'b00000; Rs1 = 5'b00000; Rs2 = 5'b00000; #10;

regWrite = 1'b1; branch_sel = 1'b1; opcode = 7'b1100011; Rd_prev = 5'b00100; Rs1 = 5'b00100; Rs2 = 5'b00000; #10;	//Stall

end

endmodule // tb_hdu