`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:    
// Engineer:    Vahe Jabagchourian
// 
// Create Date: 01/31/2023 12:19:19 PM
// Design Name: 
// Module Name: ps2tx_tb
// Project Name: GPU
// Target Devices:
// Tool Versions: 
// Description: 
//    Check if PS2 Clock Line Goes Low in TestBench for at least 100ms
// Dependencies: 
//     ps2tx.sv - Transmitter Module UUT
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ps2tx_tb;
    logic clk, reset;
    logic wr_ps2, rd_ps2_packet;
    logic [7:0] ps2_tx_data;
    logic [7:0] ps2_rx_data;
    logic ps2_tx_idle, ps2_rx_buf_empty;
    logic ps2c_to_host;
    // declaration
    logic rx_idle, tx_idle, rx_done_tick, tx_done_tick;
    logic [7:0] rx_data;
    logic done;
    wire ps2c, ps2d, ps2c_out, ps2d_out;
    logic tri_c_host, tri_c;
    logic toggleClock, countData;
    logic started;
    int countVal, cycleCount, clockLowCount, dataLowCount;
    
    pullup(ps2d);
    pullup(ps2c);
    
    assign ps2c = (tri_c_host)? ps2c_to_host: 1'bz;
    
    typedef enum {idle, waitr, rts, start, data, stop} state_type;
    state_type START_STATE = start;
    state_type STOP_STATE = stop;
    // body
    // instantiate ps2 transmitter
    ps2tx ps2_tx_unit
    (    
         .clk(clk), 
         .reset(reset), 
         .wr_ps2(wr_ps2), 
         .rx_idle(rx_idle), 
         .din(ps2_tx_data), 
         .tx_idle(tx_idle), 
         .tx_done_tick(tx_done_tick),
         .ps2c(ps2c),
         .ps2d(ps2d),
         .tri_c(tri_c),
         .tri_d(tri_d),
         .ps2c_out(ps2c_out),
         .ps2d_out(ps2d_out)
    );
    
    
    initial
    begin
        clk = 0;
        countVal = 0;
        reset = 0;
        done = 0;
        toggleClock = 0;
        tri_c_host = 0;
        cycleCount = 0;
        clockLowCount = 0;
        dataLowCount = 0;
        countData = 0;
        started = 0;
        #100;
        reset = 1;
        #100;
        reset = 0;
        wr_ps2 = 1;
        ps2_tx_data = 8'hFF;
        rx_idle = 1;
        #2000000 $finish;
    end
    
    always@(posedge clk)
    begin
       if (!ps2c)
       begin
           clockLowCount <= clockLowCount + 1;
       end
       
       if (toggleClock)
       begin
           if (countVal < 8000)
                countVal <= countVal + 1; 
           else
           begin
                countVal <= 0;
                if (!done)
                    cycleCount <= cycleCount + 1;
           end  
           
           if (cycleCount == 11)
           begin
               done <= 1;
           end
           else
           begin
                done <= 0;
           end
       end          
    end
    
    always @(posedge clk)
    begin
        if (clockLowCount >= 10000)
        begin
            countData <= 1;    
        end
        
        if (countData && !ps2d)
        begin
          dataLowCount <= dataLowCount + 1;   
        end
        
        if (countData && ps2c && !started)
        begin
           ps2c_to_host <= 1'b0;
           started <= 1'b1;
        end
        
        if (dataLowCount == 8000)
        begin
            toggleClock <= 1;
        end
    end

    always @(*)
    begin
        if (!done && toggleClock == 1)
        begin
            tri_c_host = 1;
            if (countVal < 4000)
            begin
                ps2c_to_host = 0;
            end
            else if (countVal >= 4000)
            begin
                ps2c_to_host = 1;
            end
        end
        else
        begin
           tri_c_host = 0;
        end
    end
    
    always
    begin
        #5 clk = ~clk;
    end
    
endmodule