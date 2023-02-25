/****************************************************************************
*  Module Name:             mouse_xyz_tb
*  File Name:               mouse_xyz_tb.v
*  
*  Author:                  Vahe Robert Jabagchourian
*                           California State University Northridge
*
*  Creation Date:           November 15, 2010
*  Description:             Emulates PS/2 Mouse Device  by trnasmitting
*									 and recieving packets to FPGA mouseInterface
*									 Transmits up/down, left/right movement from
*									 using PS/2 mouse packets.
*
*	Revisions
*	
*	November 15, 2010			 Initial Testbench created
*	February 12, 2011			 xPosition changed to 9 bits
*	February 15, 2011			 Removed set sample rate 10 state in
*									 state decode and revised 5 bit state values
*									 setIndex changed from 5 bit value to 4 bit value
*	February 16, 2011			 Test bench states revised to work with less than
*									 16 states to be consistent with the removal of
*									 Send 40, Send 10 States to mouse
*	February 17, 2011			 Removed set scaling rate 1:1 and set resolution
*									 Re assigned state values to match new state set
****************************************************************************/

`timescale 1ns / 1ps

module mouse_xyz_tb;

	// Inputs
	reg clk;
	reg reset;
	
	// Bi-Directional Signals from Mouse
	reg PS2C_gen;
	reg PS2D_gen;
	
	// Enable Control
	reg PS2C_en;
	reg PS2D_en;
	
	reg [7:0] DATA_in;
	reg Parity, Stop;
	reg Start;

	// Outputs
	wire [2:0] btnm;
	wire [4:0] state;
	
	wire [8:0] xPosition;
	wire [8:0] yPosition;

	reg USER_CLK;
	wire [12:0] LED;

	// Bidirs
	wire PS2D;
	wire PS2C;
	
	wire tri_c;
	wire tri_d;
	wire ps2c_out;
	wire ps2d_out;
	
	pullup r1 (PS2D);
	pullup r2 (PS2C);

    reg [11:0] clk_low_count = 0;

	reg [10:0] SDPS;
	reg [7:0] Data_out;

	// String Holders for Current State Machine Values
	reg [8*28:0] state_decode;
	reg [8*28:0] send_receive_state;
	reg [8*28:0] bit_received_state;
	reg [8*28:0] tx_state_decode;
	reg streamingMode = 0;
	reg requestToSend = 0;
	reg [4:0] setIndex = 0;

	wire [2:0] state_reg;
	wire [12:0] led;
	
	// Instantiate the Unit Under Test (UUT)
	wire I2C_SCL_DVI;
	wire I2C_SDA_DVI;
	wire XCLK_P;
	wire XCLK_N;
	wire H_SYNC;
	wire V_SYNC;
	wire DATA_ENABLE;
	wire [11:0] DATA_OUT;

// Instantiate the module
mcs_top_heat_arty_a7 mod (
    .sysclk_p(USER_CLK), 
    .sysclk_n(~USER_CLK),
    .reset(reset), 
    .ps2c(PS2C), 
    .ps2d(PS2D), 
    .ps2c_out(ps2c_out),
    .ps2d_out(ps2d_out),
    .tri_c(tri_c),
    .tri_d
    .tx(),
    .rx()
    );



	initial
	begin
		DATA_in = 0;
		clk = 0;
		USER_CLK = 0;
		reset = 0;
		PS2C_en = 0;
		PS2C_gen = 0;
		PS2D_en = 0;
		PS2D_gen = 0;
		#100 reset = 1;
		#10 reset = 0;
	end

	task receive;  // 11 bits (1 data packet)
	begin
			PS2C_en = 0;  //high
			#25000 PS2C_en = 1;  //low
			//Data
			repeat (8)
			begin
				#25000 PS2C_en = 0;  //high
				DATA_in = {DATA_in[6:0], PS2D};  //shift in data bits
				#25000 PS2C_en = 1;  //low
			end
			//Partiy
			#25000 PS2C_en = 0;
			 Parity = PS2D;
			#25000 PS2C_en = 1;
			#25000 PS2C_en = 0;
			 Stop = PS2D;
			 if (Stop == 1)
			 begin
				#25000 PS2D_gen = 0;  PS2D_en = 1; PS2C_en = 1; 
				#25000 PS2D_en = 0;   PS2C_en = 0; //release the clock and data
			 end
			 //Reception Complete
	end	
	endtask	

	task transmit;
	input [10:0] DATA;
	begin
					Start = 0;
					 Data_out = DATA;  //ACK
					 Parity = ~(^Data_out);
					 Stop = 1;
					 
					 SDPS = {Start, Data_out[0], Data_out[1],Data_out[2],Data_out[3],Data_out[4],Data_out[5],Data_out[6],Data_out[7], Parity, Stop}; //Start Data Parity Stop Packet
					 
					//send acknowledge 
					repeat (11)
					begin
						#25000 PS2C_en = 1;  //low
						PS2D_gen = 0;
						PS2D_en = (SDPS[10])? 0: 1;
						SDPS = SDPS << 1;
						#25000 PS2C_en = 0;  //high
						
					end
	end
	endtask

	//transmitSet - where mouse transmits data
	//to the FPGA PS2 transceiver module
	task transmitSet;
	input [4:0] setIndex;
	begin
		case (setIndex)
			0:		//BASIC ASSURANCE TEST REPORT
			begin
				transmit(8'hFA);
				transmit(8'hAA);
				transmit(8'h00);
			end
			//removed transmitSet 12 - Set sample rate 40,
			//removed transmitSet 13 - Set Decimal 40,
			//removed transmitSet 14 - Set sample rate 10
			//removed transmitSet 15 - Set Decimal 10
			//Added a number 10 state
			1,2,3,4,5,6:  //ACKNOWLEDGE
			begin
				transmit(8'hFA);
			end
			7:	//Get Mouse ID
			begin
				transmit(8'hFA);
				transmit(8'h03);
			end
			8:  //Set Enable State Acknowledge
			begin
				transmit(8'hFA);
				streamingMode = 1;
			end
			default:
			begin
				 
			end
		endcase
	
	end
	endtask

	always @(posedge USER_CLK)
	begin
		if (~PS2C)
		begin
				clk_low_count = clk_low_count + 1;
				if (clk_low_count == 12'hfff)
				begin
						requestToSend = 1;
				end	
		end
		else
		begin
			clk_low_count = 0;
		end
	end

	always @(PS2D or requestToSend or setIndex)
	begin
		if (~PS2D && requestToSend==1 && setIndex <= 8)
		begin
			clk_low_count = 0;
			requestToSend = 0;
			receive();
			transmitSet(setIndex);
			setIndex = setIndex + 1;
		end
	end

	always @(streamingMode)
	begin

		if (streamingMode)
		begin
			//Stream Data
			
			//Mouse Command Signals
			//Move up one (20 times)		
			//0x08,0x00,0x01
	
			repeat(10)//1 substituted in for 7F
			begin
			transmit(8'h08);
			transmit(8'h0F);
			transmit(8'h00);
			transmit(8'h00);
			//transmit(8'h1F);			
			//transmit(8'h0F);
			//transmit(8'h0F);
			end

			
			/*/Press left button
			//0x09,0x00,0x00
			transmit(8'h09);
			transmit(8'h00);		
			transmit(8'h00);
			transmit(8'h00);
			//Release left button
			//0x08,0x00,0x00
			transmit(8'h08);
			transmit(8'h00);		
			transmit(8'h00);
			transmit(8'h00);
			//Press middle button
			//0x0C,0x00,0x00
			transmit(8'h0C);
			transmit(8'h00);		
			transmit(8'h00);
			transmit(8'h00);
			//Release middle button
			//0x08,0x00,0x00
			transmit(8'h08);
			transmit(8'h00);		
			transmit(8'h00);
			transmit(8'h00);
			//Press right button
			//0x0A,0x00,0x00
			transmit(8'h0A);
			transmit(8'h00);		
			transmit(8'h00);											
			transmit(8'h00);
			//Release right button	
			//0x08,0x00,0x00
			transmit(8'h08);
			transmit(8'h00);		
			transmit(8'h00);
			transmit(8'h00);					
			#200 $finish;	
		end
	end	
					

	always
	begin
		#40 clk = ~clk;
	end


	always
	begin
		#2.5 USER_CLK = ~USER_CLK;
	end

//	// Mouse Controller State Machine Values
//    always @(gpuTop.mouseMovementAdder.mousePacketControlUnit.state)
//	begin
	
//			$display ("%s", state_decode);
	
//		if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b00000) //0
//		begin
//			 state_decode = "IDLE_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b00001) //1
//		begin
//			 state_decode = "RESET_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state  == 5'b00010) //2
//		begin
//			state_decode = "GET_ACK_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state  == 5'b00011) //3
//		begin
//			state_decode = "GET_BAT_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b00100) //4
//		begin
//			 state_decode = "GET_ID_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b00101) //5
//		begin
//			 state_decode = "SET_SAMPLE_RATE_200_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b00110) //6
//		begin
//			 state_decode = "SET_SAMPLE_RATE_100_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b00111) //7
//		begin
//			 state_decode = "SET_SAMPLE_RATE_80_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01000) //8
//		begin
//			state_decode = "SEND_DECIMAL_200_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01001) //9
//		begin
//			state_decode = "SEND_DECIMAL_100_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01010) //10
//		begin
//			state_decode = "SEND_DECIMAL_80_STATE";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01011) //11
//		begin
//			state_decode = "READ_DEVICE_TYPE_STATE";
//		end			
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01100) //12
//		begin
//			state_decode = "SET_EN_STATE";
//		end		
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01101) //13
//		begin
//			state_decode = "GET_PACKET1";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01110) //14
//		begin
//			state_decode = "GET_PACKET2";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b01111) //15
//		begin
//			state_decode = "GET_PACKET3";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.state == 5'b10000) //16
//		begin
//			state_decode = "GET_PACKET4";
//		end		
//	end
	
//	// Mouse Controller Send Recieve State
//	always @(gpuTop.mouseMovementAdder.mousePacketControlUnit.wr_ps2)
//	begin
//		if (gpuTop.mouseMovementAdder.mousePacketControlUnit.wr_ps2 == 1'b1)
//		begin
//			send_receive_state = "CONTROLLER_SENDING";
//		end
//		else if (gpuTop.mouseMovementAdder.mousePacketControlUnit.wr_ps2 == 1'b0)
//		begin
//			send_receive_state = "CONTROLLER_RECEIVING";
//		end
//	end
	
//	always @(gpuTop.mouseMovementAdder.ps2_transceiver.tx_state_reg)
//	begin
//		if (gpuTop.mouseMovementAdder.ps2_transceiver.tx_state_reg == 3'b000)
//		begin
//			tx_state_decode = "IDLE";
//		end
//		else if (gpuTop.mouseMovementAdder.ps2_transceiver.tx_state_reg == 3'b001)
//		begin
//			tx_state_decode = "REQUEST TO SEND";
//		end
//		else if (gpuTop.mouseMovementAdder.ps2_transceiver.tx_state_reg == 3'b010)
//		begin
//			tx_state_decode = "START"; 
//		end
//		else if (gpuTop.mouseMovementAdder.ps2_transceiver.tx_state_reg == 3'b011)
//		begin
//			tx_state_decode = "DATA"; 
//		end
//		else if (gpuTop.mouseMovementAdder.ps2_transceiver.tx_state_reg == 3'b100)
//		begin
//			tx_state_decode = "STOP"; 
//		end

//	end

	// tri-state buffers
	assign PS2C = (PS2C_en) ? PS2C_gen : 1'bz;
	assign PS2D = (PS2D_en) ? PS2C_gen : 1'bz;


endmodule
