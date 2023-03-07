//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2023 05:51:50 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input wire sysclk_p,
    input wire sysclk_n,
    input wire reset,
    //input wire [15:0] x_disp,
    //input wire [15:0] y_disp,
    //input wire [7:0] z_disp,
    //input wire [3:0] buttons
    
    //inout wire clk_mouse,
    //inout wire data_mouse,
    inout wire ps2c,
    inout wire ps2d,
    input wire rx,
    output wire tx
    //output wire tri_c,
    //output wire tri_d
    );
    
begin
   
    //wire clk, data;
    reg clk_100M = 0;
    wire clk_200M;
    wire transmitting, receiving, ps2tx_data, ps2tx_clock, ps2rx_clock, ps2rx_data;
    wire ps2c_in, ps2d_in, ps2c_out, ps2d_out;
   // wire tri_c, tri_d;
    
    //pullup(clk_mouse);
    //pullup(data_mouse);
       
    //pullup(clk_module);
    //pullup(data_module);
    
    
      reg count;  // 8-bit counter for dividing the clock
      parameter DIVIDER_VALUE = 2;   // divide the clock by this value
    
      always @(posedge clk_200M) begin
        if (reset) begin
            count <= 0;
            clk_100M <= 0;
        end
        else if (count == DIVIDER_VALUE-1) begin
          count <= 0;
          clk_100M <= ~clk_100M;   // invert the output clock
        end
        else begin
          count <= count + 1;
        end
      end

    IBUFGDS #(
    .DIFF_TERM("FALSE"),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT")
    ) IBUFGDS_inst(
        .O(clk_200M),
        .I(sysclk_p),
        .IB(sysclk_n)
    );
    
      
    // Tristate logic for ps2_clk
    //assign clk_mouse = (transmitting && ps2tx_clock == 1'b0)? ps2tx_clock 
    //                 : (receiving && ps2tx_clock == 1'b0)?  ps2tx_clock: 1'bz;
    // Tristate logic for ps2_data
    //assign data_mouse = (transmitting && !receiving)? ps2tx_data: 1'bz;
  
    
    /*ps2_mouse ps2_inst(
         .clk_100M(clk_100M),
         .ps2tx_clock(ps2tx_clock),
         .ps2tx_data(ps2tx_data),
         .ps2rx_clock(clk_mouse),
         .ps2rx_data(data_mouse),
         .x_displacement(1),
         .y_displacement(1),
         .z_displacement(1),
         .buttons(4'b1000),
         .transmitting(transmitting),
         .receiving(receiving)
    );*/


   // tristate buffers
   //Output Control
   assign ps2c = (tri_c)? ps2c_out: 1'bz;
   assign ps2d = (tri_d)? ps2d_out: 1'bz;
   //Input Control
   assign ps2c_in = (!tri_c)? ps2c: 1'b0;
   assign ps2d_in = (!tri_d)? ps2d: 1'b0;
   
   // Instantiate the module
    mcs_top_heat_arty_a7 mod (
        .clk_100M(clk_200M),
        .reset(reset), 
        .ps2c_in(ps2c_in),
        .ps2d_in(ps2d_in),
        .tri_c(tri_c),
        .tri_d(tri_d),
        .ps2c_out(ps2c_out),
        .ps2d_out(ps2d_out),
        .tx(tx),
        .rx(rx)
        );
       
     /*mouseMovementAccumulator host
        (.clock(clk_100M),
         .reset(~reset),
         .ps2d(ps2d_in),
         .ps2c(ps2c_in),
         .ps2c_out(ps2c_out),
         .ps2d_out(ps2d_out),
         .tri_c(tri_c),
         .tri_d(tri_d),
         //.streaming(streaming),
         //.rotationAxis(axis),
         .xDisplacement(),
         .yDisplacement(),
         .zDisplacement(),
         .led(),
         .mouse_moving()
        );*/
 
end
endmodule
