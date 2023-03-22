// Listing 7.8
module fifo
   #(
    parameter DATA_WIDTH=8, // number of bits in a word
              ADDR_WIDTH=4,  // number of address bits
              PS2_MODE=0
   )
   (
    input  logic clk, reset,
    input  logic rd, wr,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic empty, full,
    output logic [DATA_WIDTH-1:0] r_data,
    input  logic rx_done,
    input  logic tx_done
   );

   //signal declaration
   logic [ADDR_WIDTH-1:0] w_addr, r_addr;
   wire enable_write;
   reg full_tmp;
   wire wr_fifo;
   wire write;

   // body
   // write enabled only when FIFO is not full
   assign write = wr & ~full_tmp;//((wr & ~full_tmp) & !PS2_MODE) || (enable_write);
   assign full = full_tmp;

   // instantiate fifo control unit
   fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
      (.*, .wr(write), .full(full_tmp));

   // instantiate register file
   reg_file 
      #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .PS2_MODE(PS2_MODE)) f_unit (.*, .wr_en(write), .rx_done(rx_done), .tx_done(tx_done), .enable_write(enable_write));
endmodule

