`include "common.vh"
`timescale 1ps/1ps

module tb_counter_10_bit();
    reg CLK;
    reg RST;
    reg increment_i;
    reg clear_i;
    wire [9:0] count_o;
    
    // Instantiate the Unit Under Test (UUT)
    counter_10_bit uut(
        .CLK(CLK),
        .RST(RST),
        .increment_i(increment_i),
        .clear_i(clear_i),
        .count_o(count_o)
    );
    
    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) CLK = ~CLK;
    
    initial begin
        // Initialize inputs
        CLK = 0;
        RST = 0;  // Active low reset
        increment_i = 0;
        clear_i = 0;
        
        // Wait for global reset
        #(CLK_PERIOD*2);
        RST = 1;  // Release reset
        
        // Test increment functionality
        increment_i = 1;
        #(CLK_PERIOD*10);
        
        // Test hold functionality
        increment_i = 0;
        #(CLK_PERIOD*3);
        
        // Test increment again
        increment_i = 1;
        #(CLK_PERIOD*5);
        
        // Test synchronous clear
        clear_i = 1;
        #(CLK_PERIOD*2);
        clear_i = 0;
        
        // Test increment after clear
        #(CLK_PERIOD*5);
        
        // Test asynchronous reset
        RST = 0;
        #(CLK_PERIOD*2);
        RST = 1;
        
        // Finish simulation
        #(CLK_PERIOD*5);
        $finish;
    end
    
    // Monitor the outputs
    initial begin
        $monitor("Time: %t, RST: %b, increment_i: %b, clear_i: %b, count_o: %d", 
                 $time, RST, increment_i, clear_i, count_o);
    end
endmodule