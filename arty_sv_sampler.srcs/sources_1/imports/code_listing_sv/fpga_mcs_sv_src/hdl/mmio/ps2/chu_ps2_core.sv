(* keep_hierarchy = "yes" *)
module chu_ps2_core
   #(parameter W_SIZE = 6)   // # address bits in FIFO buffer
   (
      (* dont_touch = "true" *)input  logic clk,
      (* dont_touch = "true" *)input  logic reset,
    // slot interface
      (* dont_touch = "true" *)input  logic cs,
      (* dont_touch = "true" *)input  logic read,
      (* dont_touch = "true" *)input  logic write,
      (* dont_touch = "true" *)input  logic [W_SIZE-1:0] addr,
      (* dont_touch = "true" *)input  logic [31:0] wr_data,
      (* dont_touch = "true" *)output logic [31:0] rd_data,
      (* dont_touch = "true" *)output logic tri_c, tri_d, ps2c_out, ps2d_out,
      
    // external ports    
      (* dont_touch = "true" *)input wire ps2d_in,
      (* dont_touch = "true" *)input wire ps2c_in
   );

   // declaration
   logic [7:0] ps2_rx_data;
   logic rd_fifo, ps2_rx_buf_empty, ps2_rx_empty_reg;
   logic wr_ps2, ps2_tx_idle;
   logic ps2_rx_idle;

   // body
   // instantiate PS2 controller   
   ps2_top #(.W_SIZE(W_SIZE)) ps2_unit
      (.clk(clk), 
       .reset(reset), 
       .wr_ps2(wr_ps2), 
       .rd_ps2_packet(rd_fifo), 
       .ps2_tx_data(wr_data[7:0]), 
       .ps2_rx_data(ps2_rx_data), 
       .ps2_tx_idle(ps2_tx_idle),
       .ps2_rx_idle(ps2_rx_idle), 
       .ps2_rx_buf_empty(ps2_rx_buf_empty),
       .ps2d_in(ps2d_in), 
       .ps2c_in(ps2c_in), 
       .tri_c(tri_c), 
       .tri_d(tri_d), 
       .ps2c_out(ps2c_out), 
       .ps2d_out(ps2d_out)
   ); 

   // decoding and read multiplexing
   // remove an item from FIFO  
   assign rd_fifo = cs & read & (addr[1:0]==2'b11);
   // write data to PS2 transmitting subsystem  
   assign wr_ps2 = cs & write & (addr[1:0]==2'b10);
   //  read data multiplexing
   /*always @(posedge clk)
   begin
       if (read)
         rd_data <= {22'b0, ps2_tx_idle, ps2_rx_buf_empty, ((!ps2_rx_buf_empty)? ps2_rx_data: 8'b0)}; 
   end*/
   assign rd_data = {22'b0, ps2_tx_idle, ps2_rx_buf_empty, ps2_rx_data};
endmodule  