`ifdef SIM
    `define limit 32'd500
`else
    `define limit 32'd1250_0000
`endif

module led_pipe
(   
    input clk_in,
    input reset_in,
    output reg [7:0] leds
);

// clock counter
reg [31:0] clk_ctr;

always@(posedge clk_in or posedge reset_in)
begin
    if(reset_in)
    begin
        clk_ctr <= 32'd0;
        leds <= 8'b1000_0000;
    end
    
    else
    begin
    	clk_ctr <= clk_ctr + 1;
    	if(clk_ctr == `limit)
    		begin
    			leds <= {leds[6:0], leds[7]};
    			clk_ctr <= 32'd0;
    		end
    end
end

endmodule
