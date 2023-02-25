FPGA - GPU
===============

This project is a SystemVerilog module designed to work on the VC707 FPGA Board and will operate as a 3D Graphics Acceleration Unit. It currently sends mouse movement to a PC over UART.

Hardware Components
-------------------

This project requires the following hardware components:

*   [VC707 FPGA board](https://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html)
*   [Digilent FMC-CE adapter](https://store.digilentinc.com/fmc-ce-adapter-breaks-out-fmc-connectors-for-easier-access/)
*   [Digilent PMOD-BB](https://store.digilentinc.com/pmod-breadboard-adapter/)
*   [PCA9306 level-shifter](https://www.ti.com/product/PCA9306)
*   [Kensington Expert Mouse](https://us.kensington.com/products/input-devices/trackballs/expert-mouse-wired-trackball)
*   [PS/2 mouse 4-byte packet protocol](https://isdaman.com/alsos/hardware/mouse/ps2interface.htm)

Design Hierarchy
-------------------

<ul>
    <li>📄 <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sim_1/new/top.v">top.v</a> (1)
    <ul>
        <li>📄 <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/arty_supplement/mcs_top_sampler_arty_a7.sv">mcs_top_sampler_a7.sv</a> (3)
        <ul>
            <li>📄 cpu_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/cpu/cpu.v">cpu.v</a></li>
            <li>📄 b_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/chu/chu_mcs_bridge.sv">chu_mcs_bridge.sv</a></li>
            <li>📄 mmio_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/arty_supplement/mmio_sys_sampler_arty_a7.sv">mmio_sys_sampler_arty_a7.sv</a> (4)
            <ul>
                <li>📄 b_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/chu/chu_mmio_controller.sv">chu_mmio_controller.sv</a></li>
                <li>📄 ctrl_unit : chu_mmio_controller (chu_mmio_controller.sv)</li>
                <li>📄 uart_slotl : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/chu/chu_uart.sv">chu_uart.sv</a> (1)
                    <ul>
                        <li>📄 uart_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/uart/uart.sv">uart.sv</a> (5)
                            <ul>
                                <li>📄 baud_gen_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/uart/baud_gen.sv">baud_gen.sv</a></li>
                                <li>📄 uart_rx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/uart/uart_rx.sv">uart_rx.sv</a></li>
                                <li>📄 uart_tx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/uart/uart_tx.sv">uart_tx.sv</a></li>
                                <ul>
                                    <li>📄 fifo_rx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/imports/fifo.sv">fifo.sv</a></li>
                                    <ul>
                                        <li>📄 c_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/imports/fifo_ctrl.sv">fifo_ctrl.sv</a> </li>
                                        <li>📄 f_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/imports/reg_file.sv">reg_file.sv</a> </li>
                                    </ul>
                                </ul>
                            </ul>
                          </li>
                    </ul>
                </li>
                <li>📄 ps2_slot2 : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/ps2/chu_ps2_core.sv">chu_ps2_core (chu_ps2_core.sv)</a> (1)
                    <ul>
                        <li>📄 ps2_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/ps2/ps2_top.sv">ps2_top (ps2_top.sv)</a> (3)
                            <ul>
                                <li>📄 ps2_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/ps2/ps2tx.sv">ps2tx (ps2tx.sv)</a></li>
                                <li>📄 ps2_rx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/ps2/ps2rx.sv">ps2rx (ps2rx.sv)</a></li>
                            </ul>
                        </li>
                        <li> 📄 fifo_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/fifo/fifo.sv">fifo (fifo.sv)</a> (2)
                            <ul>
                                <li>📄 c_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/fifo/fifo_ctrl.sv">fifo_ctrl (fifo_ctrl.sv)</a></li>
                                <li>📄 f unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/fifo/reg_file.sv">reg_file (reg_file.sv)</a></li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </ul>
        </li>
    </ul>
</ul>
              

Additional Information
----------------------

For additional information on the PS/2 mouse 4-byte packet protocol, please refer to the following link: [https://isdaman.com/alsos/hardware/mouse/ps2interface.htm](https://isdaman.com/alsos/hardware/mouse/ps2interface.htm)

For information on how to physically connect the components, please refer to the respective datasheets of the components and the reference manual of the Arty FPGA board.

Sure, here is the revised README with the directory hierarchy, 4 byte packet information for PS/2 mouse, and the C++ files:

FPGA - GPU
===============

This project will be a SystemVerilog implementation of a GPU on a VC707 Evaluation Board

Initialization Protocol
-----------------------

To initialize a PS/2 mouse, the following steps are typically taken:

1.  Send a reset command to the mouse by sending 0xFF to the mouse.
2.  Wait for the mouse to send an acknowledge byte (0xFA).
3.  Send a request for the mouse to send its status byte and the first byte of data by sending 0xEB to the mouse.
4.  Wait for the mouse to send an acknowledge byte (0xFA).
5.  Wait for the mouse to send its status byte.
6.  Wait for the mouse to send its first data byte.

4 Byte Packet Information
-------------------------
<table>
	<thead>
		<tr>
			<th>Byte</th>
			<th>Bit 7</th>
			<th>Bit 6</th>
			<th>Bit 5</th>
			<th>Bit 4</th>
			<th>Bit 3</th>
			<th>Bit 2</th>
			<th>Bit 1</th>
			<th>Bit 0</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>1</td>
			<td>YO</td>
			<td>XO</td>
			<td>YS</td>
			<td>XS</td>
			<td>1</td>
			<td>M</td>
			<td>R</td>
			<td>L</td>
		</tr>
		<tr>
			<td>2</td>
			<td>X7</td>
			<td>X6</td>
			<td>X5</td>
			<td>X4</td>
			<td>X3</td>
			<td>X2</td>
			<td>X1</td>
			<td>X0</td>
		</tr>
		<tr>
			<td>3</td>
			<td>Y7</td>
			<td>Y6</td>
			<td>Y5</td>
			<td>Y4</td>
			<td>Y3</td>
			<td>Y2</td>
			<td>Y1</td>
			<td>Y0</td>
		</tr>
		<tr>
			<td>4</td>
			<td>0</td>
			<td>0</td>
			<td>0</td>
			<td>0</td>
			<td>ZS</td>
			<td>ZO</td>
			<td>YO</td>
			<td>XO</td>
		</tr>
	</tbody>
</table>
