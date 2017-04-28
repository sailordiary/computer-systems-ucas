module datapath(
	input  rst,
	input  clk,
	
	// signals from Control
	output wire[5:0] Op,
	input  [1:0] ALUOp, 
	input  RegWrite, RegDst, MemtoReg, ALUSrc, MemWrite, MemRead, Branch, 

	// signals from ALU Control
	output wire [5:0] func,
	
	// signals from ALU
	output [31:0] A, B,
	input  [31:0] Result,
	input  Zero,
	
	// signals from register file
	output wire [4:0] waddr, raddr1, raddr2,
	output wire wen,
	output wire [31:0] wdata,
	input  [31:0] rdata1, rdata2,
	
	// MIPS core I/O
	output reg [31:0] mips_PC,
    input  [31:0] mips_Instruction,
	output wire [31:0] mips_Address,
	output wire mips_MemWrite,
	output wire mips_MemRead,
	output wire [31:0] mips_Write_data,
	input  [31:0] mips_Read_data
);

	wire [4:0] rs, rt, rd; // note: no R-type ops specified so far
	wire [15:0] immediate;
	
	wire PCsrc, SignExtend;
	reg  [31:0] nPC; // PC and nextPC (nPC)
	wire [31:0] PC_p4, PC_jump; // wire or reg?
	
	wire [31:0] sext_imm;
	
	initial begin
		nPC = 32'b0;
	end
	
	assign Op = mips_Instruction[31:26];
	assign rs = mips_Instruction[25:21];
	assign rt = mips_Instruction[20:16];
	assign rd = mips_Instruction[15:11];
	assign immediate = mips_Instruction[15:0];
	assign func = mips_Instruction[5:0];
	
	// multiplexors
	assign SignExtend = mips_Instruction[15];
	assign PCsrc = ({Branch, Zero} == 2'b10);
	
	assign sext_imm = SignExtend ? {16'hFFFF, immediate} : {16'h0000, immediate};
	
	/* quote Patterson: "The adder is an ALU wired to always perform an add of
	 its two 32-bit inputs and place the result on its output."; for the sake
	 of simplicity, we use two adders.                                       */
	assign PC_p4 = mips_PC + 4;
	assign PC_jump = PC_p4 + (sext_imm << 2);
	// alu add32_0(.A(mips_PC), .B(4), .ALUop(3'b010), .Overflow(), .CarryOut(), .Zero(), .Result(PC_p4));
	// alu add32_1(.A(PC_p4), .B(sext_imm << 2), .ALUop(3'b010), .Overflow(), .CarryOut(), .Zero(), .Result(PC_jump));
	
	// ALU
	assign A = rdata1;
	assign B = ALUSrc ? sext_imm : rdata2;
	
	// register file
	assign waddr = RegDst ? rd : rt;
	assign raddr1 = rs;
	assign raddr2 = rt;
	assign wen = RegWrite;
	assign wdata = MemtoReg ? mips_Read_data : Result;
	
	// MIPS
	assign mips_MemWrite = MemWrite;
	assign mips_MemRead = MemRead;
	assign mips_Address = Result;
	assign mips_Write_data = rdata2;

	always @(posedge clk) begin
		if (rst) mips_PC <= 32'b0;
		else mips_PC <= nPC;
	end
	
	always @(*) begin
		nPC <= PCsrc ? PC_jump : PC_p4;
	end

endmodule