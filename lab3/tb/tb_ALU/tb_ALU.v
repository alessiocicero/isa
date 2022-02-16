//Project: RISC-V 32 bit Architecture
//Module: HDU Test bench
//Author: Filippo Carastro
//Updated: 05/02/2022
//Updates:

`timescale 1ns/1ns
module tb_ALU();

reg [31:0] A,B;
reg [2:0] ALU_cmd;
wire [31:0] result;
wire zero;

ALU DUT(A,B,ALU_cmd,result,zero);

initial

begin

A = 22; B = 10; ALU_cmd = 0'b111; #10;	//AND
A = 32'h0000000A; B = 31; ALU_cmd = 0'b101; #10; //SRAI
A = 32'hFFFFFFFC; B = 0; ALU_cmd = 0'b001; #10;

end

endmodule // tb_ALU