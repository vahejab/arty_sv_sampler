module fifo_ctrl
   #(
   parameter ADDR_WIDTH = 4
   )
   (
   input logic clk, reset,
   input logic rd, wr,
   output logic empty, full,
   output logic [ADDR_WIDTH-1:0] w_addr,
   output logic [ADDR_WIDTH-1:0] r_addr
   );

   logic [ADDR_WIDTH:0] w_addr_ext, r_addr_ext;
   logic wr_inc, rd_inc;
   logic wr_first;
   
   // Write address increment logic
   always_comb begin
      wr_inc = wr & ~full;
   end

   // Read address increment logic
   always_comb begin
      rd_inc = rd & ~empty;
   end

   // Prioritize write when both rd and wr are high
   always_comb begin
      wr_first = wr & rd & empty;
   end
   
   // Write address counter
   always_ff @(posedge clk) begin
      if (reset) begin
         w_addr_ext <= 0;
      end else if (wr_inc) begin
         w_addr_ext <= w_addr_ext + 1;
      end
   end
   
   // Read address counter
   always_ff @(posedge clk) begin
      if (reset) begin
         r_addr_ext <= 0;
      end else if (rd_inc && !wr_first) begin
         r_addr_ext <= r_addr_ext + 1;
      end
   end
   
   // Output write and read addresses
   assign w_addr = w_addr_ext[ADDR_WIDTH-1:0];
   assign r_addr = r_addr_ext[ADDR_WIDTH-1:0];
   
   // Empty and full flags
   always_comb begin
      empty = (w_addr_ext == r_addr_ext);
      full = (w_addr_ext[ADDR_WIDTH] != r_addr_ext[ADDR_WIDTH]) && (w_addr_ext[ADDR_WIDTH-1:0] == r_addr_ext[ADDR_WIDTH-1:0]);
   end

endmodule