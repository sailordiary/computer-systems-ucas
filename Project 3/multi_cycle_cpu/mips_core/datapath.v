module datapath(
	input  rst,
	input  clk,
	
	// signals from control
	output wire[5:0] Op,
	input  [1:0] ALUOp, PCSource, ALUSrcB, ALUSrcA, RegDst, MemtoReg,
	input  PCWrite, PCWriteCond, RegWrite, MemWrite, MemRead, IRWrite, PCwen,

	// signals from ALU control
	output wire [5:0] func,
	
	// signals from ALU
	output reg [31:0] OpB,
	output reg [31:0] OpA,
	input  [31:0] Result,
	input  Zero,
	
	// signals from register file
	output reg [4:0] waddr,
	output wire [4:0] raddr1, raddr2,
	output wire wen,
	output reg [31:0] wdata,
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

	// additional registers
	reg  [31:0] MDR, IR, ALUOut, A, B;
	
	wire [4:0] rs, rt, rd, sa;
	wire [15:0] immediate;
	
	reg  [31:0] nPC;
	
	wire [31:0] sext_imm;
	
	initial begin
		nPC = 32'b0;
	end
	
	assign Op = IR[31:26];
	assign rs = IR[25:21];
	assign rt = IR[20:16];
	assign rd = IR[15:11];
	assign sa = IR[10:6];
	
	assign immediate = IR[15:0];
	assign sext_imm = {{(16){IR[15]}}, immediate};
	// we assign the Op field to func for I-type instructions
	assign func = (ALUOp == 2'b11) ? IR[31:26]: IR[5:0];

	// program counter
	always @(*)
		case (PCSource)
			2'b00: nPC <= Result;
			2'b01: nPC <= ALUOut;
			2'b10: nPC <= {mips_PC[31:28], IR[25:0], 2'b00};
			default: nPC <= Result;
		endcase

	// ALU
	always @(*)
		case (ALUSrcA)
			2'b00: OpA = mips_PC;
			2'b01: OpA = A;
			2'b10: OpA = sa;
			2'b11: OpA = 32'd16;
		endcase

	always @(*)
		case (ALUSrcB)
			2'b00: OpB = B;
			2'b01: OpB = 32'd4;
			2'b10: OpB = sext_imm;
			2'b11: OpB = sext_imm << 2;
		endcase
	
	// register file
	always @(*)
		case (RegDst)
			2'b00: waddr = rt;
			2'b01: waddr = rd;
			2'b10: waddr = 5'd31;	// JAL
			default: waddr = 5'd0;
		endcase

	assign raddr1 = rs;
	assign raddr2 = rt;
	assign wen = RegWrite;
	always @(*)
		case (MemtoReg)
			2'b00: wdata = ALUOut;
			2'b01: wdata = MDR;
			2'b10: wdata = Result;
			default: wdata = Result;
		endcase
	
	// MIPS
	assign mips_MemWrite = MemWrite;
	assign mips_MemRead = MemRead;
	assign mips_Address = ALUOut;
	assign mips_Write_data = B;

	always @(posedge clk) begin
		if (rst) begin
			IR <= 32'b0; MDR <= 32'b0;
			mips_PC <= 32'b0;
			A <= 32'b0; B <= 32'b0;
			ALUOut <= 32'b0;
		end
		else begin
			if (PCwen) mips_PC <= nPC;
			if (IRWrite) IR <= mips_Instruction;
			MDR <= mips_Read_data;
			A <= rdata1;
			B <= rdata2;
			ALUOut <= Result;
		end
	end

endmodule