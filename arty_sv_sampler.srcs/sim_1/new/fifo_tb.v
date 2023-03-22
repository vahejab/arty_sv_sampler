`timescale 1ns / 1ps

module fifo_tb;

   // Parameters
   parameter DATA_WIDTH = 8;
   parameter ADDR_WIDTH = 2;
   parameter PS2_MODE = 1;

   // Inputs
   logic clk, reset, rd, wr, rx_done, tx_done;
   logic [ADDR_WIDTH-1:0] w_addr, r_addr;
   logic [DATA_WIDTH-1:0] w_data;

   // Outputs
   logic empty, full, wr_ena;
   logic [DATA_WIDTH-1:0] r_data;

   // Instantiate the DUT
   fifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .PS2_MODE(PS2_MODE)) dut (
      .clk(clk),
      .reset(reset),
      .rd(rd),
      .wr(wr),
      //.w_addr(w_addr),
      //.r_addr(r_addr),
      .w_data(w_data),
      .rx_done(rx_done),
      .tx_done(tx_done),
      .empty(empty),
      .full(full),
      .r_data(r_data)
   );

   // Clock generation
   always #2.5 clk = ~clk;

   // Stimulus
   initial begin
      // Reset
      clk = 0;
      reset = 1;
      #10;
      reset = 0;
      rx_done = 0;
      wr = 0;
      // Test 1: 4-byte read in PS/2 mode
      w_data = 8'h11;
      #137.5 rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      w_data = 8'h22;
      #137.5 rx_done = 1;
      #5 rx_done = 0; 
      #5; 
       w_data = 8'h33;
      #137.5 rx_done = 1;
      #5 rx_done = 0; 
      #5; 
       w_data = 8'h44;
      #137.5 rx_done = 1; 
      #5 rx_done = 0; 
      #5; 
      #2.5 wr = 1; rd = 1;
      #5/*r_addr = 0;*/   if (r_data != 8'h11) $display("Test 1 failed");
      #5 /*r_addr = 1;*/  if (r_data != 8'h22) $display("Test 2 failed");
      #5 /*r_addr = 2;*/  if (r_data != 8'h33) $display("Test 3 failed");
      #5 /*r_addr = 3;*/  if (r_data != 8'h44) $display("Test 4 failed");
       
      #5 rd = 0; wr = 0;
     
      // Test 2: 3-byte read in PS/2 mode

      w_data = 8'h55;
      #137.5  rx_done = 1;
      #5 rx_done = 0; 
      #5
      w_data = 8'h66;
      #137.5  rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      w_data = 8'h77;
      #137.5  rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      tx_done = 1;
      #5 rx_done = 0; #5   tx_done = 0;
      #2.5 rd = 1; wr = 1;
      #5 /*r_addr = 4;*/  if (r_data != 8'h55) $display("Test 2 failed");
      #5 /*r_addr = 5;*/  if (r_data != 8'h66) $display("Test 3 failed");
      #5 /*r_addr = 6;*/  if (r_data != 8'h77) $display("Test 4 failed");

      #5 rd = 0; wr = 0;

      // Test 3: 2-byte read in non-PS/2 mode
      w_data = 8'h88;
      #137.5  rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      w_data = 8'h99;
      #137.5  rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      tx_done = 1;
      #5 rx_done = 0; #5 tx_done = 0;
      #2.5 rd = 1; wr = 1;
      #5 /*r_addr = 7;*/  if (r_data != 8'h88) $display("Test 5 failed");
      #5 /*r_addr = 8;*/  if (r_data != 8'h99) $display("Test 6 failed");
      #5 rd = 0; wr = 0;

      // Test 4: 1-byte read in non-PS/2 mode

      w_data = 8'hAA;
      #137.5  rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      tx_done = 1;
      #5 rx_done = 0; #5 tx_done = 0;
      #5 rd = 1; wr = 1;
      #5 if (r_data !== 8'hAA) $display("Test 7 failed");
      #5 rd = 0; wr = 0;
      
      
      // Test 5: 4-byte read in PS/2 mode
      w_data = 8'h11;
      #137.5 rx_done = 1;
      #5 rx_done = 0; 
      #5; 
      w_data = 8'h22;
      #137.5 rx_done = 1;
      #5 rx_done = 0; 
      #5; 
       w_data = 8'h33;
      #137.5 rx_done = 1;
      #5 rx_done = 0; 
      #5; 
       w_data = 8'h44;
      #137.5 rx_done = 1; 
      #5 rx_done = 0; 
      tx_done = 1;
      #5 rx_done = 0; #5 tx_done = 0;
      #2.5 rd = 1; wr = 1;
      #5/*r_addr = 0;*/   if (r_data != 8'h11) $display("Test 1 failed");
      #5 /*r_addr = 1;*/  if (r_data != 8'h22) $display("Test 2 failed");
      #5 /*r_addr = 2;*/  if (r_data != 8'h33) $display("Test 3 failed");
      #5 /*r_addr = 3;*/  if (r_data != 8'h44) $display("Test 4 failed");
       
      #5 rd = 0; wr = 0;
      
      #5 $finish;
   end
endmodule