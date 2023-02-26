<h1 align="center">
  FPGA - GPU
</h1>
<h4 align="center">This project is a SystemVerilog module designed to work on the VC707 FPGA Board and will operate as a 3D Graphics Acceleration Unit. It currently sends mouse movement to a PC over UART.</h4>
<p align="center">
  <a href="#hardware-components">Hardware Components</a> •
  <a href="#design-hierarchy">Design Hierarchy</a> •
  <a href="#file-descriptions">File Descriptions</a> •
  <a href="#additional-information">Additional Information</a>
</p>


This project is a SystemVerilog module designed to work on the VC707 FPGA Board and will operate as a 3D Graphics Acceleration Unit. It currently sends mouse movement to a PC over UART.

Hardware Components
-------------------

This project uses the following hardware components:

<ul>
   <li><a href="https://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html" target="_new">VC707 FPGA board</a></li>
   <li><a href="https://digilent.com/reference/fmc_ce_card/fmc_ce_card/" target="_new">Digilent FMC-CE adapter</a></li>
   <li><a href="https://digilent.com/reference/pmod/pmodbb/" target="_new">Digilent PMOD-BB</a></li>
   <li><a href="https://www.sparkfun.com/products/15439" target="_new">SparkFun PCA9306 level-shifter</a></li>
   <li><a href="https://www.kensington.com/p/products/electronic-control-solutions/trackball-products/expert-mouse-wired-trackball/" target="_new">Kensington Expert Mouse</a></li>
</ul>

Design Hierarchy
-------------------

<ul>
    <li>📄 <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sim_1/imports/new/top.v">top.v</a> (1)
    <ul>
		<li>📄 <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/arty_supplement/mcs_top_sampler_arty_a7.sv">mcs_top_sampler_arty_a7.sv</a> (3)
		<ul>
		    <li>📄 cpu_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/cpu/cpu.v">cpu.v</a></li>
		    <li>📄 b_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/sys/bridge/chu_mcs_bridge.sv">chu_mcs_bridge.sv</a></li>
		    <li>📄 mmio_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/arty_supplement/mmio_sys_sampler_arty_a7.sv">mmio_sys_sampler_arty_a7.sv</a> (4)
		    <ul>
			<li>📄 ctrl_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/chu_mmio_controller.sv">chu_mmio_controller.sv</a></li>
			<li>📄 uart_slotl : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/uart/chu_uart.sv">chu_uart.sv</a> (3)
			    <ul>
				<li>📄 uart_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/uart/mmio/uart.sv">uart.sv</a> (3)
				    <ul>
					<li>📄 baud_gen_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/uart/baud_gen.sv">baud_gen.sv</a></li>
					<li>📄 uart_rx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/uart/uart_rx.sv">uart_rx.sv</a></li>
					<li>📄 uart_tx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/uart/uart_tx.sv">uart_tx.sv</a></li>
					<ul>
					    <li>📄 fifo_rx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/fifo/fifo_ctrl.sv">fifo.sv</a></li>
					    <ul>
						<li>📄 c_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/mainarty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/fifo/fifo_ctrl.sv">fifo_ctrl.sv</a> </li>
						<li>📄 f_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/mmio_support/fifo/reg_file.sv">reg_file.sv</a> </li>
					    </ul>
					</ul>
				    </ul>
				  </li>
			    </ul>
			</li>
			<li>📄 ps2_slot2 : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/ps2/chu_ps2_core.sv">chu_ps2_core (chu_ps2_core.sv)</a> (2)
			    <ul>
				<li>📄 ps2_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/ps2/ps2_top.sv">ps2_top (ps2_top.sv)</a> (2)
				    <ul>
					<li>📄 ps2_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/ps2/ps2tx.sv">ps2tx (ps2tx.sv)</a></li>
					<li>📄 ps2_rx_unit : <a href="https://github.com/vahejab/arty_sv_sampler/blob/main/arty_sv_sampler.srcs/sources_1/imports/code_listing_sv/fpga_mcs_sv_src/hdl/mmio/ps2/ps2rx.sv">ps2rx (ps2rx.sv)</a></li>
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
</ul>

