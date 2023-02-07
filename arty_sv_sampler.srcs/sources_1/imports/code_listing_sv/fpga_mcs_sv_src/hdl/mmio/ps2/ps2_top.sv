(* keep_hierarchy = "yes" *)
module ps2_top
   #(parameter W_SIZE = 6)   // # address bits in FIFO buffer
   (
      (* dont_touch = "true" *) input  logic clk, reset,
      (* dont_touch = "true" *)input  logic wr_ps2, rd_ps2_packet,
      (* dont_touch = "true" *)input  logic [7:0] ps2_tx_data,
      (* dont_touch = "true" *)output logic [7:0] ps2_rx_data,
      (* dont_touch = "true" *)output logic ps2_tx_idle,
      (* dont_touch = "true" *)output logic ps2_rx_idle,
      (* dont_touch = "true" *)output logic ps2_rx_buf_empty,
      (* dont_touch = "true" *)output logic tri_c,
      (* dont_touch = "true" *)output logic tri_d,
      (* dont_touch = "true" *)output logic ps2c_out,
      (* dont_touch = "true" *)output logic ps2d_out,
      (* dont_touch = "true" *)output logic rx_done_tick,
      (* dont_touch = "true" *)input  wire ps2d_in,
      (* dont_touch = "true" *)input  wire ps2c_in
   );

   // declaration
   logic rx_idle, tx_idle;
   logic [7:0] rx_data;
   logic full;
   // body
   // instantiate ps2 transmitter
   ps2tx ps2_tx_unit
      (.clk(clk), 
       .reset(reset), 
       .wr_ps2(wr_ps2), 
       .rx_idle(rx_idle),
       .din(ps2_tx_data), 
       .tx_idle(tx_idle), 
       .tx_done_tick(), 
       .ps2d_in(ps2d_in), 
       .ps2c_in(ps2c_in),
       .tri_c(tri_c),
       .tri_d(tri_d), 
       .ps2c_out(ps2c_out), 
       .ps2d_out(ps2d_out)
      );
   // instantiate ps2 receiver
   ps2rx ps2_rx_unit
      (.clk(clk), 
      .reset(reset), 
      .ps2d_in(ps2d_in), 
      .ps2c_in(ps2c_in), 
      .rx_en(tx_idle), 
      .rx_idle(rx_idle), 
      .rx_done_tick(rx_done_tick), 
      .dout(rx_data)
      );

   /* ila_0 ila (
        .clk(clk),
        .probe0(rd_ps2_packet), //rd
        .probe1(ps2_rx_data), //read
        .probe2(rx_done_tick),//wr
        .probe3(rx_data),  //write
        .probe4(ps2_rx_buf_empty), //empty
        .probe5(full) //full
    );*/

   // instantiate FIFO buffer
   fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(W_SIZE)) fifo_unit
      (.clk(clk), .reset(reset), .rd(rd_ps2_packet),
       .wr(rx_done_tick), .w_data(rx_data), .empty(ps2_rx_buf_empty),
       .full(full), .r_data(ps2_rx_data));
   //output 
   assign ps2_tx_idle = tx_idle;
   assign psr_rx_idle = rx_idle;
endmodule