module mips_cpu(
	input  rst,
	input  clk,

	output [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,

	input  [31:0] Read_data,
	output MemRead
);

	wire [31:0] mips_cpu_datapath_A, mips_cpu_datapath_B, mips_cpu_alu_Result;
	wire [1:0] mips_cpu_control_ALUOp;
	wire mips_cpu_alu_Zero;
	wire [5:0] mips_cpu_datapath_Op;
	wire mips_cpu_control_RegDst, mips_cpu_control_RegWrite;
	wire mips_cpu_control_MemRead, mips_cpu_control_MemtoReg, mips_cpu_control_MemWrite;
	wire mips_cpu_control_ALUSrc, mips_cpu_control_Branch;
	wire [5:0] mips_cpu_datapath_func;
	wire [2:0] mips_cpu_alu_control_ALUctr;
	wire [4:0] mips_cpu_datapath_waddr,mips_cpu_datapath_raddr1, mips_cpu_datapath_raddr2;
	wire mips_cpu_datapath_wen;
	wire [31:0] mips_cpu_datapath_wdata, mips_cpu_reg_file_rdata1, mips_cpu_reg_file_rdata2;
	
	control mips_cpu_control
		(.Op(mips_cpu_datapath_Op),
		 .ALUOp(mips_cpu_control_ALUOp),
		 .RegDst(mips_cpu_control_RegDst),
		 .Branch(mips_cpu_control_Branch),
		 .MemRead(mips_cpu_control_MemRead),
		 .MemtoReg(mips_cpu_control_MemtoReg),
		 .MemWrite(mips_cpu_control_MemWrite),
		 .ALUSrc(mips_cpu_control_ALUSrc),
		 .RegWrite(mips_cpu_control_RegWrite));
	alu_control mips_cpu_alu_control
		(.func(mips_cpu_datapath_func),
		 .ALUOp(mips_cpu_control_ALUOp),
		 .ALUctr(mips_cpu_alu_control_ALUctr));
	reg_file mips_cpu_reg_file
		(.clk(clk),
		 .rst(rst),
		 .waddr(mips_cpu_datapath_waddr),
		 .raddr1(mips_cpu_datapath_raddr1),
		 .raddr2(mips_cpu_datapath_raddr2),
		 .wen(mips_cpu_datapath_wen),
		 .wdata(mips_cpu_datapath_wdata),
		 .rdata1(mips_cpu_reg_file_rdata1),
		 .rdata2(mips_cpu_reg_file_rdata2));
	datapath mips_cpu_datapath
		(.rst(rst),
		 .clk(clk),
		 .Op(mips_cpu_datapath_Op),
		 .ALUOp(mips_cpu_control_ALUOp),
		 .RegDst(mips_cpu_control_RegDst),
		 .Branch(mips_cpu_control_Branch),
		 .MemRead(mips_cpu_control_MemRead),
		 .MemtoReg(mips_cpu_control_MemtoReg),
		 .MemWrite(mips_cpu_control_MemWrite),
		 .ALUSrc(mips_cpu_control_ALUSrc),
		 .RegWrite(mips_cpu_control_RegWrite),
		 .func(mips_cpu_datapath_func),
		 .A(mips_cpu_datapath_A),
		 .B(mips_cpu_datapath_B),
		 .Result(mips_cpu_alu_Result),
		 .Zero(mips_cpu_alu_Zero),
		 .waddr(mips_cpu_datapath_waddr),
		 .raddr1(mips_cpu_datapath_raddr1),
		 .raddr2(mips_cpu_datapath_raddr2),
		 .wen(mips_cpu_datapath_wen),
		 .wdata(mips_cpu_datapath_wdata),
		 .rdata1(mips_cpu_reg_file_rdata1),
		 .rdata2(mips_cpu_reg_file_rdata2),
		 .mips_PC(PC),
		 .mips_Instruction(Instruction),
		 .mips_Address(Address),
		 .mips_MemWrite(MemWrite),
		 .mips_MemRead(MemRead),
		 .mips_Write_data(Write_data),
		 .mips_Read_data(Read_data));
	alu mips_cpu_alu
		(.A(mips_cpu_datapath_A),
		 .B(mips_cpu_datapath_B),
 		 .ALUop(mips_cpu_alu_control_ALUctr),
 		 .Overflow(),
 		 .CarryOut(),
 		 .Zero(mips_cpu_alu_Zero),
 		 .Result(mips_cpu_alu_Result));

endmodule
