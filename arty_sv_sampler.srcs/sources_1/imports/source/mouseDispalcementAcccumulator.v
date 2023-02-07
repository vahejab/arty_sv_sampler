`timescale 1ns / 1ps

/**********************************************************************************
*  Module Name:      	mouse_xy
*  File Name:        	mouse_xy.v
*
*  Author:					Vahe Robert Jabagchourian
*								California State University Northridge
*
*  Creation Date:   		November 10, 2010
*  
*  Description:      	Contains logic to capture mouse x,y,z Movement and 
*								button presses
*
*  Modifications Made		
*  November 10, 2010	  Initial Design Created		
*  December 28, 2010   Overflow Detection Conditions Created
*							  Set abs_dy or abs_dx to 0 when the dy dx counters 
*							  overflow
*							  Added support for falling edge of x and y ready
*							  These falling edge signals are called sign ready signals
*  February 8, 2011	  MAX_X, MAX_Y changed to 511, 511 respectively
*	February 8, 2011	  WIDTH, HEIGHT changed to CURSOR_WIDTH, CURSOR_HEIGHT  
*  February 15, 2011   zMovement added to mouse_xy otuput port
*  February 17, 2011	  abs_dy replaced with abs_dz to fix typographical error
*							  on continous assignment statement
*  April 27, 2011		  Added logic to detect mouse motion (x or y changing)
*  July 28, 2011		  Separated the mixed structural and behavioral constructs
*							  And created logic for 10-bit Movement accumulator
*
*							  xMovement = rotation about y axis on monitor
*							  yMovement = rotation about x axis on monitor
* 							  zMovement = rotation about z axis on monitor
***********************************************************************************/

module mouseDisplacementAccumulator
(clock, 
 reset, 
 sign_x,
 sign_y,
 mouseButton,
 streaming,
 btn_ready,
 xMovement, 
 yMovement,
 zMovement,
 xDisplacement,
 yDisplacement,
 zDisplacement,
 buttonPressed, 
 led,
 mouse_moving, //When asserted, the object is fetched again one vertex at a time
 overflowX,
 overflowY,
 data_x_ready,
 data_y_ready,
 data_z_ready); 
   
	parameter DISPLACEMENT_QUANTIZATION_DEPTH = 1024;
	
	/************************************************************************************
	* Input Output Ports
	************************************************************************************/
	
   input wire clock, reset;
	input wire sign_x, sign_y;
	input wire overflowX, overflowY;
	input wire data_x_ready;
	input wire data_y_ready;
	input wire data_z_ready;
   input wire [2:0] 	 mouseButton;
	input wire streaming;
	input wire btn_ready;
	input wire [7:0] xMovement;
	input wire [7:0] yMovement;
	input wire [7:0] zMovement;
   output reg [9:0] xDisplacement;
	output reg [9:0] yDisplacement;  	// current mouse Movement
	output reg [9:0] zDisplacement;
   output reg [2:0]  buttonPressed;	// button click: Left-Middle-Right
	//Debugging on FPGA led's
	output wire [12:0] led;
	output reg mouse_moving;
	
	/************************************************************************************
	* Interconnects
	************************************************************************************/


	wire sign_x_ready;  //falling data x ready
	wire sign_y_ready;  //falling data y ready
	wire sign_z_ready;  //falling data z ready
	wire rising_btn_ready;
	
	/************************************************************************************
	* Reg
	************************************************************************************/
	reg data_x_ready_delay;
	reg data_y_ready_delay;
	reg data_z_ready_delay;
	reg btn_ready_delay;
	reg sign_z;
   // Update "absolute" Movement of mouse
   reg [8:0]  abs_dx;
   reg [8:0]  abs_dy;
	reg [3:0]  abs_dz;	//Upper 4 bits are sign extended therefore we only use 4 significant bits
	

	/************************************************************************************
	* Continuous Assignments
	************************************************************************************/
	//Changed ~signY and signY because LED was inverted with respect
	//to direction of movement
	//To make up movement turn on North LED and down movement turn on
	//South LED the change had to be made
	assign led = {zMovement[7:0], mouse_moving, ~sign_x, ~sign_y, sign_y, sign_x};
	
	//Note: this is the falling edge of data_x_ready
	assign sign_x_ready = ~data_x_ready & data_x_ready_delay;
	assign sign_y_ready = ~data_y_ready & data_y_ready_delay;
	assign sign_z_ready = ~data_z_ready & data_z_ready_delay;
	
	assign rising_btn_ready = ~btn_ready & btn_ready_delay;

	/************************************************************************************
	* Always Blocks
	************************************************************************************/
	always @(*)//Changed from *
	begin
	
		/******************************************************************************
		* X Value
		******************************************************************************/
		// Apply a Two's complement to negative values (MSB = 1) for absolute magnitude
		if (!overflowX && data_x_ready)
		begin
			abs_dx <= (sign_x == 1)? ~{sign_x, xMovement[7:0]}+1'b1 : {sign_x, xMovement[7:0]};
		end
		else if (overflowX && sign_x_ready)
		begin
			abs_dx <= 0;
		end
		else //if !sign_x_ready
		begin
			abs_dx <= abs_dx;
		end
		
		// Apply a Two's complement to negative values (MSB = 1) for absolute magnitude
		if (!overflowY & data_y_ready)
		begin
			abs_dy <= (sign_y == 1)? ~{sign_y, yMovement[7:0]}+1'b1 : {sign_y, yMovement[7:0]};
		end
		else if (overflowY && sign_y_ready)
		begin
			abs_dy <= 0;
		end
		else //if !sign_x_ready
		begin
			abs_dy <= abs_dy;
		end
	
		//Note: there is no overflow or sign information for Z packet
		//Therefore we use the MSB (bit 3) of the Z packet for the sign
		//This is because Z is a signed 2's compliment		
		if (data_z_ready)
		begin
			sign_z <= zMovement[3];  //Sign Bit of the Z vector
			abs_dz <= ((zMovement[3] == 1)? ~{zMovement[3:0]}+1'b1 : {zMovement[3:0]});
		end
		else
		begin
			abs_dz <= 0;
		end 
	end
	

	always @(posedge clock)
	begin
		data_x_ready_delay <= data_x_ready;
		data_y_ready_delay <= data_y_ready;
		data_z_ready_delay <= data_z_ready;
		btn_ready_delay <= btn_ready;
	end
 
	/*********************************************************
	* Movement Accumulator Logic
	*********************************************************/
	always @(posedge clock)
	begin
		if (!reset)
		begin
			xDisplacement <= 0;
			yDisplacement <= 0;
			zDisplacement <= 0;
			mouse_moving <= 0;
		end
		else
		begin
			if (streaming)
			begin
				mouse_moving <= (abs_dx > 0 || abs_dy > 0 || abs_dz > 0);
				//Trigger a rotation about the X Axis
				if (data_x_ready)
				begin
					if (sign_x == 1)
					begin
					   //Wrap Around from the end of the sin cos look up table so that
						//the sin cos lut will generate a negative rotation
						xDisplacement <= (DISPLACEMENT_QUANTIZATION_DEPTH - 1) - {abs_dx[8], abs_dx};
					end
					else if (sign_x == 0) 
					begin

						xDisplacement <= ((abs_dx  ));
					end
				end
				else
				begin
					xDisplacement <= 0; //Hold Value
				end	

				//Trigger a rotation about the Y Axis
				if (data_y_ready)
				begin
					//Negative Sign
					if (sign_y == 0)
					begin
						//Wrap Around from the end of the sin cos look up table so that
						//the sin cos lut will generate a negative rotation
						yDisplacement <= (DISPLACEMENT_QUANTIZATION_DEPTH - 1) - {abs_dy[8], abs_dy}; 
					end
					else if (sign_y == 1) 
					begin
						yDisplacement <= (abs_dy  );
					end
				end
				else
				begin
					yDisplacement <= 0;
				end
				
				//Trigger a rotation about the Z axis
				if (data_z_ready)
				begin
					//Negative Sign
					if (sign_z == 0)
					begin
						zDisplacement <= (DISPLACEMENT_QUANTIZATION_DEPTH - 1) - {{5{abs_dz[3]}}, abs_dz};
					end
					else if (sign_z == 1) 
					begin
						//Wrap Around from the end of the sin cos look up table so that
						//the sin cos lut will generate a negative rotation					
						zDisplacement <=  ((abs_dz)); 
					end
				end
				else
				begin
					zDisplacement <= 0;
				end
		
				if (rising_btn_ready)
				begin
					buttonPressed <= mouseButton;
				end
				else
				begin
					buttonPressed <= buttonPressed;
				end	
			end
			else if (!streaming)
			begin
				mouse_moving <= 0;
			end
		end
	end
endmodule

