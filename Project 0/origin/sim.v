`timescale 10ns / 1ns
`define SIM

module led_test
();

 reg clk_in;
 reg reset_in; 
 
 wire [7:0] leds;
 
 led_pipe led_pipe
 (
    .clk_in(clk_in),
    .reset_in(reset_in),
    .leds(leds)
 );
 
 
 initial
 begin
 
 clk_in   = 0;
 reset_in = 0;
 
 #5 reset_in = 1;
 #5 reset_in = 0;
 
 end
 
 always begin #10 clk_in = ~clk_in; end
 
 endmodule
 
 