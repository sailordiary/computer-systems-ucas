
module alu_fpga (   
	input [7:0] sw,
	input [2:0] btn,
	output [2:0] led,
	output [6:0] seg
);

	wire [3:0] C;

	alu alu_i(
		.A(sw[7:4]),
		.B(sw[3:0]),
		.ALUop(btn),
		.Overflow(led[2]),
		.CarryOut(led[1]),
		.Zero(led[0]),
		.Result(C)
	);

	seg_impl digit(
		.num(C),
		.seg(seg)
	);

endmodule

