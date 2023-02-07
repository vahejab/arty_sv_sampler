`timescale 1ns / 1ps

/****************************************************************************
*  Module Name:            mouseDisplacementAccumulator
*  File Name:              mouseDisplacementAccumulator.v
*
*  Author:                 Vahe Jabagchourian
*                          California State University, Northridge
*
*  Creation Date:        	August 28, 2011
*  
*  Description:            Contains Structural Interconnection of
*									mousePacketController, and mouseDisplacementAccumulator
****************************************************************************/

module mouseMovementAccumulator
(clock,
 reset,
 ps2d,
 ps2c,
 ps2c_out,
 ps2d_out,
 tri_c,
 tri_d,
 streaming,
 rotationAxis,
 led,
 mouse_moving,
 xDisplacement,
 yDisplacement,
 zDisplacement,
 buttonPressed
);

	/*****************************************************************
	* Inputs Outputs
	*****************************************************************/

	input wire clock;
	input wire reset;
	input wire ps2d, ps2c; 
    output wire streaming;
	//output wire [9:0] rotationAmountX, rotationAmountY, rotationAmountZ;
	output wire [2:0] rotationAxis;
	output wire mouse_moving;
	output wire [12:0] led;
	output wire [9:0] xDisplacement;
    output wire [9:0] yDisplacement;
	output wire [9:0] zDisplacement;
    output wire [2:0] buttonPressed;
    output wire ps2c_out, ps2d_out, tri_c, tri_d;

		
	/*****************************************************************
	* Interconnects
	*****************************************************************/
	//output wire data_x_ready, data_y_ready, data_z_ready;
	wire [7:0] xMovement, yMovement, zMovement; //8 Bit Displacement Counters
	wire [4:0] state;				  //5 Bit State Value
	wire [2:0] mouseButton;
	wire btn_ready;
	wire signX, signY, signZ;
	wire overflowX;
	wire overflowY;
	wire [2:0] state_reg;
	
	wire rx_done_tick;
	wire tx_done_tick;
	wire [7:0] rx_data;
   wire wr_ps2;
	wire [7:0] tx_data;





// Instantiate the module
ps2_txrx ps2_transceiver (
    .clk(clock), 
    .reset(reset), 
    .wr_ps2(wr_ps2), 
    .din(tx_data), 
	.dout(rx_data),
    .ps2d(ps2d), 
    .ps2c(ps2c), 
    .ps2c_out(ps2c_out),
    .ps2d_out(ps2d_out),
    .tri_c(tri_c),
    .tri_d(tri_d),
    .tx_done_tick(tx_done_tick), 
    .rx_done_tick(rx_done_tick)
    );


	
	/************************************************************
	* PS/2 Receiver Unit
	************************************************************/
	
	
	/*ps2_rx ps2_rx_unit
		(.clk(clock), 
		 .reset(reset), 
		 .rx_en(tx_idle), 
		 .ps2d(ps2d), 
		 .ps2c(ps2c),
		 .rx_done_tick(rx_done_tick), 
		 .dout(rx_data));
*/
	/************************************************************
	* PS/2 Transmitter Unit
	************************************************************/
		
/*
	ps2_tx ps2_tx_unit
		(.clk(clock), 
		 .wr_ps2(wr_ps2), 
		 .din(tx_data), 
		 .ps2d(ps2d), 
		 .ps2c(ps2c),
		 .tx_idle(tx_idle), 
		 .tx_done_tick(tx_done_tick), 
		 .state_reg(state_reg));
*/	 
	 
	/************************************************************
	* Mouse Packet Controller
	************************************************************/ 

	mousePacketController mousePacketControlUnit (
    .clock(clock), 
    .reset(reset), 
	 .rx_data(rx_data),
	 .tx_data(tx_data),
    .rx_done_tick(rx_done_tick), 
    .tx_done_tick(tx_done_tick), 
    .xMovement(xMovement), 
    .yMovement(yMovement), 
    .zMovement(zMovement), 
    .buttonPressed(mouseButton), 
    .data_x_ready(data_x_ready), 
    .data_y_ready(data_y_ready), 
    .data_z_ready(data_z_ready), 
    .state(state), 
    .streaming(streaming), 
    .btn_ready(btn_ready), 
    .signX(signX), 
    .signY(signY),
	.signZ(signZ),
    .overflowX(overflowX), 
    .overflowY(overflowY),
	.wr_ps2(wr_ps2)
    );
	 
	/************************************************************
	* Mouse Displacement dAccumulator
	************************************************************/
	mouseDisplacementAccumulator mouseDisplacerAdder (
    .clock(clock), 
    .reset(reset), 
    .sign_x(signX), 
    .sign_y(signY), 
    .mouseButton(mouseButton), 
    .streaming(streaming), 
    .btn_ready(btn_ready), 
    .xMovement(xMovement), 
    .yMovement(yMovement), 
    .zMovement(zMovement), 
    .xDisplacement(xDisplacement), 
    .yDisplacement(yDisplacement), 
    .zDisplacement(zDisplacement), 
    .buttonPressed(buttonPressed), 
    .led(led), 
    .mouse_moving(mouse_moving), 
    .overflowX(overflowX), 
    .overflowY(overflowY), 
    .data_x_ready(data_x_ready), 
    .data_y_ready(data_y_ready), 
    .data_z_ready(data_z_ready)
    );
	 
	 
	/************************************************************
	* Mouse Movement Axis to Rotation Axis Decoder
	************************************************************/
	/*mouseMovementAxisToRotationDecoder rotationAxisDecoder(
    .clock(clock), 
    .reset(reset), 
    .streaming(streaming), 
    .data_x_ready(data_x_ready), 
    .data_y_ready(data_y_ready), 
    .data_z_ready(data_z_ready), 
    .xDisplacement(xDisplacement), 
    .yDisplacement(yDisplacement), 
    .zDisplacement(zDisplacement), 
	 .rotationAxis(rotationAxis),
	 .rotationAmountX(rotationAmountX),
	 .rotationAmountY(rotationAmountY),
	 .rotationAmountZ(rotationAmountZ),
	 .mouse_moving(mouse_moving)
	 );*/

endmodule
