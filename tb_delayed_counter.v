`include "common.vh"
`timescale 1ps/1ps

module tb_delayed_counter();
    reg CLK;
    reg RST;
    reg [3:0] counter_window;
    reg start_bubble_sort;
    wire [3:0] delayed_counter_window;
    wire delay_start_bubble_sort;
    wire delay_2clk_start_bubble_sort;
    
    // Registers to implement the delay logic
    reg [3:0] delayed_counter_window_r;
    reg delay_start_bubble_sort_r;
    reg delay_2clk_start_bubble_sort_r;
    
    // Assign outputs
    assign delayed_counter_window = delayed_counter_window_r;
    assign delay_start_bubble_sort = delay_start_bubble_sort_r;
    assign delay_2clk_start_bubble_sort = delay_2clk_start_bubble_sort_r;
    
    // Clock generation
    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) CLK = ~CLK;
    
    // Implement the delay logic from median_filter_unit.v
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            delayed_counter_window_r <= 4'd0;
            delay_start_bubble_sort_r <= 1'b0;
            delay_2clk_start_bubble_sort_r <= 1'b0;
        end
        else begin
            delayed_counter_window_r <= counter_window;
            delay_start_bubble_sort_r <= start_bubble_sort;
            delay_2clk_start_bubble_sort_r <= delay_start_bubble_sort;
        end
    end
    
    initial begin
        // Initialize inputs
        CLK = 0;
        RST = 0;
        counter_window = 4'd0;
        start_bubble_sort = 0;
        
        // Reset
        #(CLK_PERIOD*2);
        RST = 1;
        
        // Test delay of counter_window
        counter_window = 4'd5;
        #(CLK_PERIOD);
        if(delayed_counter_window == 4'd5)
            $display("delayed_counter_window correctly delayed by 1 clock: %d", delayed_counter_window);
        else
            $display("ERROR: delayed_counter_window not delayed correctly. Got: %d, expected: 5", delayed_counter_window);
        
        counter_window = 4'd8;
        #(CLK_PERIOD);
        if(delayed_counter_window == 4'd8)
            $display("delayed_counter_window correctly updated to: %d", delayed_counter_window);
        else
            $display("ERROR: delayed_counter_window not updated correctly. Got: %d, expected: 8", delayed_counter_window);
        
        // Test 2-stage delay of start_bubble_sort
        start_bubble_sort = 1;
        #(CLK_PERIOD);
        if(delay_start_bubble_sort == 1 && delay_2clk_start_bubble_sort == 0)
            $display("start_bubble_sort correctly delayed by 1 clock");
        else
            $display("ERROR: start_bubble_sort delay incorrect after 1 clock");
        
        #(CLK_PERIOD);
        if(delay_start_bubble_sort == 1 && delay_2clk_start_bubble_sort == 1)
            $display("start_bubble_sort correctly delayed by 2 clocks");
        else
            $display("ERROR: start_bubble_sort delay incorrect after 2 clocks");
        
        // Turn off signal and check delay chain
        start_bubble_sort = 0;
        #(CLK_PERIOD);
        if(delay_start_bubble_sort == 0 && delay_2clk_start_bubble_sort == 1)
            $display("start_bubble_sort=0 correctly delayed by 1 clock");
        else
            $display("ERROR: start_bubble_sort=0 delay incorrect after 1 clock");
        
        #(CLK_PERIOD);
        if(delay_start_bubble_sort == 0 && delay_2clk_start_bubble_sort == 0)
            $display("start_bubble_sort=0 correctly delayed by 2 clocks");
        else
            $display("ERROR: start_bubble_sort=0 delay incorrect after 2 clocks");
        
        // Finish simulation
        #(CLK_PERIOD*2);
        $finish;
    end
    
    // Monitor the outputs
    initial begin
        $monitor("Time: %t, RST: %b, counter_window: %d, start_bubble_sort: %b, delayed_counter_window: %d, delay_start_bubble_sort: %b, delay_2clk_start_bubble_sort: %b", 
                 $time, RST, counter_window, start_bubble_sort, delayed_counter_window, delay_start_bubble_sort, delay_2clk_start_bubble_sort);
    end
endmodule