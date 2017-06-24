module seg_impl(
	input [3:0] num,
	output reg [6:0] seg
);

	always@(*) begin
		case(num)
			4'h0: seg = 7'b0000001;
			4'h1: seg = 7'b1001111;
			4'h2: seg = 7'b0010010;
			4'h3: seg = 7'b0000110;
			4'h4: seg = 7'b1001100;
			4'h5: seg = 7'b0100100;
			4'h6: seg = 7'b0100000;
			4'h7: seg = 7'b0001101;
			4'h8: seg = 7'b0000000;
			4'h9: seg = 7'b0000100;
			4'ha: seg = 7'b0001000;
			4'hb: seg = 7'b1100000;
			4'hc: seg = 7'b0110001;
			4'hd: seg = 7'b1000010;
			4'he: seg = 7'b0110000;
			4'hf: seg = 7'b0111000;
		endcase
	end

endmodule
