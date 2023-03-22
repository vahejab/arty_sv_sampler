module reg_file #(parameter DATA_WIDTH = 8,
                  parameter ADDR_WIDTH = 2,
                  parameter PS2_MODE = 0)
                (input  logic           clk,
                 input  logic           reset,
                 input  logic           wr_en,
                 input  logic           rd,
                 input  logic           rx_done,
                 input  logic           tx_done,
                 output logic           enable_write,
                 input  logic [ADDR_WIDTH-1:0]  w_addr,
                 input  logic [ADDR_WIDTH-1:0]  r_addr,
                 input  logic [DATA_WIDTH-1:0]  w_data,
                 output logic [DATA_WIDTH-1:0]  r_data);
   
   reg rd_en;
   reg [ADDR_WIDTH-1:0] r_addr_reg, r_addr_reg2;
   reg [DATA_WIDTH-1:0] r_data_reg;
   reg done;
   // signal declaration
   logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

   // buffer shift register and state variable
   reg [DATA_WIDTH*4-1:0] buffer_reg;
   reg [ADDR_WIDTH*4-1:0] addr_reg;
   reg [2:0] buffer_count = 0;
   reg [ADDR_WIDTH-1:0] addr = 0;

   // write operation
   always_ff @(posedge clk)
   begin  
      if (PS2_MODE == 3)
      begin
         if ((buffer_count <= 3) && rx_done)
         begin
            buffer_reg <= {buffer_reg[DATA_WIDTH*3-1:0], w_data};
            //addr_reg <= {addr_reg[ADDR_WIDTH*3-1:0], addr};
            //addr <= addr + 1;
            buffer_count <= buffer_count + 1;
            //wr_ena <= 0;   
            //done <= 0;  
            
         end
         else if (buffer_count == 1 && wr_en)
         begin
            array_reg[/*addr_reg[1*ADDR_WIDTH-1:0*ADDR_WIDTH]*/w_addr] <= buffer_reg[1*DATA_WIDTH-1:0*DATA_WIDTH];
            buffer_count <= buffer_count - 1;
            done <= 0;
            addr <= 0;
         end
         else if (buffer_count == 2 && wr_en)
         begin
            array_reg[/*addr_reg[2*ADDR_WIDTH-1:1*ADDR_WIDTH]*/w_addr] <= buffer_reg[2*DATA_WIDTH-1:1*DATA_WIDTH];
            buffer_count <= buffer_count - 1;
         
            done <= 1;
            addr <= 0;
         end
         else if (buffer_count == 3 && wr_en)
         begin
            array_reg[/*addr_reg[3*ADDR_WIDTH-1:2*ADDR_WIDTH]*/w_addr] <= buffer_reg[3*DATA_WIDTH-1:2*DATA_WIDTH];
            buffer_count <= buffer_count - 1;
     
            done <= 1;
            addr <= 0;
         end
         else if (buffer_count == 4 && wr_en)
         begin
            array_reg[/*addr_reg[4*ADDR_WIDTH-1:3*ADDR_WIDTH]*/w_addr] <= buffer_reg[4*DATA_WIDTH-1:3*DATA_WIDTH];
            buffer_count <= buffer_count - 1;
           
            done <= 1;
            addr <= 0;
         end
      end
      else if (wr_en)
      begin
         array_reg[w_addr] <= w_data;
      end
      //if (rd)
      //  r_data <= array_reg[r_addr];
   end
   assign enable_write = (buffer_count == 4 || done) || (buffer_count >= 1 && tx_done);
   assign r_data = array_reg[r_addr];
   
endmodule