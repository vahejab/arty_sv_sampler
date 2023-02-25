`timescale 1ns / 1ps

// Testbench
module testbench;
    reg sysclk_p;
    reg sysclk_n;
    reg reset;
    wire ps2c, ps2d;
    wire tx, rx;
    
    top system(
     .sysclk_p(sysclk_p),
     .sysclk_n(sysclk_n),
     .reset(reset),
     .clk_mouse(ps2c),
     .data_mouse(ps2d),
     .clk_module(ps2c),
     .data_module(ps2d),
     .rx(tx),
     .tx(rx)
    );

    always
    begin
        #2.5 sysclk_p = ~sysclk_p;
             sysclk_n = ~sysclk_n;
    end
    
    initial begin
        reset = 0;
        sysclk_p = 0;
        sysclk_n = 1;
        #100 reset = 1;
        #10 reset = 0;
    end
endmodule