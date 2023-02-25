`timescale 1ns / 1ps


module ps2_mouse #(parameter int MOUSE_ID = 8'h03)(
    input wire clk_100M,
    output wire ps2tx_clock,
    output wire ps2tx_data,
    input wire ps2rx_clock,
    input wire ps2rx_data,
    input wire [15:0] x_displacement,
    input wire [15:0] y_displacement,
    input wire [7:0] z_displacement,
    input wire [3:0] buttons,
    output wire transmitting,
    output wire receiving
);

    // Internal signal for reset
    reg internal_reset = 0;
    // Internal signal for clock
    reg internal_clk = 0;
    // Counter for generating clock
    reg [7:0] clock_counter = 8'b0;
    // Counter for generating reset
    reg [7:0] reset_counter = 8'b0;
    
    reg tx_enable;
    wire send_ack;
    
    wire [15:0] x_movement;
    wire [15:0] y_movement;
    wire [7:0] z_movement;
    wire [7:0] data_out;
    wire send_data;
    wire clk_out_sending, clk_out_receiving;
    
    wire ps2din;
    /*always begin
        #10; internal_clk <= ~internal_clk;
    end*/
    
    assign ps2tx_clock = (transmitting)? clk_out_sending: (receiving)? clk_out_receiving: 1'b1;

    always  @(posedge clk_100M) begin
        // Generate internal reset
        internal_reset <= (reset_counter == 100) ? 1'b1 : 1'b0;
        // Reset reset counter
        reset_counter <= (reset_counter < 101) ? reset_counter + 1: 101;
       
        if (internal_reset == 1) begin
            tx_enable <= 0;
        end else begin
            if (send_ack) begin
                tx_enable <= 0;
            end else if (send_data) begin
                tx_enable <= 1;
            end
        end
    end

    // Instantiation of mouse_movement module
    mouse_movement movement (
        .clk(clk_100M),
        .rst(internal_reset),
        .x_displacement(x_displacement),
        .y_displacement(y_displacement),
        .wheel_displacement(z_displacement),
        .x_movement(x_movement),
        .y_movement(y_movement),
        .wheel_movement(z_movement)
    );
    // Instantiation of ps2_transmit and ps2_receive modules
    ps2_transmit transmit(
        .clkIn(clk_100M),
        .rst(internal_reset),
        .data_in(data_out),
        .send_ack(send_ack),
        .send_data(send_data),
        .data_out(ps2tx_data),
        .clk_out(clk_out_sending),
        .transmitting(transmitting)
    );
    
    ps2_receive  #(.MOUSE_ID(MOUSE_ID)) receive(
        .clkIn(clk_100M),
        .rst(internal_reset),
        .data_in(ps2rx_data),
        .send_ack(send_ack),
        .data_out(data_out),
        .send_data(send_data),
        .clk_out(clk_out_receiving),
        .clk_in(ps2rx_clock),
        .receiving(receiving),
        .x_movement(x_movement),
        .y_movement(y_movement),
        .z_movement(z_movement),
        .buttons(buttons)
    );

endmodule