
`define LIMIT 32'd50_000_000

module reg_fpga (   
	input clk,
	input [7:0] sw,
	input [1:0] btn,
	output [7:0] led,
	output [6:0] seg
);

	reg [1:0] rst_i = 2'b11;
	wire rst;

	reg [1:0] raddr2;
	reg [31:0] clk_cnt;

	always @(posedge clk)
		rst_i <= {rst_i[0], btn[1]};

	assign rst = rst_i[1];

	always@(posedge clk)
	begin
		if(rst) begin
			raddr2 <= 2'b0;
			clk_cnt <= 32'd0;
		end
		else begin
			clk_cnt <= (clk_cnt == `LIMIT ? 32'd0 : clk_cnt + 1'b1);
			if(clk_cnt == `LIMIT) begin
				raddr2 <= raddr2 + 1'b1;
			end
		end
	end

	reg_file reg_i(
		.clk(clk),
		.rst(rst),
		.waddr(sw[5:4]),
		.raddr1(sw[7:6]),
		.raddr2(raddr2),
		.wen(btn[0]),
		.wdata(sw[3:0]),
		.rdata1(led[7:4]),
		.rdata2(led[3:0])
	);

	seg_impl digit_raddr2(
		.num({2'b0, raddr2}),
		.seg(seg)
	);

endmodule

