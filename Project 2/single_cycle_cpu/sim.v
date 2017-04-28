`timescale 10ns / 1ns

module mips_cpu_test
();

	reg		mips_cpu_clk;
    reg     mips_cpu_reset;

	initial begin
		mips_cpu_clk = 1'b0;
		mips_cpu_reset = 1'b1;
		# 3
		mips_cpu_reset = 1'b0;

		# 200
		$finish;
	end

	always begin
		# 1 mips_cpu_clk = ~mips_cpu_clk;
	end

    mips_cpu_top    u_mips_cpu_top (
        .mips_cpu_clk       (mips_cpu_clk),
        .mips_cpu_reset   (mips_cpu_reset)
    );

endmodule
