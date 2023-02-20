set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVDS} [get_ports sysclk_p]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVDS} [get_ports sysclk_n]

set_property -dict {PACKAGE_PIN AV40 IOSTANDARD LVCMOS18} [get_ports reset]

##(PS/2) FMC2 PMOD

##PS2 Data
#System Module
set_property PACKAGE_PIN Y40 [get_ports ps2d]
set_property PULLUP true [get_ports ps2d]
set_property IOSTANDARD LVCMOS18 [get_ports ps2d]
#Mouse Module Loopback
#set_property PACKAGE_PIN W40 [get_ports interrupt]
#set_property IOSTANDARD LVCMOS18 [get_ports interrupt]

##PS2 Clock
#System Module
set_property PACKAGE_PIN AK38 [get_ports ps2c]
set_property PULLUP true [get_ports ps2c]
set_property IOSTANDARD LVCMOS18 [get_ports ps2c]
#Mouse Module Loopback
#set_property -dict {PACKAGE_PIN AB42 IOSTANDARD LVCMOS18} [get_ports clk_mouse]



##GPIO - PS2 Debug
#set_property -dict {PACKAGE_PIN W40 IOSTANDARD LVCMOS18} [get_ports tri_d]
#set_property -dict {PACKAGE_PIN AB42 IOSTANDARD LVCMOS18} [get_ports tri_c]

#set_property -dict {PACKAGE_PIN AU39 IOSTANDARD LVCMOS18} [get_ports ps2c_out]
#set_property -dict {PACKAGE_PIN AP42 IOSTANDARD LVCMOS18} [get_ports ps2d_out]

##====================================================================================================
## USB-uart Interface
set_property -dict {PACKAGE_PIN AU36 IOSTANDARD LVCMOS18} [get_ports tx]
set_property -dict {PACKAGE_PIN AU33 IOSTANDARD LVCMOS18} [get_ports rx]

create_clock -period 4.700 -name sysclk_p [get_ports sysclk_p]


#(PS/2) FMC1 PMOD
#set_property -dict {PACKAGE_PIN G39 IOSTANDARD LVCMOS18} [get_ports ps2d]
#set_property -dict {PACKAGE_PIN P42 IOSTANDARD LVCMOS18} [get_ports ps2c]
