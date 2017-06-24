`timescale 10ns / 1ns

module alu_test
();

	reg [31:0] A, B;
	reg [2:0] ALUop;
	wire [31:0] Result;
	wire Overflow, Zero, CarryOut;
	
	initial begin
		// AND
		#50; ALUop = 3'b000;
		A = ($random); B = ($random);
		#5; A = 32'hFFFFFFFF; B = 32'hFFFFFFFF;
		#5; A = 32'h11110001; B = 32'h00000001;
		// OR
		#5; ALUop = 3'b001;
		A = ($random); B = ($random);
		#5; A = 32'hFFFFFFFF; B = 32'hFFFFFFFF;
		#5; A = 32'h11110001; B = 32'h00000001;	
		// ADD
		#5; ALUop = 3'b010;
		// 0001 = 1; 0010 = 2; 0111 = 7; 1000 = 8; 1111 = F
		A = ($random); B = ($random);
		// (+) 0 111...11 + 0 000...01
		#5; A = 32'h7FFFFFFF; B = 32'h00000001;
		// (-) 1 000...01 + 1 111...10
		#5; A = 32'h80000001; B = 32'hFFFFFFF2;
		// SUB
		#5; ALUop = 3'b110;
		A = ($random); B = ($random);
		// 0 111...11 - (-)0 000...01
		#5; A = 32'h7FFFFFFF; B = 32'h80000001;
		// (-) 1 000...01 - (-)1 111...10
		#5; A = 32'h80000001; B = 32'h7FFFFFF2;
		// SLT
		#5; ALUop = 3'b111;
		A = 32'h7FFFFFFF; B = 32'hFFFFFFF2;
		#5; A = 32'h80000001; B = 32'h00000001;
		#5; A = ($random); B = ($random);
		// Test Zero
		#5; ALUop = 3'b010;
		A = 32'h00000000; B = 32'h00000000;
		#5; ALUop = 3'b110;
		A = 32'hFFFFFFFF; B = 32'hFFFFFFFF;
	end
	
	alu ALU_tb(A, B, ALUop, Overflow, CarryOut, Zero, Result);

endmodule
