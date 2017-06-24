module control(
	input  clk, rst, Zero,

	input  [5:0] Op, func,
	output reg [1:0] ALUOp, ALUSrcB, ALUSrcA, PCSource, RegDst, MemtoReg, 

	output reg PCWriteCond, PCWrite, MemRead, MemWrite, IRWrite, RegWrite,
	output wire PCwen
);
	
	parameter JR = 6'b001000;
	parameter SLL = 6'b000000;

	parameter SPECIAL = 6'b000000;  // SLL(NOP), JR, ADDU, OR(MOVE)
	parameter J = 6'b000010;
	parameter JAL = 6'b000011;
	parameter BEQ = 6'b000100;      // B, BEQ(BEQZ)
	parameter BNE = 6'b000101;
	parameter ADDIU = 6'b001001;    // ADDIU(LI)
	parameter SLTI = 6'b001010;
	parameter SLTIU = 6'b001011;
	parameter LUI = 6'b001111;
	parameter LW = 6'b100011;
	parameter SW = 6'b101011;

	// FSM data selector
	parameter FETCH = 4'b0000;			// instruction fetch
	parameter DECODE = 4'b0001;			// instruction decode / register fetch
	parameter MEMADDRCOMP = 4'b0010;	// memory address computation
	parameter MEMACCESS_L = 4'b0011;	// memory access (LW)
	parameter MEMRDEND = 4'b0100;		// memory read completion step
	parameter MEMACCESS_S = 4'b0101;	// memory access (SW)
	parameter RTYPEEXEC = 4'b0110;		// R-type execution
	parameter RTYPEEND = 4'b0111;		// R-type completion
	parameter BRANCHEND = 4'b1000;		// branch completion
	parameter JMPEND = 4'b1001;			// jump completion
	parameter ITYPEEXEC = 4'b1010;		// I-type execution
	parameter ITYPEEND = 4'b1011;		// I-type completion
	parameter JALEXEC = 4'b1100;		// JAL execution, step 1 (PC)
	parameter JREXEC = 4'b1101;			// JR execution
	parameter SLLEXEC = 4'b1110;
	parameter LUIEXEC = 4'b1111;
	
	reg [3:0] state, nextstate;

	// BNE or BEQ
	assign PCwen = PCWrite | (PCWriteCond & (Op[0] ? !Zero : Zero));

	// synchronous reset
	always @(posedge clk)
		if (rst)
			state <= FETCH;
		else
			state <= nextstate;

	// next state logic
	always @(state or Op or func) begin
		case (state)
			FETCH: nextstate <= DECODE;
			DECODE: case (Op)
				SPECIAL:
					case (func)
						JR: nextstate <= JREXEC;
						SLL: nextstate <= SLLEXEC;
						default: nextstate <= RTYPEEXEC;
					endcase
				ADDIU, SLTI, SLTIU: nextstate <= ITYPEEXEC;
				LUI: nextstate <= LUIEXEC;
				BEQ, BNE: nextstate <= BRANCHEND;
				J: nextstate <= JMPEND;
				JAL: nextstate <= JALEXEC;
				LW: nextstate <= MEMADDRCOMP;
				SW: nextstate <= MEMADDRCOMP;
				default: nextstate <= FETCH;
			endcase
			MEMADDRCOMP: case(Op)
				LW: nextstate <= MEMACCESS_L;
				SW: nextstate <= MEMACCESS_S;
				default: nextstate <= FETCH;
			endcase
			JALEXEC: nextstate <= JMPEND;	// jump after PC+4
			JREXEC: nextstate <= FETCH;
			LUIEXEC: nextstate <= ITYPEEND;
			SLLEXEC: nextstate <= RTYPEEND;
			MEMACCESS_L: nextstate <= MEMRDEND;
			RTYPEEXEC: nextstate <= RTYPEEND;
			ITYPEEXEC: nextstate <= ITYPEEND;
			MEMACCESS_S, MEMRDEND, ITYPEEND, RTYPEEND, BRANCHEND, JMPEND: nextstate <= FETCH;
			default: nextstate <= FETCH;
		endcase
	end

	always @(state) begin
		case (state)
			FETCH:  {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0110_00_1_00_00_00_01_0_00;
			DECODE: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_00_00_11_0_00;
			MEMADDRCOMP: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_00_01_10_0_00;
			MEMACCESS_L: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0010_00_0_00_00_00_00_0_00;
			MEMACCESS_S: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0001_00_0_00_00_00_00_0_00;
			RTYPEEXEC: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_10_01_00_0_00;
			RTYPEEND:  {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_00_00_00_1_01;
			JREXEC:    {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0100_00_0_00_10_01_00_0_00;
			SLLEXEC:   {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_10_10_00_0_00;
			LUIEXEC:   {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_11_11_10_0_00;
			// for the time being we use PC+4 for JAL
			JALEXEC:   {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_10_0_00_11_00_01_1_10;
			ITYPEEXEC: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_11_01_10_0_00;
			ITYPEEND:  {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_00_0_00_00_00_00_1_00;
			BRANCHEND: {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b1000_00_0_01_01_01_00_0_00;
			MEMRDEND:  {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0000_01_0_00_00_00_00_1_00;
			JMPEND:    {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0100_00_0_10_00_00_00_0_00;
			default:   {PCWriteCond, PCWrite, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcA, ALUSrcB, RegWrite, RegDst} <= 18'b0;
		endcase
	end

endmodule