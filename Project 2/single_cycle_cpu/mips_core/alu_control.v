module alu_control(
	input  [5:0] func,
	
	input  [1:0] ALUOp,
	output reg [2:0] ALUctr
);

	parameter AND = 3'b000;
	parameter ADD = 3'b010;
	parameter SUB = 3'b110;
	parameter OR = 3'b001;
	parameter SLT = 3'b111;
	
	always @(*) begin
		casex ({ALUOp, func})
			8'b00xxxxxx: ALUctr <= ADD;	// LW or SW
			8'b01xxxxxx: ALUctr <= SUB;	// BNE
			8'b11xxxxxx: ALUctr <= ADD;	// I-type, since we do not have SLL
			// PLACEHOLDER: for R-type instructions, ALUOp = 2'b10
			default: ALUctr <= 3'b000;	// exceptions
		endcase
	end

endmodule