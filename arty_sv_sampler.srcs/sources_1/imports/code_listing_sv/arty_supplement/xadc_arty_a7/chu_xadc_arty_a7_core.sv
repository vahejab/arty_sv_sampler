
//*********************************************************************
//file: chu_xadc_arty_a7_core.vhd - xadc core with 16 aux channels 
//Copyright (C) 2017  p. chu
//
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <https://www.gnu.org/licenses/>.
//*********************************************************************


//*********************************************************************
// Xilinx xadc interface:
//  * xadc in sequence mode
//  * DRP interface is connected to atomtically read
//    out the pres-designated channels
//  * the readout is stored into corresponding register
//*********************************************************************
// arty board configuration
//  * vp/vn channel
//  * 13 aux channels:
//      * 6 single-ended channels
//      * 3 differential channels
//      * 4 on-board voltage/current channels
//  * the design enables all 16 aux channels and 
//    * 16 aux reading in a register file
//    * vp/temp/vcc in three registers 
// *********************************************************************
//  * channel mapping (arty signal: aux)
//    * single-ended channels (max=3V via voltage divider)
//      * a0: 4
//      * a1: 5
//      * a2: 6
//      * a3: 7
//      * a4: 15
//      * a5: 0
//    * differential channels  (max=1V)
//      * a6/a7: 12 (diff)
//      * a8/a9: 13 (diff)
//      * a10/a11: 14 (diff)
//    * on-board v-i channel
//      * iv0 (core current): 10 (max=1V)
//          * shunt register = 10m ohm; amp gain = 50 
//          * 1A(0.5V
//      * iv1 (unregulated voltage): 2 (max=16V via volatge divider)
//          * voltage of external power jack (usually not connected) 
//      * iv2 (5V power supply voltage): 1 (max=5.99V via voltage divider) 
//      * iv3 (5V power supply current): 9 
//          * shunt register = 5m ohm; amp gain = 50 
//          * 1A(0.25V
//    * software driver must do the conversion  
//*********************************************************************
//  * channel mapping (aux: arty signal)
//    * 0:a5   1:iv2  2:iv1    3:n/a  4:a0     5:a1     6:a2       7:a3
//    * 8:n/a  9:iv3  10:iv0  11:n/a 12:a6/a7 13:a8/a9 14:a10/a11 15:a4   
//*********************************************************************
//*********************************************************************
//  * xadc internal reg address space (5 bits) 
//    * 0xxxx: internal measurements and vp/vn
//    * 1xxxx: 16 aux analog readings    
//*********************************************************************
//*********************************************************************
//  * xadc_arty_core MMIO reg map 
//    * 1xxxx: 16 aux analog readings    
//    * 00000: FPGA die temperature
//    * 00001: FPGA core voltage 
//    * 00011: vp/vn
//*********************************************************************
module chu_xadc_arty_a7_core
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external signals 
    input  logic vp_in, vn_in,
    input  logic [8:0] adc_a_p, adc_a_n,  // 9 analog channels
    input  logic [3:0] adc_iv_p, adc_iv_n // 4 i-v channels
   );

   // signal declaration
   logic [4:0] channel;
   logic [6:0] daddr_in;
   logic eoc;
   logic rdy;
   logic wr_fifo;
   logic [15:0] fifo_readout;
   logic [15:0] adc_data, tmp_out_reg, vcc_out_reg, vpn_out_reg;
   
   // instantiate xadc
   xadc_arty_fpro xadc_unit (
      .dclk_in(clk),         // input logic dclk_in
      .reset_in(reset),      // input logic reset_in
      .di_in(16'h0000),      // input logic [15 : 0] di_in
      .daddr_in(daddr_in),   // input logic [6 : 0] daddr_in
      .den_in(eoc),          // input logic den_in
      .dwe_in(1'b0),         // input logic dwe_in
      .drdy_out(rdy),        // output logic drdy_out
      .do_out(adc_data),     // output logic [15 : 0] do_out
      .channel_out(channel), // output logic [4 : 0] channel_out
      .eoc_out(eoc),         // output logic eoc_out
      .alarm_out(),          // output logic alarm_out
      .eos_out(),            // output logic eos_out
      .busy_out(),            // output logic busy_out
      .ot_out(),
      .user_temp_alarm_out(),
      .vp_in(vp_in), 
      .vn_in(vn_in), 
      .vauxp0(adc_a_p[5]), 
      .vauxn0(adc_a_n[5]),
      .vauxp1(adc_iv_p[2]),
      .vauxn1(adc_iv_n[2]),
      .vauxp2(adc_iv_p[1]),
      .vauxn2(adc_iv_n[1]),
      .vauxp3(1'b0),
      .vauxn3(1'b0),
      .vauxp4(adc_a_p[0]),
      .vauxn4(adc_a_n[0]),
      .vauxp5(adc_a_p[1]),
      .vauxn5(adc_a_n[1]),
      .vauxp6(adc_a_p[2]),
      .vauxn6(adc_a_n[2]),
      .vauxp7(adc_a_p[3]),
      .vauxn7(adc_a_n[3]),
      .vauxp8(1'b0),
      .vauxn8(1'b0),
      .vauxp9(adc_iv_p[3]),
      .vauxn9(adc_iv_n[3]),
      .vauxp10(adc_iv_p[0]),
      .vauxn10(adc_iv_n[0]),
      .vauxp11(1'b0),
      .vauxn11(1'b0),
      .vauxp12(adc_a_p[6]),
      .vauxn12(adc_a_n[6]),
      .vauxp13(adc_a_p[7]),
      .vauxn13(adc_a_n[7]),
      .vauxp14(adc_a_p[8]),
      .vauxn14(adc_a_n[8]),
      .vauxp15(adc_a_p[4]),
      .vauxn15(adc_a_n[4])
   );

   // form xadc DRP address 
   assign daddr_in = {2'b00, channel};
   
   // register file 
   reg_file #(.DATA_WIDTH(16), .ADDR_WIDTH(4)) f_unit (
      .clk(clk),
      .w_addr(channel[3:0]),
      .w_data(adc_data),
      .r_addr(addr[3:0]),
      .r_data(fifo_readout),
      .wr_en(wr_fifo)
   );

   // aux register addr is "1xxxx" 
   assign wr_fifo = rdy && channel[4];    
 
   // registers and decoding
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         tmp_out_reg <= 16'h0000;
         vcc_out_reg <= 16'h0000;
         vpn_out_reg <= 16'h0000;
      end 
      else begin
         if (rdy && channel == 5'b00000)
            tmp_out_reg <= adc_data;
         if (rdy && channel == 5'b00001)
            vcc_out_reg <= adc_data;
         if (rdy && channel == 5'b00011)
            vpn_out_reg <= adc_data;
     end
    
   // read multiplexing 
   always_comb
      if(addr[4])
         rd_data <= {16'h0000, fifo_readout};
      else if (addr==5'b00000)
         rd_data <= {16'h0000, tmp_out_reg};
      else if (addr==5'b00011)
         rd_data <= {16'h0000, vpn_out_reg};
      else 
         rd_data <= {16'h0000, vcc_out_reg};
endmodule     


