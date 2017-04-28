`timescale 10ns / 1ns

module reg_test
();

	reg clk, rst, wen;
	reg [4:0] waddr, raddr1, raddr2;
	reg [31:0] wdata;
	wire [31:0] rdata1, rdata2;
	
	integer address;
	
	reg_file reg_file_tb(clk, rst, waddr, raddr1, raddr2, wen, wdata, rdata1, rdata2);
	
	always #5 clk = ~clk;
	
	initial begin
		clk = 0; rst = 1;
		address = 0; wen = 1;
		// wait for global reset
		#50 rst = 0;
		repeat (32) begin
			raddr1 = address;
			raddr2 = address;
			waddr = address;
			wdata = 32'b0;
			repeat (300) begin
				#10;
				wen = ($random);
				wdata <= wdata + 1;
			end
			address <= address + 1;
		end
		$stop;
	end

endmodule
