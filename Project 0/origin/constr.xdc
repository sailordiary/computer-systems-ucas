create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk_in]
set_property PACKAGE_PIN Y9 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]

set_property PACKAGE_PIN R16 [get_ports reset_in]
set_property IOSTANDARD LVCMOS33 [get_ports reset_in]

set_property PACKAGE_PIN T22 [get_ports leds[0]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[0]]

set_property PACKAGE_PIN T21 [get_ports leds[1]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[1]]

set_property PACKAGE_PIN U22 [get_ports leds[2]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[2]]

set_property PACKAGE_PIN U21 [get_ports leds[3]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[3]]

set_property PACKAGE_PIN V22 [get_ports leds[4]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[4]]

set_property PACKAGE_PIN W22 [get_ports leds[5]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[5]]

set_property PACKAGE_PIN U19 [get_ports leds[6]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[6]]

set_property PACKAGE_PIN U14 [get_ports leds[7]]
set_property IOSTANDARD LVCMOS33 [get_ports leds[7]]