File Descriptions
-------------------

<table>
   <thead>
      <tr>
         <th>File name</th>
         <th>Description</th>
      </tr>
   </thead>
   <tbody>
      <tr>
         <td>top.v</td>
         <td>The top-level Verilog file for the design, which instantiates the CPU, MMIO, UART, and PS/2 modules.</td>
      </tr>
      <tr>
         <td>cpu.v</td>
         <td>The Verilog source file for the CPU, which contains the top-level logic for the design.</td>
      </tr>
      <tr>
         <td>chu_mcs_bridge.sv</td>
         <td>The Verilog source file for the memory controller subsystem (MCS) bridge module, which provides a bridge between the CPU and the memory controller subsystem.</td>
      </tr>
      <tr>
         <td>chu_mmio_controller.sv</td>
         <td>The Verilog source file for the memory-mapped I/O (MMIO) controller, which provides an interface for controlling and communicating with peripheral devices.</td>
      </tr>
      <tr>
         <td>mmio_sys_sampler_arty_a7.sv</td>
         <td>The Verilog source file for the system sampler, which is a memory-mapped peripheral that provides an interface for sampling data from an ADC.</td>
      </tr>
      <tr>
         <td>chu_uart.sv</td>
         <td>The Verilog source file for the Universal Asynchronous Receiver/Transmitter (UART) slot logic, which handles the data communication over a serial interface.</td>
      </tr>
      <tr>
         <td>uart.sv</td>
         <td>The Verilog source file for the UART unit, which provides an interface for transmitting and receiving data over a serial connection.</td>
      </tr>
      <tr>
         <td>baud_gen.sv</td>
         <td>The Verilog source file for the baud rate generator unit, which generates the correct baud rate for the UART interface.</td>
      </tr>
      <tr>
         <td>uart_rx.sv</td>
         <td>The Verilog source file for the UART receiver unit, which receives data over a serial interface.</td>
      </tr>
      <tr>
         <td>uart_tx.sv</td>
         <td>The Verilog source file for the UART transmitter unit, which transmits data over a serial interface.</td>
      </tr>
      <tr>
         <td>fifo.sv</td>
         <td>The Verilog source file for the First-In-First-Out (FIFO) unit, which stores data in a buffer.</td>
      </tr>
      <tr>
         <td>fifo_ctrl.sv</td>
         <td>The Verilog source file for the FIFO control unit, which manages the read and write operations to the FIFO.</td>
      </tr>
      <tr>
         <td>reg_file.sv</td>
         <td>The Verilog source file for the register file unit, which stores the status of the peripheral devices.</td>
      </tr>
      <tr>
         <td>chu_ps2_core.sv</td>
         <td>The Verilog source file for the PS/2 slot logic, which handles the communication over a PS/2 interface.</td>
      </tr>
      <tr>
         <td>ps2_top.sv</td>
         <td>The Verilog source file for the PS/2 unit, which provides an interface for communicating with a PS/2 device.</td>
      </tr>
      <tr>
         <td>ps2tx.sv</td>
         <td>The Verilog source file for the PS/2 transmitter unit, which transmits data over a PS/2 interface.</td>
      </tr>
      <tr>
         <td>ps2rx.sv</td>
         <td>The Verilog source file for the PS/2 receiver unit, which receives data over a PS/2 interface.</td>
      </tr>
   </tbody>
</table>
              

Additional Information
----------------------

For additional information on the PS/2 mouse 4-byte packet protocol, please refer to the following link: [https://isdaman.com/alsos/hardware/mouse/ps2interface.htm](https://isdaman.com/alsos/hardware/mouse/ps2interface.htm)

For information on how to physically connect the components, please refer to the respective datasheets of the components and the reference manual of the Arty FPGA board.


Mouse Initialization Protocol
-----------------------

To initialize a PS/2 mouse, the following steps are typically taken:

1.  Send a reset command to the mouse by sending 0xFF to the mouse.
2.  Wait for the mouse to send an acknowledge byte (0xFA).
3.  Send a series of commands to prepare to initialize mouse
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
