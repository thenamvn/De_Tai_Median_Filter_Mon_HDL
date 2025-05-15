`include "common.vh"
`timescale 1ps/1ps

module tb_bubble_sort_unit(
);
    reg CLK;
    reg RST;
    reg start_i;
    reg [`BIT_WIDTH-1:0] in_data0_i;
    reg [`BIT_WIDTH-1:0] in_data1_i;
    reg [`BIT_WIDTH-1:0] in_data2_i;
    reg [`BIT_WIDTH-1:0] in_data3_i;
    reg [`BIT_WIDTH-1:0] in_data4_i;
    reg [`BIT_WIDTH-1:0] in_data5_i;
    reg [`BIT_WIDTH-1:0] in_data6_i;
    reg [`BIT_WIDTH-1:0] in_data7_i;
    reg [`BIT_WIDTH-1:0] in_data8_i;

    wire [`BIT_WIDTH-1:0] out_data0_o;
    wire [`BIT_WIDTH-1:0] out_data1_o;
    wire [`BIT_WIDTH-1:0] out_data2_o;
    wire [`BIT_WIDTH-1:0] out_data3_o;
    wire [`BIT_WIDTH-1:0] out_data4_o;
    wire [`BIT_WIDTH-1:0] out_data5_o;
    wire [`BIT_WIDTH-1:0] out_data6_o;
    wire [`BIT_WIDTH-1:0] out_data7_o;
    wire [`BIT_WIDTH-1:0] out_data8_o;
    wire valid_o;

    bubble_sort_unit uut(
        .CLK(CLK),
        .RST(RST),
        .start_i(start_i),
        .in_data0_i(in_data0_i),
        .in_data1_i(in_data1_i),
        .in_data2_i(in_data2_i),
        .in_data3_i(in_data3_i),
        .in_data4_i(in_data4_i),
        .in_data5_i(in_data5_i),
        .in_data6_i(in_data6_i),
        .in_data7_i(in_data7_i),
        .in_data8_i(in_data8_i),

        .out_data0_o(out_data0_o),
        .out_data1_o(out_data1_o),
        .out_data2_o(out_data2_o),
        .out_data3_o(out_data3_o),
        .out_data4_o(out_data4_o),
        .out_data5_o(out_data5_o),
        .out_data6_o(out_data6_o),
        .out_data7_o(out_data7_o),
        .out_data8_o(out_data8_o),

        .valid_o(valid_o)
    );
    parameter CLK_PERIOD = 10;
    
    // Function to display messages
    task display;
        input [1000:0] message;
        begin
            $display(message);
        end
    endtask
    
    always #(CLK_PERIOD/2) begin
        CLK = ~CLK;
    end
    
    initial begin
        CLK = 1'b0;
        RST = 1'b0;
        start_i = 1'b0;

        //mang truoc khi sap xep
        // 9 3 7 1 4 6 8 2 5
        in_data0_i = 9;
        in_data1_i = 3;
        in_data2_i = 7;
        in_data3_i = 1;
        in_data4_i = 4;
        in_data5_i = 6;
        in_data6_i = 8;
        in_data7_i = 2;
        in_data8_i = 5;

        $display("Input data: %d %d %d %d %d %d %d %d %d", in_data0_i, in_data1_i, in_data2_i, in_data3_i, in_data4_i, in_data5_i, in_data6_i, in_data7_i, in_data8_i);

        #(CLK_PERIOD) RST = 1'b1;
        #(CLK_PERIOD) start_i = 1'b1;
        #(CLK_PERIOD) start_i = 1'b0;

        while (~valid_o) begin
            #(CLK_PERIOD);
        end

        $display("Output data: %d %d %d %d %d %d %d %d %d", out_data0_o, out_data1_o, out_data2_o, out_data3_o, out_data4_o, out_data5_o, out_data6_o, out_data7_o, out_data8_o);
        #(CLK_PERIOD) $finish;
    end

endmodule