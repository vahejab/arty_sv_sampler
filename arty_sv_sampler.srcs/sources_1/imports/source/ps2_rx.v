
module ps2_rx(clk, reset, ps2d, ps2c, rx_en, rx_done_tick, dout);

	input wire clk, reset;
	input wire ps2d, ps2c, rx_en;
	output reg rx_done_tick;
	output wire [7:0] dout;
	
	//state declaration
	parameter
		rx_idle = 2'b00,
		dps  = 2'b01,  // data parity stop
		load = 2'b10;
		
	//signal declaration
	
	reg [1:0] rx_state_reg, rx_state_next;
	reg [7:0] rx_filter_reg;
	wire [7:0] rx_filter_next;
	reg rx_f_ps2c_reg;
	wire rx_f_ps2c_next;
	reg [3:0] rx_n_reg, rx_n_next;
	reg [10:0] rx_b_reg, rx_b_next;
	wire rx_fall_edge;
	
	reg rx_done_tick_reg;
	
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
