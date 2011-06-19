## Generated SDC file "top.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 10.1 Build 197 01/19/2011 Service Pack 1 SJ Full Version"

## DATE    "Sun Jun 19 17:52:17 2011"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {db_clk}]
create_clock -name {cm_pixclk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {cm_pixclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {altera_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {clock} [get_pins {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {altera_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -divide_by 3 -master_clock {clock} [get_pins {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {altera_pll_inst|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {altera_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock {clock} [get_pins {altera_pll_inst|altpll_component|auto_generated|pll1|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {cm_pixclk}] -rise_to [get_clocks {cm_pixclk}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {cm_pixclk}] -fall_to [get_clocks {cm_pixclk}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {cm_pixclk}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080 
set_clock_uncertainty -rise_from [get_clocks {cm_pixclk}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110 
set_clock_uncertainty -rise_from [get_clocks {cm_pixclk}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080 
set_clock_uncertainty -rise_from [get_clocks {cm_pixclk}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110 
set_clock_uncertainty -fall_from [get_clocks {cm_pixclk}] -rise_to [get_clocks {cm_pixclk}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {cm_pixclk}] -fall_to [get_clocks {cm_pixclk}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {cm_pixclk}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080 
set_clock_uncertainty -fall_from [get_clocks {cm_pixclk}] -rise_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110 
set_clock_uncertainty -fall_from [get_clocks {cm_pixclk}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080 
set_clock_uncertainty -fall_from [get_clocks {cm_pixclk}] -fall_to [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cm_pixclk}] -setup 0.110 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cm_pixclk}] -hold 0.080 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cm_pixclk}] -setup 0.110 
set_clock_uncertainty -rise_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cm_pixclk}] -hold 0.080 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cm_pixclk}] -setup 0.110 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cm_pixclk}] -hold 0.080 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cm_pixclk}] -setup 0.110 
set_clock_uncertainty -fall_from [get_clocks {altera_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cm_pixclk}] -hold 0.080 


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

