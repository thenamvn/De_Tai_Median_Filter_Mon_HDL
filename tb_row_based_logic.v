`include "common.vh"
`timescale 1ps/1ps

module tb_row_based_logic();
    reg CLK;
    reg RST;
    reg row_based_clear;
    reg row_based_update;
    reg [9:0] width;
    wire [`ADDR_WIDTH-1:0] row_based;
    
    // Declare registers to implement the row_based logic
    reg [`ADDR_WIDTH-1:0] row_based_r;
    
    // Implement the row_based logic
    assign row_based = row_based_r;
    
    // Clock generation
    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) CLK = ~CLK;
    
    // Implement the row_based logic from the median_filter_unit.v
    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            row_based_r <= 18'd0;
        end
        else begin
            if(row_based_clear) begin
                row_based_r <= 18'd0;
            end
            else begin
                if(row_based_update) begin
                    row_based_r <= row_based_r + width;
                end
                else begin
                    row_based_r <= row_based_r;
                end
            end
        end
    end
    
    initial begin
        // Initialize inputs
        CLK = 0;
        RST = 0;
        row_based_clear = 0;
        row_based_update = 0;
        width = 10'd100;
        
        // Reset
        #(CLK_PERIOD*2);
        RST = 1;
        
        // Test row_based_update
        #(CLK_PERIOD);
        row_based_update = 1;
        #(CLK_PERIOD);
        row_based_update = 0;
        
        // Check if row_based is updated with width
        #(CLK_PERIOD);
        if(row_based == 100)
            $display("row_based correctly updated to: %d", row_based);
        else
            $display("ERROR: row_based not updated correctly. Got: %d, expected: 100", row_based);
        
        // Update again
        row_based_update = 1;
        #(CLK_PERIOD);
        row_based_update = 0;
        
        // Check if row_based is updated with 2*width
        #(CLK_PERIOD);
        if(row_based == 200)
            $display("row_based correctly updated to: %d", row_based);
        else
            $display("ERROR: row_based not updated correctly. Got: %d, expected: 200", row_based);
        
        // Test row_based_clear
        row_based_clear = 1;
        #(CLK_PERIOD);
        row_based_clear = 0;
        
        // Check if row_based is cleared
        #(CLK_PERIOD);
        if(row_based == 0)
            $display("row_based correctly cleared to: %d", row_based);
        else
            $display("ERROR: row_based not cleared correctly. Got: %d, expected: 0", row_based);
        
        // Change width and update
        width = 10'd200;
        row_based_update = 1;
        #(CLK_PERIOD);
        row_based_update = 0;
        
        // Check if row_based is updated with new width
        #(CLK_PERIOD);
        if(row_based == 200)
            $display("row_based correctly updated to: %d with new width", row_based);
        else
            $display("ERROR: row_based not updated correctly with new width. Got: %d, expected: 200", row_based);
        
        // Finish simulation
        #(CLK_PERIOD*2);
        $finish;
    end
    
    // Monitor the outputs
    initial begin
        $monitor("Time: %t, RST: %b, row_based_clear: %b, row_based_update: %b, width: %d, row_based: %d", 
                 $time, RST, row_based_clear, row_based_update, width, row_based);
    end
endmodule