module alu_control(
	input  [5:0] func,
	
	input  [1:0] ALUOp,
	output reg [2:0] ALUctr
);

	// ALU function code
	parameter OP_NOP  = 3'b000;
	parameter OP_AND  = 3'b000;
	parameter OP_OR   = 3'b001;
	parameter OP_ADD  = 3'b010;
	parameter OP_SLL  = 3'b011;
	parameter OP_SLTU = 3'b100;
	parameter OP_LUI  = 3'b101;
	parameter OP_SUB  = 3'b110;
	parameter OP_SLT  = 3'b111;
	
	// MIPS function code
	parameter SLL   = 6'b000000;			// SLL(NOP)
	parameter ADDU  = 6'b100001;
	parameter OR    = 6'b100101;
	parameter JR    = 6'b001000;
	parameter SLT   = 6'b101010;
	parameter ADDIU = 6'b001001;
	parameter SLTI  = 6'b001010;
	parameter SLTIU = 6'b001011;
	parameter JAL   = 6'b000011;
	parameter LUI   = 6'b001111;
	
	always @(*) begin
		case (ALUOp)
			2'b00: ALUctr <= OP_ADD;	// LW or SW
			2'b01: ALUctr <= OP_SUB;	// BEQ or BNE
			2'b10:						// R-type
				case (func)
					SLL:  ALUctr <= OP_SLL;
					ADDU: ALUctr <= OP_ADD;
					OR:   ALUctr <= OP_OR;
					JR:   ALUctr <= OP_ADD;	// [$zero]+GPR[rs] = GPR[rs]; optimize later
					SLT:  ALUctr <= OP_SLT;
					default: ALUctr <= OP_NOP;
				endcase
			2'b11:					// I-type or J-type
				case (func)
					ADDIU: ALUctr <= OP_ADD;
					SLTI:  ALUctr <= OP_SLT;
					SLTIU: ALUctr <= OP_SLTU;
					LUI:   ALUctr <= OP_LUI;
					JAL:   ALUctr <= OP_ADD;
					default: ALUctr <= OP_NOP;
				endcase
		endcase
	end

endmodule