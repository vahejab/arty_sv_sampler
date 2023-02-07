/***********************************************************************************
* Module: ps2_txrx
* Author: Dr. Pong Chu Cleveland State University, Ohio
* Modified by: Vahe Jabagchouiran
* Modifications:
* August 13, 2011 		Consolidated ps2_tx / ps2_rx into a single module
*								to resolve feedback issue into eachother in XST.
***********************************************************************************/



module ps2_txrx(clk, reset, wr_ps2, din, ps2d, ps2c, ps2c_out, ps2d_out, tri_c, tri_d, tx_done_tick, rx_done_tick, dout);


	input wire clk, reset;
	input wire wr_ps2;
	input wire [7:0] din;
	input wire ps2d; 
	input wire ps2c;
	output reg tx_done_tick;
	output reg ps2c_out, ps2d_out;
	output reg tri_c, tri_d;
	output reg rx_done_tick;
	output wire [7:0] dout;
	
	
	// state declaration
	

	/*************************************************************************************
	*Begin PS/2 TX Module
	*************************************************************************************/	
	
	parameter
	tx_idle_state  = 3'b000,
	rts   = 3'b001,
	start = 3'b010,
	data  = 3'b011,
	stop  = 3'b100;
	
	//signal declaration
	reg tx_idle;
	reg [2:0] tx_state_reg, tx_state_next;
	reg [7:0] tx_filter_reg;
	wire [7:0] tx_filter_next;
	reg tx_f_ps2c_reg;
	wire tx_f_ps2c_next;
	reg [3:0] tx_n_reg, tx_n_next;
	reg [8:0] tx_b_reg, tx_b_next;
	reg [11:0] tx_c_reg, tx_c_next;
	wire par, tx_fall_edge, tx_rise_edge;
	//reg ps2c_out, ps2d_out;
	//reg 

	reg ps2d_reg;

	
	//body
	//filter and falling edge tick generation for ps2c
	always @(posedge clk)
	begin
		if (!reset)
		begin
			tx_filter_reg <= 0;
			tx_f_ps2c_reg <= 0;
		    //tri_c <= 0;
		    //tri_d <= 0;
		end
		else
		begin
			tx_filter_reg <= tx_filter_next;
			tx_f_ps2c_reg <= tx_f_ps2c_next;
			ps2d_reg <= ps2d_out;
		end
	end
	
	
	assign tx_filter_next = {ps2c, tx_filter_reg[7:1]};
	assign tx_f_ps2c_next = (tx_filter_reg==8'b11111111) ? 1'b1 :
			     (tx_filter_reg==8'b00000000) ? 1'b0 :
			     tx_f_ps2c_reg;
								
   assign tx_fall_edge   = tx_f_ps2c_reg & ~tx_f_ps2c_next;
	assign tx_rise_edge   = ~tx_f_ps2c_reg & tx_f_ps2c_next;
	

	// FSMD state & data registers
	always @(posedge clk)
	if (!reset)
	 begin
	    tx_state_reg <= tx_idle_state;
	    tx_c_reg <= 0;
	    tx_n_reg <= 0;
	    tx_b_reg <= 0;
	 end
	else
	 begin
	    tx_state_reg <= tx_state_next;
	    tx_c_reg <= tx_c_next;
	    tx_n_reg <= tx_n_next;
	    tx_b_reg <= tx_b_next;
	 end

	// odd parity bit
	assign par = ~(^din);

	// FSMD next-state logic
	always @(*)
	begin
	tx_state_next = tx_state_reg;
	tx_c_next = tx_c_reg;
	tx_n_next = tx_n_reg;
	tx_b_next = tx_b_reg;
	ps2d_out = 1'b1;
	tri_c = 1'b0;
	tri_d = 1'b0;
	tx_idle = 1'b0;
	case (tx_state_reg)
	 tx_idle_state:
	    begin
			 tx_done_tick = 0;
			 tx_idle = 1'b1;
	       if (wr_ps2)
			 begin
				  tx_b_next = {par, din};
				  tx_c_next = 12'hfff;
				  tx_state_next = rts;
			 end
	    end
	 rts:   // request to send
		 begin
		    tri_c = 1'b1;
			 ps2c_out = 1'b0;
			 tx_c_next = tx_c_reg - 1;
	       if (tx_c_reg==0)
			 begin
					tx_state_next = start;
			 end
		end
	 start:  // assert start bit
	    begin
	       ps2d_out = 1'b0;
	       tri_d = 1'b1;
				if (tx_fall_edge)
				begin
				  tx_n_next = 4'h8;
				  tx_state_next = data;
				end
	    end
	 data:   //  8 data + 1 parity
	    begin
	       ps2d_out = tx_b_reg[0];
	       tri_d = 1'b1;
			 if (tx_fall_edge)
			 begin
				  tx_b_next = {1'b0, tx_b_reg[8:1]};
				  if (tx_n_reg == 0)
					 tx_state_next = stop;
				  else
					tx_n_next = tx_n_reg - 1;
				  end
			 end
	 stop:   // assume floating high for ps2d
	    begin
		 if (tx_fall_edge)
	       begin
		  tx_state_next = tx_idle_state;
		  tx_done_tick = 1'b1;
	       end
	    end
	endcase
	end

	// tri-state buffers
	//assign ps2c = (tri_c) ? ps2c_out : 1'bz;
	//assign ps2d = (tri_d) ? ps2d_out : 1'bz;
	
	
	/*************************************************************************************
	*Begin PS/2 RX Module
	*************************************************************************************/
	
	
	//state declaration
	parameter
		rx_idle = 2'b00,
		dps  = 2'b01,  // data parity stop
		load = 2'b10;
		
	//signal declaration
		
	
	wire rx_en;
	reg [1:0] rx_state_reg, rx_state_next;
	reg [7:0] rx_filter_reg;
	wire [7:0] rx_filter_next;
	reg rx_f_ps2c_reg;
	wire rx_f_ps2c_next;
	reg [3:0] rx_n_reg, rx_n_next;
	reg [10:0] rx_b_reg, rx_b_next;
	wire rx_fall_edge;
	
	reg rx_done_tick_reg;
	
	//Added to complete connection
	assign rx_en = tx_idle;
	
	
	
	//body

	//filter and falling edge tick generation for ps2c
	
	always @(posedge clk)
	begin
		if (!reset)
		begin
			rx_filter_reg <= 0;
			rx_f_ps2c_reg <= 0;
		end
		else
		begin
			rx_filter_reg <= rx_filter_next;
			rx_f_ps2c_reg <= rx_f_ps2c_next;
		end
	end
	
	assign rx_filter_next = {ps2c, rx_filter_reg[7:1]};
	assign rx_f_ps2c_next = (rx_filter_reg==8'b11111111) ? 1'b1 :
								(rx_filter_reg==8'b00000000) ? 1'b0 :
								rx_f_ps2c_reg;
								
   assign rx_fall_edge   = rx_f_ps2c_reg & ~rx_f_ps2c_next;
	
	//state and data registers
	
	always @(posedge clk)
	begin
		if (!reset)
		begin
			rx_state_reg <= rx_idle;
			rx_done_tick_reg <= 0;
			rx_n_reg <= 0;
			rx_b_reg <= 0;
		end
		else
		begin
			rx_state_reg <= rx_state_next;
			rx_done_tick_reg <= rx_done_tick;
			rx_n_reg <= rx_n_next;
			rx_b_reg <= rx_b_next;
		end
	end
	
	//next state logic
	always @(*)
	begin
		rx_state_next = rx_state_reg;
		rx_n_next = rx_n_reg;
		rx_b_next = rx_b_reg;
		rx_done_tick = rx_done_tick_reg;
		case (rx_state_reg)
			rx_idle:
			begin
					rx_done_tick = 1'b0;
					if (rx_fall_edge && rx_en)
					begin
						//shift in start bit
						rx_b_next = {ps2d, rx_b_reg[10:1]};
						rx_n_next = 4'b1001;
						rx_state_next = dps;
					end
			end
			dps: //8 data + 1 parity + 1 stop
					if (rx_fall_edge)
					begin
						rx_b_next = {ps2d, rx_b_reg[10:1]};
						if (rx_n_reg==0)
							rx_state_next = load;
						else
							rx_n_next = rx_n_reg - 1;
					end
			load:
				begin
					rx_state_next = rx_idle;
					rx_done_tick = 1'b1;
				end
		endcase
	end

	//output
	assign dout = rx_b_reg[8:1];  //data bits



endmodule