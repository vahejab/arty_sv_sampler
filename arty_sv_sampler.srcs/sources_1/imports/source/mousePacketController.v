`timescale 1ns / 1ps

/**********************************************************************************
*  Module Name:      		mousePacketController
*  File Name:        		mousePacketController.v
*
*  Author:						Vahe Robert Jabagchourian
*									California State University Northridge
*
*  Creation Date:   			November 1, 2010
*  
*  Description:      		Contains state machine logic to form the main tx/rx
*									states for packet transaction for a PS/2 mouse/trackball
*
*  Modifications Made		
*  November 1, 2010			Module Created
*  November 3, 2010			PS/2 Intellimouse States / State Machine Added
*  November 10, 2010			Check for ID Scrolling Mouse added
*  November 20, 2010			LED outputs added to determine state at which module 
*									gets stuck
* 	December 28, 2010			Logic created to hold value of sign x and sign y
*									Overflow bits capture
*	February 15, 2011			Removed set sample rate 10 state	
*									and revised state machine to work with scroll wheel
*									two buttons (left, right) (translate, rotate)
*									Added zMovement and data_z_ready to outut inteface ports
*  February 15, 2011	      Reinserted sample rate 10 state to resolve Z movement	 
*  4 Byte Packet Depiction for "3D Mouse" from 
*  http://www.colinfahey.com
*				/ps2_mouse_and_basic_stamp_computer
*					/ps2_mouse_and_basic_stamp_computer_en.html
*
*		------------------------
*		 D7 D6 D5 D4 D3 D2 D1 D0  (The D0 bit (LSB) is sent first)
*		------------------------
*	(1) YV XV YS XS  1  M  R  L  (overflow, sign, buttons)
*	(2) X7 X6 X5 X4 X3 X2 X1 X0  (X movement; -128 to +127)
*	(3) Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0  (Y movement; -128 to +127)
*	(4)  0  0  0  0 Z3 Z2 Z1 Z0  (Z movement;   -8 to +7)
* 
* February 16, 2011       Removed Set Sample Rate 40, 10 and Send Decimal 40, 10
*								  to test scroll wheel.
* February 16, 2011		  Added z_next[7:0] <= rx_data; to Packet 4 State (Z Packet)
* February 16, 2011		  Removed/ReInserted Set Scaling 1:1, Set Sample Rate 40, 10 
*								  States to calibrate cursor for erratic mouse movements
* Feburary 16, 2011		  Removed Set Sample Rate 40, 10 State to test Z
* July 28, 2011			  Renamed module from mouse_xy to mousePacketController
*								  Added rx_done_tick and tx_done_tick to module port list
*								  Removed ps2d and ps2c (clock/data) from port list
*							     Renamed state to mouseController state
***********************************************************************************/
		 
module mousePacketController
(clock, 
reset,
rx_done_tick,
tx_done_tick,
rx_data,
tx_data, 
xMovement, 
yMovement,
zMovement,
buttonPressed,
data_x_ready,
data_y_ready,
data_z_ready,
state,
streaming,
btn_ready,
signX,
signY,
signZ,
overflowX,
overflowY,
wr_ps2);
		
	input wire clock, reset;
	input wire rx_done_tick;
	input wire tx_done_tick;
	input wire [7:0] rx_data;
	
	output reg wr_ps2;
	output reg [7:0] tx_data;
	output reg [7:0] xMovement, yMovement, zMovement; //8 Bit Movement Counters
	output reg [2:0] buttonPressed;	 //Middle Left Right Button Vector
	output reg data_x_ready = 0;
	output reg data_y_ready = 0;
	output reg data_z_ready = 0;
	output [4:0] state;		//5 Bit State Value
	output reg streaming;	//Is FPGA Recieving Streaming Data From Mouse?
	output reg btn_ready;
	output reg signX, signY, signZ;
	output overflowX;
	output overflowY;
	
	/************************************************************************************
	* Top Level State Machine Names
	************************************************************************************/
	
	//Note that in all GET states
	//The mouse is sending, transmitting to the FPGA (the receiver)
	//The basis for this state machine is from www.computer-engineering.org/ps2mouse/
	
	parameter IDLE_STATE =  5'b00000;
	parameter RESET_STATE =  5'b00001;
	parameter GET_ACK_STATE =  5'b00010;
	parameter GET_BAT_STATE = 5'b00011;
	parameter GET_ID_STATE =  5'b00100;
	parameter SET_SAMPLE_RATE_200_STATE =  5'b00101;
	parameter SET_SAMPLE_RATE_100_STATE =  5'b00110;
	parameter SET_SAMPLE_RATE_80_STATE =  5'b00111;
	parameter SEND_DECIMAL_200_STATE =  5'b01000;
	parameter SEND_DECIMAL_100_STATE = 5'b01001;
	parameter SEND_DECIMAL_80_STATE =  5'b01010;
	parameter READ_DEVICE_TYPE_STATE =  5'b01011;
	parameter SET_EN_STATE =  5'b01100;
	parameter GET_PACKET1_STATE =  5'b01101;
	parameter GET_PACKET2_STATE =  5'b01110;
	parameter GET_PACKET3_STATE =  5'b01111;			
	parameter GET_PACKET4_STATE =  5'b10000;
	
	/************************************************************************************
	* Commands Sent to PS/2 Mouse
	************************************************************************************/
 
	parameter RESET_COMMAND =  8'hFF;
	parameter ENABLE_COMMAND = 8'hEA;
	parameter SET_SAMPLE_RATE_COMMAND = 8'hF3;
	parameter SEND_DECIMAL_200_COMMAND =  8'hC8;
	parameter SEND_DECIMAL_100_COMMAND =  8'h64;
	parameter SEND_DECIMAL_80_COMMAND =  8'h50;
	parameter READ_DEVICE_TYPE_COMMAND =  8'hF2;
	
	/************************************************************************************
	* Commands Sent from PS/2 Mouse
	************************************************************************************/
	
	parameter ACK_MOUSE = 8'hFA;
	parameter BAT_OK_MOUSE = 8'hAA;
	parameter BAT_ERR_MOUSE = 8'hFC;
	parameter ID_MOUSE = 8'h00;
	parameter ID_SCROLLING_MOUSE = 8'h03;
	parameter RESEND = 8'hFE;
	
	/************************************************************************************
	* Reg Declarations
	************************************************************************************/

	reg [4:0] state, next_state, state_after_ack, state_after_ack_reg;


	/************************************************************************************
	* State Transition Flags
	************************************************************************************/
	reg decimal_10_sent = 0, decimal_10_sent_reg;
	reg scroll_mode_set = 0, scroll_mode_set_reg;
	

	/************************************************************************************
	* Reset Active
	************************************************************************************/
	
	reg reset_active;	//Once an active reset occurs set reset_active to 1
	
	/************************************************************************************
	* Overflow information
	************************************************************************************/

	reg overflowX;		//Overflow from Packet 1
	reg overflowY;		//Overflow from Packet 1

	reg[16:0] clk_count = 0;	
	/************************************************************************************
	* State Machine 
	************************************************************************************/

	always @(posedge clock)
	begin
		if (!reset)
		begin
			state <= IDLE_STATE;
			xMovement <= 0;
			yMovement <= 0;
			zMovement <= 0;
			buttonPressed <= 0;
			reset_active <= 1;
			scroll_mode_set <= 0;
			decimal_10_sent <= 0;
			overflowX <= 0;
			overflowY <= 0;
			signX <= 0;
			signY <= 0;
			signZ <= 0;
		end
		else
		begin
			case(state)
				IDLE_STATE:			//Do Nothing in this state but go to RESET_STATE unconditionally
				begin
                        xMovement <= 0;
                        yMovement <= 0;
                        zMovement <= 0;
                        buttonPressed  <= 0;
                        state <= RESET_STATE;						
                        //RESET_COMMAND <= 8'hFF
                        tx_data <= RESET_COMMAND;			
                        //FPGA writing to PS/2 Mouse
                        wr_ps2 <= 1;
                end			
				RESET_STATE:		//Initialize mouse and prepare mouse for Basic Assurance Test
				begin

						//When FPGA is done writing to mouse
						//move to next state
						if(tx_done_tick)
						begin
							//Since Ack is reached by several states
							//we need to compute the state after ack
							//to know where our current state was
							state <= GET_ACK_STATE;
							state_after_ack <= GET_BAT_STATE;
							//FPGA not writing to PS/2 Mouse
							wr_ps2 <= 0;
							//When ack signal received
							//go to the state after ack from the 
							//previous state which has
							//state_after_ack stored
						end

				end
				GET_ACK_STATE:			//Acknowledge state from mouse
				begin
                    /*if(rx_done_tick && state_after_ack != GET_BAT_STATE && state_after_ack != GET_PACKET1_STATE)		//When receive is done and ack_mouse recieved then go to state after ack
                    begin
                        if (state_after_ack == SET_SAMPLE_RATE_100_STATE)
                        begin
                            tx_data <= SET_SAMPLE_RATE_COMMAND; //SET_SAMPLE_RATE_COMMAND <= 8'hF3	
                            wr_ps2 <= 1;  //FPGA Sending to Mouse
                        end
                        else if (state_after_ack == SET_SAMPLE_RATE_80_STATE)
                        begin
                            tx_data <= SET_SAMPLE_RATE_COMMAND; //SET_SAMPLE_RATE_COMMAND <= 8'hF3	
                            wr_ps2 <= 1; //FPGA Sending to Mouse
                        end
                        else if (state_after_ack == SEND_DECIMAL_200_STATE)
                        begin
                            tx_data <= SEND_DECIMAL_200_COMMAND; //SEND_DECIMAL_200_COMMAND <= 8'hC8 <= 8'd200
                            wr_ps2 <= 1;  //FPGA Sending to Mouse
                        end
                        else if (state_after_ack == SEND_DECIMAL_100_STATE)
                        begin
                            tx_data <= SEND_DECIMAL_100_COMMAND; //SEND_DECIMAL_100_COMMAND <= 8'h64 <= 8'd100	
                            wr_ps2 <= 1;	 //FPGA Sending to Mouse	
                        end
                        else if (state_after_ack == SEND_DECIMAL_80_STATE)
                        begin
                            tx_data <= SEND_DECIMAL_80_COMMAND; //SEND_DECIMAL_80_COMMAND <= 8'h50 <= 8'd50
                            wr_ps2 <= 1;	//FPGA Sending to Mouse
                        end
                        else if (state_after_ack == READ_DEVICE_TYPE_STATE)
                        begin
                            tx_data <= READ_DEVICE_TYPE_COMMAND;
                            wr_ps2 <= 1;   //FPGA Sending to Mouse
                        end
                        else
                        begin
                            wr_ps2 <= 0;
                        end
                    end*/
                    if(rx_done_tick) begin
                        if (state_after_ack == READ_DEVICE_TYPE_STATE) begin
                            state <= state_after_ack;
                            tx_data <= READ_DEVICE_TYPE_COMMAND;
                            wr_ps2 <= 1;   //FPGA Sending to Mouse
                        end
                        
                        if (state_after_ack == GET_ID_STATE) begin
                            state <= state_after_ack;
                            wr_ps2 <= 0;
                        end
                        else if (state_after_ack == GET_BAT_STATE) begin
                            state <= state_after_ack;
                            wr_ps2 <= 0;
                        end
                        else if (state_after_ack == GET_PACKET1_STATE) begin
                             if (rx_data == ACK_MOUSE) begin
                                wr_ps2 <= 0;
                                state <= state_after_ack;
                            end
                        end
                    end
				end
				GET_BAT_STATE:			// Basic Assurance Test State
				begin
                    if(rx_data == BAT_OK_MOUSE)		//If receive data is 8'hAA
                    begin	
                        wr_ps2 <= 0;	//Mouse Sending to FPGA
                        state <= GET_ID_STATE;		//Then go to Get Mouse ID
                    end
				end
				//Since GET_ID_STATE is reached from several states
				//deterimine which part of the mouse initialization 
				//it was reached and make the state machine go 1 of two states
				//If scroll mode has not yet been set then go to SET_SAMPLE_RATE_200
				//Else if scroll mode has been set then go to SET_RESOLUTION_STATE
				GET_ID_STATE:				
				begin
                        ////////////////////////////////
                        /*
                        if (rx_data == ID_MOUSE)
                        begin
                            wr_ps2 <= 1;	 //FPGA Sending to Mouse	
                            state <= SET_SAMPLE_RATE_200_STATE;
                            tx_data <= SET_SAMPLE_RATE_COMMAND; //SET_SAMPLE_RATE_COMMAND <= 8'hF3	
                        end
                        */
                        /////////////////////////////////
                        /// Go to streaing mode after reading device type
                        if(rx_data == ID_SCROLLING_MOUSE)
                        begin
                                clk_count <= clk_count + 1;
                                if (clk_count == 65535) begin
                                    wr_ps2 <= 1;
                                    state <= SET_EN_STATE;
                                    tx_data <= ENABLE_COMMAND; //ENABLE_COMMAND <= 8'hEA
                                end
                                
                        end
				end
				SET_SAMPLE_RATE_200_STATE:
				begin
                    if(tx_done_tick) //When Transmit Done Tick Move onto next state
                    begin	
                    wr_ps2 <= 0;
                        state <= GET_ACK_STATE;
                        state_after_ack <= SEND_DECIMAL_200_STATE;

                    end
				end
				SET_SAMPLE_RATE_100_STATE:
				begin
				    if(tx_done_tick)  //When Transmit Done Move onto next state
					begin
						wr_ps2 <= 0;
						state <= GET_ACK_STATE;
						state_after_ack <= SEND_DECIMAL_100_STATE;
					end
				end
				SET_SAMPLE_RATE_80_STATE:
				begin
				    if(tx_done_tick) //When Transmit done move onto next state
					begin
						wr_ps2 <= 0;
						state <= GET_ACK_STATE;
						state_after_ack <= SEND_DECIMAL_80_STATE;
					end
				end		
				SEND_DECIMAL_200_STATE:
				begin
				    if(tx_done_tick)
					begin
						wr_ps2 <= 0;
						state <= GET_ACK_STATE;
						state_after_ack <= SET_SAMPLE_RATE_100_STATE;
					end			
				end
				SEND_DECIMAL_100_STATE:
				begin
				    if(tx_done_tick)
					begin
						wr_ps2 <= 0;
						state <= GET_ACK_STATE;
						state_after_ack <= SET_SAMPLE_RATE_80_STATE;
					end
				end
				SEND_DECIMAL_80_STATE:
				begin
				    if(tx_done_tick)
					begin
						wr_ps2 <= 0;
						state <= GET_ACK_STATE;
						state_after_ack <= READ_DEVICE_TYPE_STATE;
					end
				end
				READ_DEVICE_TYPE_STATE:
				begin
				    if (tx_done_tick)
                    begin
                        scroll_mode_set <= 1;  
                        //Once Read Device Type is requested and 
                        //mouse responds with Mouse ID of 8'h03 
                        //then the scrolling mode is done
                        state <= GET_ACK_STATE;
                        state_after_ack <= GET_ID_STATE;
                        wr_ps2 <= 0;
                    end
				end
				SET_EN_STATE:
				begin
				    if(tx_done_tick)
                    begin
                        wr_ps2 <= 0;
                        state <= GET_ACK_STATE;
                        state_after_ack <= GET_PACKET1_STATE;
                    end
				end
				GET_PACKET1_STATE:  //Overflow (Y,X), Sign, Button Bits
				begin
					streaming <= 1;
					if (rx_done_tick)
					begin
							wr_ps2 <= 0;
							state <= GET_PACKET2_STATE;
							overflowX <= rx_data[6];
							overflowY <= rx_data[7];
							signX <= rx_data[4];
							signY <= rx_data[5];
							buttonPressed <= rx_data[2:0];
							data_z_ready <= 0;  //We do not want to keep this more than one duration of a packet
					end
				end								
				GET_PACKET2_STATE: //X Movement Bits
				begin
						streaming <= 1;
						if (rx_done_tick)
						begin
							//When mouse has transmitted to FPGA
							//this is when receive is done and data is ready
							data_x_ready <= 1;
							wr_ps2 <= 0;
							state <= GET_PACKET3_STATE;
							xMovement[7:0] <= rx_data;
						end
				end
				GET_PACKET3_STATE:  //Y Movement Bits
				begin
						streaming <= 1;
						//Streaming <= 1 Means that Mouse is reporting stream data to FPGA
						if (rx_done_tick)
						begin
							//When Y is done being received make data Y ready 0
							data_x_ready <= 0;
							data_y_ready <= 1;
							//PS2 is writing to FPGA therefore FPGA is not writing to PS2 mouse
							wr_ps2 <= 0;
							state <= GET_PACKET4_STATE;
							yMovement[7:0] <= rx_data; //Assign Y Movement from current received packet
						end
				end
				GET_PACKET4_STATE:  //Z Movement Bits
				begin
						//Streaming <= 1 Means that Mouse is reporting stream data to FPGA
						streaming <= 1;
						if (rx_done_tick)
						begin
							//Deassert y ready because we are in the 4th packet (Z packet)
							data_y_ready <= 0;
							data_z_ready <= 1;
							//PS2 is writing to FPGA therefore FPGA is not writing to PS2 mouse
							zMovement[7:0] <= rx_data; //Added to capture bus data for Z Movement
							signZ <= rx_data[3];
							wr_ps2 <= 0;
							state <= GET_PACKET1_STATE;		
						end
					end
			endcase	
		end
	end	
		
endmodule
