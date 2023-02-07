module ps2_tx(clk, reset, wr_ps2, din, ps2d, ps2c, tx_idle_state, tx_idle, tx_done_tick, tx_state_reg);

	input wire clk, reset;
	input wire wr_ps2;
	input wire [7:0] din;
	inout wire ps2d; 
	inout wire ps2c;
	output reg tx_idle, tx_done_tick;
	output [2:0] tx_state_reg;
	// state declaration
	
	parameter
	tx_idle_state  = 3'b000,
	rts   = 3'b001,
	start = 3'b010,
	data  = 3'b011,
	stop  = 3'b100;
	
	//signal declaration
	reg [2:0] tx_state_reg, tx_state_next;
	reg [7:0] tx_filter_reg;
	wire [7:0] tx_filter_next;
	reg tx_f_ps2c_reg;
	wire tx_f_ps2c_next;
	reg [3:0] tx_n_reg, tx_n_next;
	reg [8:0] tx_b_reg, tx_b_next;
	reg [11:0] tx_c_reg, tx_c_next;
	wire par, tx_fall_edge, tx_rise_edge;
	reg ps2c_out, ps2d_out;
	reg tri_c = 0, tri_d = 0;
	reg ps2d_reg;

	
	//body
	//filter and falling edge tick generation for ps2c
	always @(posedge clk)
	begin
		if (!reset)
		begin
			tx_filter_reg <= 0;
			tx_f_ps2c_reg <= 0;
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
	assign ps2c = (tri_c) ? ps2c_out : 1'bz;
	assign ps2d = (tri_d) ? ps2d_out : 1'bz;

endmodule