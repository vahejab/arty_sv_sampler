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
#set_property -dict {PACKAGE_PIN W40 IOSTANDARD LVCMOS18} [get_ports data_mouse]

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



#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list genblk1.clk_100M]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 8 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[0]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[1]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[2]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[3]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[4]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[5]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[6]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_data[7]}]]
#create_debug_core u_ila_1 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
#set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_1]
#set_property C_ADV_TRIGGER true [get_debug_cores u_ila_1]
#set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_1]
#set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_1]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
#set_property port_width 1 [get_debug_ports u_ila_1/clk]
#connect_debug_port u_ila_1/clk [get_nets [list genblk1.clk_100M]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
#set_property port_width 8 [get_debug_ports u_ila_1/probe0]
#connect_debug_port u_ila_1/probe0 [get_nets [list {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[0]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[1]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[2]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[3]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[4]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[5]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[6]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_data[7]}]]
#create_debug_port u_ila_1 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
#set_property port_width 8 [get_debug_ports u_ila_1/probe1]
#connect_debug_port u_ila_1/probe1 [get_nets [list {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[0]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[1]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[2]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[3]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[4]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[5]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[6]} {genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_tx_data[7]}]]
#create_debug_port u_ila_1 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
#set_property port_width 1 [get_debug_ports u_ila_1/probe2]
#connect_debug_port u_ila_1/probe2 [get_nets [list genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/full]]
#create_debug_port u_ila_1 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
#set_property port_width 1 [get_debug_ports u_ila_1/probe3]
#connect_debug_port u_ila_1/probe3 [get_nets [list genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/ps2_rx_buf_empty]]
#create_debug_port u_ila_1 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
#set_property port_width 1 [get_debug_ports u_ila_1/probe4]
#connect_debug_port u_ila_1/probe4 [get_nets [list genblk1.mod/mmio_unit/ps2_slot11/ps2_unit/rx_done_tick]]
#set_property C_CLK_INPUT_FREQ_HZ 30000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets genblk1.clk_100M]
