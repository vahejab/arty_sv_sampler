`include "chu_io_map.svh"
module mmio_sys_sampler_arty_a7
#(
  parameter N_SW = 8,
            N_LED = 8
)   
(
     (* dont_touch = "true" *) input  logic clk,
     (* dont_touch = "true" *) input  logic reset,
   // FPro bus 
     (* dont_touch = "true" *) input   logic mmio_cs,
     (* dont_touch = "true" *) input   logic mmio_wr,
     (* dont_touch = "true" *) input   logic mmio_rd,
     (* dont_touch = "true" *) input   logic [20:0] mmio_addr, 
     (* dont_touch = "true" *) input   logic [31:0] mmio_wr_data,
     (* dont_touch = "true" *) output  logic [31:0] mmio_rd_data,
     (* dont_touch = "true" *) output  logic rx_done_pulse,
   // uart
     (* dont_touch = "true" *) input logic rx,
     (* dont_touch = "true" *) output logic tx, 
   // ps2   
     (* dont_touch = "true" *) output logic ps2c_out,
     (* dont_touch = "true" *) output logic ps2d_out,  
     (* dont_touch = "true" *) output logic tri_c,
     (* dont_touch = "true" *) output logic tri_d,
     (* dont_touch = "true" *) input wire ps2c_in,
     (* dont_touch = "true" *) input wire ps2d_in  
);

   //declaration
   logic [63:0] mem_rd_array;
   logic [63:0] mem_wr_array;
   logic [63:0] cs_array;
   logic [4:0] reg_addr_array [63:0];
   logic [31:0] rd_data_array [63:0]; 
   logic [31:0] wr_data_array [63:0];
   logic [15:0] adsr_env;

   // body
   // instantiate mmio controller 
   chu_mmio_controller ctrl_unit
   (.clk(clk),
    .reset(reset),
    .mmio_cs(mmio_cs),
    .mmio_wr(mmio_wr),
    .mmio_rd(mmio_rd),
    .mmio_addr(mmio_addr), 
    .mmio_wr_data(mmio_wr_data),
    .mmio_rd_data(mmio_rd_data),
    // slot interface
    .slot_cs_array(cs_array),
    .slot_mem_rd_array(mem_rd_array),
    .slot_mem_wr_array(mem_wr_array),
    .slot_reg_addr_array(reg_addr_array),
    .slot_rd_data_array(rd_data_array), 
    .slot_wr_data_array(wr_data_array)
    );

   // slot 1: UART 
   chu_uart #(.FIFO_DEPTH_BIT(8))  uart_slot1
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S1_UART]),
    .read(mem_rd_array[`S1_UART]),
    .write(mem_wr_array[`S1_UART]),
    .addr(reg_addr_array[`S1_UART]),
    .rd_data(rd_data_array[`S1_UART]),
    .wr_data(wr_data_array[`S1_UART]), 
    .tx(tx),
    .rx(rx)
    );
   // slot 2: ps2 
    chu_ps2_core #(.W_SIZE(6)) ps2_slot2 
    (.clk(clk),
     .reset(reset),
     .cs(cs_array[`S2_PS2]),
     .read(mem_rd_array[`S2_PS2]),
     .write(mem_wr_array[`S2_PS2]),
     .addr(reg_addr_array[`S2_PS2]),
     .rd_data(rd_data_array[`S2_PS2]),
     .wr_data(wr_data_array[`S2_PS2]),
     .rx_done_pulse(rx_done_pulse),
     .ps2d_in(ps2d_in),
     .ps2c_in(ps2c_in),
     .tri_c(tri_c),
     .tri_d(tri_d),
     .ps2c_out(ps2c_out),
     .ps2d_out(ps2d_out)
     );
     
         // slot 0: system timer 
   chu_timer timer_slot0 
   (.clk(clk),
    .reset(reset),
    .cs(cs_array[`S0_SYS_TIMER]),
    .read(mem_rd_array[`S0_SYS_TIMER]),
    .write(mem_wr_array[`S0_SYS_TIMER]),
    .addr(reg_addr_array[`S0_SYS_TIMER]),
    .rd_data(rd_data_array[`S0_SYS_TIMER]),
    .wr_data(wr_data_array[`S0_SYS_TIMER])
    );


   // assign 0's to all unused slot rd_data signals
   generate
      genvar i;
      for (i=14; i<64; i=i+1) begin
         assign rd_data_array[i] = 32'h0;
      end
   endgenerate
endmodule