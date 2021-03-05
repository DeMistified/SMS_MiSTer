
# Decouple asynchronous clocks

set_clock_groups -asynchronous -group [get_clocks {spiclk}] -group [get_clocks guest|pll|altpll_component|auto_generated|pll1|clk[*]]


# Input delays

set_input_delay -clock [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -reference_pin [get_ports ${RAM_CLK}] -max 6.4 [get_ports ${RAM_IN}]
set_input_delay -clock [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -reference_pin [get_ports ${RAM_CLK}] -min 3.2 [get_ports ${RAM_IN}]

# Output delays


set_output_delay -clock [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -reference_pin [get_ports ${RAM_CLK}] -max 1.5 [get_ports ${RAM_OUT}]
set_output_delay -clock [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -reference_pin [get_ports ${RAM_CLK}] -min -0.8 [get_ports ${RAM_OUT}]

set_output_delay -clock [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -max 0 [get_ports ${VGA_OUT}]
set_output_delay -clock [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -min -5 [get_ports ${VGA_OUT}]

# false paths

set_false_path -from [get_clocks {spiclk}] -to [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path -from [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {spiclk}]

set_false_path -to [get_ports ${FALSE_OUT}]

# Multicycles

# set_multicycle_path -from [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {guest|clock_21mhz|altpll_component|auto_generated|pll1|clk[0]}] -setup 2
# set_multicycle_path -from [get_clocks {guest|pll|altpll_component|auto_generated|pll1|clk[1]}] -to [get_clocks {guest|clock_21mhz|altpll_component|auto_generated|pll1|clk[0]}] -hold 1

set_multicycle_path -to ${VGA_OUT} -setup 2
set_multicycle_path -to ${VGA_OUT} -hold 1

# T80 just cannot run in 64 MHz, but it's safe to allow 2 clock cycles for the paths in it
set_multicycle_path -from {guest|system|z80_inst|u0|*} -setup 2
set_multicycle_path -from {guest|system|z80_inst|u0|*} -hold 1
