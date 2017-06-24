`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement a 4-bit ALU
    `define DATA_WIDTH 4
`else
    `define DATA_WIDTH 32
`endif

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);

	// behavioral implementation
	parameter	AND	 = 3'b000,	// bitwise and
				OR	 = 3'b001,	// bitwise or
				ADD  = 3'b010,	// arithmetic addition
				SUB  = 3'b110,	// arithmetic subtraction
				SLL  = 3'b011,	// shift word left logical
				SLTU = 3'b100,	// unsigned set-on-less-than
				LUI  = 3'b101,	// load upper immediate
				SLT  = 3'b111;	// set-on-less-than
	
	// stores the last carry
	reg LastCout;
	reg [`DATA_WIDTH - 1:0] Result;
	
	always @(A, B, ALUop) begin
		case (ALUop)
			AND: begin
				Result = A & B; LastCout = `DATA_WIDTH'b0;
			end
			OR: begin
			 	Result = A | B; LastCout = `DATA_WIDTH'b0;
			 end
			ADD: {LastCout, Result} = A + B;
			SUB: {LastCout, Result} = A - B;
			SLT: begin
				Result = ($signed(A) < $signed(B))? `DATA_WIDTH'b1 : `DATA_WIDTH'b0; LastCout = `DATA_WIDTH'b0;
			end
			SLTU: begin
				Result = (A < B)? `DATA_WIDTH'b1 : `DATA_WIDTH'b0; LastCout = `DATA_WIDTH'b0;
			end
			SLL: begin
				Result = B << A; LastCout = `DATA_WIDTH'b0;
			end
			LUI: begin
				Result = {B[15:0], 16'b0}; LastCout = `DATA_WIDTH'b0;
			end
			// catches exceptions, should not occur
			default: begin
				Result = `DATA_WIDTH'b0; LastCout = `DATA_WIDTH'b0;
			end
		endcase
	end
	
	/*
		CarryOut: defined for ADD and SUB, undefined otherwise (casts 0)
		- CarryOut = LastCout XOR IS_SUB
		- for A-B, we actually use A+~B+1 so LastCout should be inverted for SUB
	*/
	assign CarryOut = (ALUop == ADD && LastCout) || (ALUop == SUB && (~LastCout ^ 1));
	/*
		Overflow: defined for ADD and SUB, undefined otherwise (casts 0)
		2's complement overflow happens:
		 - if a sum of two positive numbers results in a negative number
		 - if a sum of two negative numbers results in a positive number
	*/
	assign Overflow = (ALUop == ADD && (A[`DATA_WIDTH - 1] == B[`DATA_WIDTH - 1]) && (LastCout ^ Result[`DATA_WIDTH - 1]))
					|| (ALUop == SUB && (A[`DATA_WIDTH - 1] == ~B[`DATA_WIDTH - 1]) && (~LastCout ^ Result[`DATA_WIDTH - 1]));
	// Zero: defined for SUB, undefined otherwise (casts 0)
	assign Zero = (ALUop[1:0] == 2'b10) && (!Result);
	
endmodule
