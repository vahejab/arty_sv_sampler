// Listing 7.2
module reg_file
   #(
    parameter DATA_WIDTH = 8,  // number of bits
              ADDR_WIDTH = 2,  // number of address bits
              PS2_MODE = 0,   // PS2 Mode for Mouse
              REGION_SIZE = 2 ** (ADDR_WIDTH - 1) // size of each divided region for gray encoded addresable fifo

   )
   (
    input  logic clk,
    input  logic reset,
    input  logic wr_en, rd,
    input  logic [ADDR_WIDTH-1:0] w_addr, r_addr,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data
   );
   
   reg [ADDR_WIDTH-1:0] wr_region = 0;
   reg [ADDR_WIDTH-1:0] rd_region = 0;

   // signal declaration
   logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];
   
   // body
   // write operation
   always_ff @(posedge clk)
   begin
      if (wr_en)
         array_reg[w_addr] <= w_data;
   end
 
    // read operation
   assign r_data = array_reg[r_addr];
      
endmodule