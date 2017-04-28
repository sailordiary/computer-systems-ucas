module control(
	input  [5:0] Op,
	output reg [1:0] ALUOp,
	
	output reg RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite
);

	parameter ADDIU = 6'b001001;
	parameter LW = 6'b100011;
	parameter SW = 6'b101011;
	parameter BNE = 6'b000101;
	parameter SPECIAL = 6'b000000;

	always @(*) begin
		case (Op)
			LW: {ALUOp, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite} <= 9'b00_0011011;
			SW: {ALUOp, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite} <= 9'b00_0000110;
			BNE: {ALUOp, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite} <= 9'b01_0100000;
			ADDIU: {ALUOp, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite} <= 9'b11_0000011;
			SPECIAL: {ALUOp, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite} <= 9'b10_1000000;
			default: {ALUOp, RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite} <= 9'b00_0000000;
		endcase
	end
	
endmodule