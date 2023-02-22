module fifo_ctrl
#(   
   parameter ADDR_WIDTH = 4,
   parameter PS2_MODE = 0, // set to 1 to use PS/2 mode with synchronized wr signal
   parameter REGION_SIZE = 2 ** (ADDR_WIDTH - 1) // size of each region
)
(
   input logic clk, reset,
   input logic rd, wr,
   output logic empty, full,
   output logic [ADDR_WIDTH-1:0] w_addr,
   output logic [ADDR_WIDTH-1:0] r_addr
);

    // signal declaration
    logic [ADDR_WIDTH-1:0] w_ptr_logic, w_ptr_next, w_ptr_succ;
    logic [ADDR_WIDTH-1:0] r_ptr_logic, r_ptr_next, r_ptr_succ;
    reg [ADDR_WIDTH-1:0] wr_region = 0;
    reg [ADDR_WIDTH-1:0] rd_region = 0;
    logic full_logic, empty_logic, full_next, empty_next;
    
    // synchronization signals
    logic rd_sync, wr_sync, wr_sync2;
    logic read, write;
    
    // Gray code conversion
    logic [ADDR_WIDTH-1:0] w_ptr_gray;
    logic [ADDR_WIDTH-1:0] r_ptr_gray;
    
    always_comb begin
        w_ptr_gray[ADDR_WIDTH-1] = w_ptr_logic[ADDR_WIDTH-1];
        for (int i = ADDR_WIDTH-2; i >= 0; i--) begin
            w_ptr_gray[i] = w_ptr_logic[i+1] ^ w_ptr_logic[i];
        end
        r_ptr_gray[ADDR_WIDTH-1] = r_ptr_logic[ADDR_WIDTH-1];
        for (int i = ADDR_WIDTH-2; i >= 0; i--) begin
            r_ptr_gray[i] = r_ptr_logic[i+1] ^ r_ptr_logic[i];
        end
    end
    
    // synchronization
    always @(posedge clk) begin
       if (PS2_MODE) begin
          rd_sync <= rd; // add 1 cycle delay for read in PS/2 mode
          wr_sync <= wr_sync2;  //wr_sync now asserts for 1 cc, no more than that
          wr_sync2 <= wr;
       end
    end
    assign read = (PS2_MODE)? rd_sync : rd;
    assign write = (PS2_MODE)? wr_sync : wr;
    
    // fifo control logic
    // registers for status and read and write pointers
    always_ff @(posedge clk) begin
        if (reset) begin
          w_ptr_logic <= 0;
          r_ptr_logic <= 0;
          full_logic <= 1'b0;
          empty_logic <= 1'b1;
        end else begin
          w_ptr_logic <= w_ptr_next;
          r_ptr_logic <= r_ptr_next;
          full_logic <= full_next;
          empty_logic <= empty_next;
        end
    end
    
    // next-state logic for read and write pointers
    always_comb begin
      if (PS2_MODE)// Gray code successor values with wraparound
          for (int i = 0; i < ADDR_WIDTH; i++) begin
            w_ptr_succ[i] = w_ptr_logic[i] ^ (write & (w_ptr_gray[i] ^ w_ptr_gray[(i+1)%ADDR_WIDTH]));
            r_ptr_succ[i] = r_ptr_logic[i] ^ (read & (r_ptr_gray[i] ^ r_ptr_gray[(i+1)%ADDR_WIDTH]));
          end
      else begin
          // successive pointer values
          w_ptr_succ = w_ptr_logic + 1;
          r_ptr_succ = r_ptr_logic + 1;
      end
      
      // default: keep old values
      w_ptr_next = w_ptr_logic;
      r_ptr_next = r_ptr_logic;
      full_next = full_logic;
      empty_next = empty_logic;
      
      unique case ({write, read})
        2'b01: // read
        if (~empty_logic) begin // not empty
          if (PS2_MODE && r_ptr_gray == (rd_region + REGION_SIZE - 1)) begin
            rd_region = rd_region + REGION_SIZE;
            r_ptr_next = rd_region;
          end else begin
            r_ptr_next = r_ptr_succ;
          end
          full_next = 1'b0;
          if (r_ptr_succ == w_ptr_logic/* && w_addr == r_addr*/) begin
            empty_next = 1'b1;
          end
        end
        2'b10: // write
        if (~full_logic) begin // not full
          if (PS2_MODE && w_ptr_gray == (wr_region + REGION_SIZE - 1)) begin
            wr_region = wr_region + REGION_SIZE;
            w_ptr_next = wr_region;
          end else begin
            w_ptr_next = w_ptr_succ;
          end
          empty_next = 1'b0;
          if (w_ptr_succ == r_ptr_logic/* && w_addr == r_addr*/) begin
            full_next = 1'b1;
          end
        end
        2'b11: // write and read
        begin
          w_ptr_next = w_ptr_succ;
          r_ptr_next = r_ptr_succ;
        end
        default: ; // 2'b00; null statement; no op
     endcase
   end
   
   // output
   assign w_addr = w_ptr_logic;
   assign r_addr = r_ptr_logic;
  
   assign full = full_logic;
   assign empty = empty_logic;
endmodule

