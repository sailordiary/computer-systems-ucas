/* =========================================
* Ideal Memory Module for MIPS CPU Core
* Synchronize write (clock enable)
* Asynchronize read (do not use clock signal)
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 31/05/2016
* Version: v0.0.1
*===========================================
*/

`timescale 1 ps / 1 ps

module ideal_mem #(
	parameter ADDR_WIDTH = 10,
	parameter MEM_WIDTH = 2 ** (ADDR_WIDTH - 2)
	) (
	input			clk,			//source clock of the MIPS CPU Evaluation Module

	input [ADDR_WIDTH - 1:0]	Waddr,			//Memory write port address
	input [ADDR_WIDTH - 1:0]	Raddr1,			//Read port 1 address
	input [ADDR_WIDTH - 1:0]	Raddr2,			//Read port 2 address

	input			Wren,			//write enable
	input			Rden1,			//port 1 read enable
	input			Rden2,			//port 2 read enable

	input [31:0]	Wdata,			//Memory write data
	output [31:0]	Rdata1,			//Memory read data 1
	output [31:0]	Rdata2			//Memory read data 2
);

reg [31:0]	mem [MEM_WIDTH - 1:0];

`define ADDIU(rt, rs, imm) {6'b001001, rs, rt, imm}
`define LW(rt, base, offset) {6'b100011, base, rt, offset}
`define SW(rt, base, offset) {6'b101011, base, rt, offset}
`define BNE(rt, rs, offset) {6'b000101, rs, rt, offset}
`define NOP 32'd0

/*         MIPS register set symbolic names         */
`define _zero 5'd0		// constant 0
`define _at 5'd1		// reserved for the assembler
`define _v0 5'd2		// result registers
`define _v1 5'd3
`define _a0 5'd4		// argument registers 1...4
`define _a1 5'd5
`define _a2 5'd6
`define _a3 5'd7
`define _t0 5'd8		// temporary registers 0...9
`define _t1 5'd9
`define _t2 5'd10
`define _t3 5'd11
`define _t4 5'd12
`define _t5 5'd13
`define _t6 5'd14
`define _t7 5'd15
`define _t8 5'd24
`define _t9 5'd25
`define _s0 5'd16		// saved registers 0...7
`define _s1 5'd17
`define _s2 5'd18
`define _s3 5'd19
`define _s4 5'd20
`define _s5 5'd21
`define _s6 5'd22
`define _s7 5'd23
`define _k0 5'd26		// kernel registers 0...1
`define _k1 5'd27
`define _gp 5'd28		// global data pointer
`define _sp 5'd29		// stack pointer
`define _fp 5'd30		// frame pointer
`define _ra 5'd31		// return address

`ifdef MIPS_CPU_SIM
	//Add memory initialization here
	initial begin
		/*
		// simple C program for verification
		mem[0] = `ADDIU(5'd1, 5'd0, 16'd100);
		mem[1] = `BNE(5'd1, `_zero, 16'd1);		// skip data memory
		mem[2] = 32'd9;							// const s = 9;
		mem[3] = `ADDIU(`_t0, `_zero, 16'd5);	// a = 5;
		mem[4] = `LW(`_t1, `_zero, 16'd8);		// b = s (mem[2]);
		mem[5] = `ADDIU(`_t0, `_t0, 16'd3);		// a = a + 3;
		mem[6] = `BNE(`_t0, `_t1, 16'd1);		// if (a == b)
		mem[7] = `ADDIU(`_t0, `_t0, 16'd0);		// 	a = a + a;
		mem[8] = `SW(`_s0, `_t0, 16'd0);		// else c = a;
		*/
		
		/*
		// mixing while loops with if conditions
		// note: the following program computes 0+1+2+...+10 and halts
		// $s0 = 10; $t0 = a; $t1 = b; $t2 = ADDIU instruction
		mem[0] = `ADDIU(`_s0, `_zero, 16'd10);	// const max = 10;
		mem[1] = `ADDIU(`_t1, `_zero, 16'd0);	// initialize loop counter b
		mem[2] = `ADDIU(`_t0, `_zero, 16'd0);	// initialize a
		mem[3] = `LW(`_t2, `_zero, 16'd20);		// initialize command register with mem[5]
		mem[4] = `BNE(`_t2, `_zero, 16'd1);		// jump to loop body mem[6]
		mem[5] = `ADDIU(`_t0, `_t0, 16'd0);		// initial: "a = a + 0"
		mem[6] = `ADDIU(`_t2, `_t2, 16'd1);		// increment command
		mem[7] = `SW(`_t2, `_zero, 16'd32);		// update command in mem[8]
		mem[8] = `NOP;							// to be replaced by command "a = a + x", x = 1...b
		mem[9] = `ADDIU(`_t1, `_t1, 16'd1);		// increment loop counter
		mem[10] = `BNE(`_s0, `_t1, -16'd5);		// if (b != max) jump to mem[6] and increment command
		mem[11] = `BNE(`_zero, `_s0, -16'd1);	// halt
		*/
		
		// memcpy
		mem[0] = 32'h241a0001;
		mem[1] = 32'h17400002;
		mem[2] = 32'h00000000;
		mem[3] = 32'hffffffff;
		mem[4] = 32'h24040000;
		mem[5] = 32'h24050064;
		mem[6] = 32'hac8400c8;
		mem[7] = 32'h24840004;
		mem[8] = 32'h1485fffd;
		mem[9] = 32'h00000000;
		mem[10] = 32'h24040000;
		mem[11] = 32'h8c8600c8;
		mem[12] = 32'hac86012c;
		mem[13] = 32'h24840004;
		mem[14] = 32'h1485fffc;
		mem[15] = 32'h00000000;
		mem[16] = 32'h24040000;
		mem[17] = 32'h8c86012c;
		mem[18] = 32'h14c40007;
		mem[19] = 32'h00000000;
		mem[20] = 32'h24840004;
		mem[21] = 32'h1485fffb;
		mem[22] = 32'h00000000;
		mem[23] = 32'h241a0001;
		mem[24] = 32'h17400005;
		mem[25] = 32'h00000000;
		mem[26] = 32'h24040001;
		mem[27] = 32'h241a0001;
		mem[28] = 32'h17400002;
		mem[29] = 32'h00000000;
		mem[30] = 32'h24040000;
		mem[31] = 32'hac04000c;
		mem[32] = 32'h241a0001;
		mem[33] = 32'h1740fffe;
		mem[34] = 32'h00000000;
	end
`endif

always @ (posedge clk)
begin
	if (Wren)
		mem[Waddr] <= Wdata;
end

assign Rdata1 = {32{Rden1}} & mem[Raddr1];
assign Rdata2 = {32{Rden2}} & mem[Raddr2];

endmodule
