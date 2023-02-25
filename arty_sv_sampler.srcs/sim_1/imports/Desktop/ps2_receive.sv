module ps2_receive #(parameter int MOUSE_ID)(
    input wire      clkIn,
    input wire      rst,
    input wire      data_in,
    input wire      clk_in,
    input wire      send_ack,
    output reg      send_data,
    output reg [7:0]data_out,
    output reg      clk_out,
    input wire [3:0] buttons,
    input wire [15:0] x_movement,
    input wire [15:0] y_movement,
    input reg [7:0] z_movement,
    output reg receiving
);

    // State and command definitions
    typedef enum {
        S_IDLE = 0,
        S_RESET = 1,
        S_ASSURANCE_TEST = 2,
        S_RECEIVING = 3,
        S_RECEIVING_PARAM = 4,
        S_STREAMING = 5,
        S_REPORTING_ID = 6,
        S_DISABLING = 7,
        S_DISABLE_REPORTING = 8
    } PS2_STATES;
   
           
    reg [7:0] mouse_id = MOUSE_ID;
    reg [3:0] state, next_receiving_state;
    reg [7:0] rx_data, rx_buffer;
    reg [3:0] rx_bit_counter;
    reg [15:0] x_displacement, y_displacement;
    reg [7:0] z_displacement;
    reg [3:0] buttons_state;
    reg [1:0] movement_counter;
    reg rx_parity;
    reg disable_movement_counter;
    reg button_packet;
    
    reg [16:0] lowcount;
    reg ack_rcv;
    reg[20*8-1:0] test_vector_string;
    reg wr_en;
    
    reg clk = 0; 
    reg [16:0] clkCount = 0;
    int countPeriod = 1000;
    reg drive_clock, drive_data;
    reg bat = 0;
    reg host_rts = 0;
    reg reset_request_complete = 0;
   
    assign receiving = (state == S_RECEIVING)? 1'b1: 1'b0;
    
    always @(posedge clkIn) begin
        if(rst) begin
            state <= S_IDLE;
            next_receiving_state <= S_IDLE;
            data_out <= 1'b0;
            clk_out <= 1'b0;
            x_displacement <= 16'b0;
            y_displacement <= 16'b0;
            z_displacement <= 8'b0;
            buttons_state <= 4'b0;
            ack_rcv <= 1'b0;
            bat <= 1'b0;
            rx_bit_counter <= 4'b0;
            host_rts <= 0;
            reset_request_complete <= 0;
        end else begin
            case(state)
                S_IDLE: begin
                    send_data <= 1'b0;
                    if(clk_in == 1'b0) begin
                        lowcount <= lowcount+1;
                    end else begin
                        lowcount <= 0;
                    end
                    
                    if (lowcount >= 1900 && data_in == 1'b0) begin
                        host_rts <= 1'b1;
                    end
                    clkCount <= clkCount + 1; 
                    if (host_rts) begin
                        if (ack_rcv == 1'b0) begin
                            clk_out <= (clkCount < 5000)? 1'b0: 1'b1;
                            state <= (clkCount == 10000)? S_RECEIVING : S_IDLE;
                            if (clkCount == 10000) begin
                                host_rts <= 0;
                                clkCount <= 0;
                                rx_bit_counter <= 4'b0;
                            end
                        end
                    end
                end
                S_ASSURANCE_TEST: begin
                    data_out <= 8'hAA;
                    send_data <= 1'b1;
                    if (send_ack == 1'b1) begin
                        clkCount <= 0;
                        state <= S_REPORTING_ID;
                    end 
                end
                S_RESET: begin
                    data_out <= 8'hFA;
                    send_data <= 1'b1;
                    if(send_ack == 1'b1) begin
                        state <= S_ASSURANCE_TEST;
                    end
                end
                S_RECEIVING: begin
                    if (ack_rcv == 1'b0 && rx_bit_counter <= 8) begin
                       
                        if (rx_bit_counter <= 7) begin
                            rx_buffer[rx_bit_counter] <= data_in;
                            rx_parity <= rx_parity ^ data_in;
                        end
                        if (clkCount < 5000 && rx_bit_counter <= 8) begin
                            clk_out <= 1'b0;
                        end else if (clkCount >= 5000 && rx_bit_counter <= 8) begin
                            clk_out <= 1'b1;
                        end
                        rx_bit_counter <= (clkCount == 10000)? rx_bit_counter + 1'b1: rx_bit_counter; 
                    end
                    clkCount <= (clkCount <= 10000)? (clkCount + 1): 0;
                   
                    if (rx_bit_counter == 9) begin
                        if (clkCount < 5000 && !ack_rcv) begin
                            clk_out <= 1'b0;
                        end else if (clkCount >= 5000 && !ack_rcv) begin
                            clk_out <= 1'b1;
                        end
                        
                        if (clkCount == 10000) begin
                            ack_rcv <= 1'b1;
                            data_out <= 1'b0;
                            state <= next_receiving_state;
                        end
                    end  
                    if (ack_rcv) begin
                        rx_data <= rx_buffer;
                        next_receiving_state <= S_RECEIVING_PARAM; 
                    end else if (!ack_rcv) begin
                        next_receiving_state <= S_RECEIVING;
                    end
                end
                S_RECEIVING_PARAM: begin
                    rx_bit_counter <= 4'b0; 
                    if (rx_data == 8'hEA) begin
                        if (send_ack == 1'b1) begin
                            state <= S_STREAMING;
                        end 
                        data_out <= 8'hFA;
                        send_data <= 1'b1;
                    end else if (rx_data == 8'hF2) begin
                        if (send_ack == 1'b1) begin
                            state <= S_REPORTING_ID;
                        end 
                        data_out <= 8'hFA;
                        send_data <= 1'b1;         
                    end else if (rx_data == 8'hF5) begin
                        if (send_ack == 1'b1) begin
                            state <= S_DISABLING;
                        end 
                        data_out <= 8'hFA;
                        send_data <= 1'b1;
                    end else if (rx_data == 8'hFF) begin
                        state <= S_RESET;
                        rx_data <= 8'h00;
                    end
                    ack_rcv <= 1'b0;
                end
                S_STREAMING: begin
                    if (rx_data == 8'hF5) begin
                        if (send_ack == 1'b1) begin
                            state <= S_DISABLING;
                        end 
                        data_out <= 8'hFA;
                        send_data <= 1'b1;
                    end else begin
                        state <= S_STREAMING;  
                        send_data <= 1'b1;
                    end
                    case (movement_counter)
                        0: begin
                            data_out <= 8'b10000000 | buttons;
                        end
                        1: begin
                            data_out <= x_movement;
                        end
                        2: begin
                            data_out <= y_movement;
                        end
                        3: begin
                            data_out <= z_movement;
                            movement_counter <= 0;
                        end
                    endcase
                    if (send_ack == 1'b1) begin
                        movement_counter <= movement_counter + 1;
                    end
                end
                S_REPORTING_ID: begin
                    data_out <= mouse_id;
                    send_data <= 1'b1;
                    if (send_ack == 1'b1) begin
                        clkCount <= 0;
                        state <= S_IDLE;
                    end  
                end
                S_DISABLING: begin
                    state <= S_IDLE;
                end
                S_DISABLE_REPORTING: begin
                    if(rx_data == 8'hFF) begin
                        state <= S_RESET;
                    end else begin
                        send_data <= 1'b0;
                        state <= S_DISABLE_REPORTING;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
            if (send_ack == 1'b1) begin
                send_data <= 1'b0;
            end
        end
    end
 
    always @(state) begin
        case (state)
            S_IDLE: test_vector_string =                "                IDLE";
            S_RESET: test_vector_string =               "               RESET";
            S_ASSURANCE_TEST: test_vector_string =      "BASIC ASSURANCE TEST";
            S_RECEIVING: test_vector_string =           "           RECEIVING";
            S_RECEIVING_PARAM: test_vector_string =     "     RECEIVING PARAM";
            S_REPORTING_ID : test_vector_string =       "        REPORTING ID";
            S_STREAMING: test_vector_string =           "    ENABLE STREAMING";
            S_DISABLING: test_vector_string =           "           DISABLING";
            S_DISABLE_REPORTING: test_vector_string =   "   DISABLE REPORTING";
        endcase
    end
 endmodule