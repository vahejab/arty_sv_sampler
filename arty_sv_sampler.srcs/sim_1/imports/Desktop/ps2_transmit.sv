module ps2_transmit (
    input wire          clkIn,
    input wire          rst,
    input wire [7:0]     data_in,
    input wire          send_data,
    output reg      data_out,
    output reg      clk_out,
    output reg      send_ack,
    output reg      transmitting
);
    // Shift register to transmit data
    reg [8:0] shift_reg;

    // State machine to handle transmit states
    localparam IDLE = 3'b000, START_BIT = 3'b001, DATA_BITS = 3'b010, PARITY_BIT = 3'b011, STOP_BIT = 3'b100;
    reg [2:0] tx_state;

    reg [14:0] clkCount = 0;
    reg [14:0] countPeriod = 10000;
    reg [3:0] bits;
    assign transmitting = (tx_state != IDLE)? 1'b1: 1'b0;
   
    always @(posedge clkIn) begin
      if (clkCount <= countPeriod) begin
        clkCount <= clkCount + 1;
      end else begin
        clkCount <= 0;
      end
    end
    
    always @(posedge clkIn) begin
        if (rst) begin
            shift_reg <= 8'b0;
            tx_state <= IDLE;
            bits <= 0;
        end else begin
            case (tx_state)
                IDLE: begin
                    bits = 0;
                    send_ack <= 1'b0;
                    //clk_out <= 1'b1;
                    //data_out <= 1'b1;
                    if (send_data) begin
                        shift_reg <= {data_in, 1'b0}; // load data with a 0 as start bit
                        tx_state <= START_BIT;
                    end
                end
                START_BIT: begin
                    clk_out <= (clkCount < countPeriod/2)? 1'b0: 1'b1;
                    if (clkCount == countPeriod/2) begin      
                        data_out <= shift_reg[0];           
                        shift_reg <= {1'b0,shift_reg[8:1]};
                    end
                    tx_state <= (clkCount == countPeriod)? DATA_BITS: START_BIT;
                end
                DATA_BITS: begin
                    clk_out <= (clkCount < countPeriod/2)? 1'b0: 1'b1;
                    bits <= (clkCount == countPeriod)? bits + 1: bits;
                    if (clkCount == countPeriod/2 && bits <= 8) begin
                        data_out <= shift_reg[0];
                        shift_reg <= {1'b0,shift_reg[8:1]};
                    end
                    tx_state <= (clkCount == countPeriod && bits == 8)? PARITY_BIT: DATA_BITS;
                end
                PARITY_BIT: begin
                    clk_out <= (clkCount < countPeriod/2)? 1'b0: 1'b1;
                    if (clkCount == countPeriod/2) begin      
                        data_out <= shift_reg[0];           
                        shift_reg <= {1'b0,shift_reg[8:1]};
                    end
                    tx_state <= (clkCount == countPeriod)? STOP_BIT: PARITY_BIT;
                end
                STOP_BIT: begin
                    clk_out <= (clkCount < countPeriod/2)? 1'b0: 1'b1;
                    if (clkCount == countPeriod/2) begin
                        data_out <= shift_reg[0];
                        shift_reg <= {1'b0, shift_reg[8:1]};
                    end                
                    send_ack <= (clkCount == countPeriod/2)? 1'b1: 1'b0; 
                    tx_state <= (clkCount == countPeriod)? IDLE: STOP_BIT;
                end
            endcase
        end
    end
endmodule