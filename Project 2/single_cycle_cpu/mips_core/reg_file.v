`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement 4 4-bit registers
    `define DATA_WIDTH 4
	`define ADDR_WIDTH 2
`else
    `define DATA_WIDTH 32
	`define ADDR_WIDTH 5
`endif

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

	parameter REG_UNITS = 1 << `ADDR_WIDTH;

	reg [`DATA_WIDTH - 1:0] r[REG_UNITS - 1:0];
	
	integer i;
	
	initial begin
		for (i = 0; i < REG_UNITS; i = i + 1) r[i] = `DATA_WIDTH'b0;
	end
	
	always @(posedge clk) begin
		// zero register ($zero) always gives a value of zero and should not be overwritten
		if (wen && waddr) r[waddr] <= wdata;
	end
	
	
	assign rdata1 = r[raddr1];
	assign rdata2 = r[raddr2];

endmodule
