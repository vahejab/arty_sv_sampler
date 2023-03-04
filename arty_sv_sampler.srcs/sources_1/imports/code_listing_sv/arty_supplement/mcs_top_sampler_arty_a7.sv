module mcs_top_heat_arty_a7
    #(parameter BRG_BASE = 32'hc000_0000)   
    (
       (* dont_touch = "true" *)  input  logic reset,
       (* dont_touch = "true" *)  input  logic clk_100M,
       // uart
       (* dont_touch = "true" *)  input  logic rx,
       (* dont_touch = "true" *)  output logic tx,
       // ps2
       (* dont_touch = "true" *)  output logic tri_c,
       (* dont_touch = "true" *)  output logic tri_d,
       (* dont_touch = "true" *)  input wire   ps2c_in,
       (* dont_touch = "true" *)  input wire   ps2d_in,
       (* dont_touch = "true" *)  output logic ps2c_out,
       (* dont_touch = "true" *)  output logic ps2d_out
    );
    
       // declaration
       //logic clk_200M;
       logic reset_sys;
       // MCS IO bus
       logic io_addr_strobe;
       logic io_read_strobe;
       logic io_write_strobe;
       logic [3:0] io_byte_enable;
       logic [31:0] io_address;
       logic [31:0] io_write_data;
       logic [31:0] io_read_data;
       logic io_ready;
       // fpro bus 
       logic fp_mmio_cs; 
       logic fp_wr;      
       logic fp_rd;     
       logic [20:0] fp_addr;       
       logic [31:0] fp_wr_data;    
       logic [31:0] fp_rd_data; 
       // PS/2 rx done interrupt
       logic ps2_rx_done_interrupt;
       logic irq;
       
       //instantiate uBlaze MCS
       cpu cpu_unit (
        .Clk(clk_100M),                          
        .Reset(reset),            
        .IO_addr_strobe(io_addr_strobe),    
        .IO_address(io_address),            
        .IO_byte_enable(io_byte_enable),    
        .IO_read_data(io_read_data),        
        .IO_read_strobe(io_read_strobe),    
        .IO_ready(io_ready),                
        .IO_write_data(io_write_data),      
        .IO_write_strobe(io_write_strobe),
        .INTC_Interrupt(irq)
        );
        
       axi_intc_0 intc(
        .s_axi_awaddr(0),
        .s_axi_awvalid(0),
        .s_axi_wdata(0),
        .s_axi_wvalid(0),
        .s_axi_bready(0),
        .s_axi_araddr(0),
        .s_axi_arvalid(0),
        .s_axi_rready(0),
        .s_axi_wstrb(0),
        .s_axi_aclk (clk_100M),
        .s_axi_aresetn(~reset),
        .processor_clk(clk_100M),
        .processor_rst(reset),
        .intr(ps2_rx_done_interrupt),
        .irq(irq)
       );

       // instantiate bridge
       chu_mcs_bridge #(.BRG_BASE(BRG_BASE)) 
         b_unit (.io_addr_strobe(io_addr_strobe), 
                 .io_read_strobe(io_read_strobe),
                 .io_write_strobe(io_write_strobe), 
                 .io_byte_enable(io_byte_enable), 
                 .io_address(io_address), 
                 .io_write_data(io_write_data),
                 .io_read_data(io_read_data), 
                 .io_ready(io_ready),
                 .fp_video_cs(), 
                 .fp_mmio_cs(fp_mmio_cs), 
                 .fp_wr(fp_wr), 
                 .fp_rd(fp_rd),
                 .fp_addr(fp_addr), 
                 .fp_wr_data(fp_wr_data), 
                 .fp_rd_data(fp_rd_data));
       
       // instantiated i/o subsystem
       mmio_sys_sampler_arty_a7  mmio_unit (
        .clk(clk_100M),
        .reset(reset),
        .mmio_cs(fp_mmio_cs),
        .mmio_wr(fp_wr),
        .mmio_rd(fp_rd),
        .mmio_addr(fp_addr), 
        .mmio_wr_data(fp_wr_data),
        .mmio_rd_data(fp_rd_data),
        .ps2d_in(ps2d_in),
        .ps2c_in(ps2c_in),
        .tri_c(tri_c),
        .tri_d(tri_d),
        .ps2c_out(ps2c_out),
        .ps2d_out(ps2d_out),          
        .rx(rx),
        .tx(tx),
        .ps2_rx_done_interrupt(ps2_rx_done_interrupt)
       );   
    endmodule 