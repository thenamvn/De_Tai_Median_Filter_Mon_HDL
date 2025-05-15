`include "common.vh"
`timescale 1ps/1ps

module tb_median_filter_unit (
);
    reg CLK;
    reg RST;
    reg [`FULL_BIT_WIDTH-1:0] dina_i;
    reg [`MODE_ADDR_WIDTH+`ADDR_WIDTH-1:0] addra_i;
    reg wea_i;
    reg ena_i;
    reg [`FULL_BIT_WIDTH-1:0] douta_o;



    median_filter_unit median_filter_unit_inst (
        .CLK(CLK),
        .RST(RST),
        .dina_i(dina_i),
        .addra_i(addra_i),
        .wea_i(wea_i),
        .ena_i(ena_i),
        .douta_o(douta_o)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) CLK = ~CLK;

    reg [`BIT_WIDTH-1:0] read_file_mem [0:238219];
    reg [`BIT_WIDTH-1:0] read_file_out_mem [0:238219];

    initial begin
        $readmemh("/home/ntnhacker/Downloads/De_Tai_Median_Filter_Mon_HDL/noisyimg.txt", read_file_mem);
    end

    integer i, f_out;

    initial begin
        CLK = 0;
        RST = 0;
        dina_i = 0;
        addra_i = 0;
        wea_i = 0;
        ena_i = 0;
        #(CLK_PERIOD*2000) RST = 1;

        for (i = 0; i < 238220; i = i + 1) begin
            #(CLK_PERIOD);
            dina_i = read_file_mem[i];
            addra_i = i;
            wea_i = 1;
            ena_i = 1;
        end
        #(CLK_PERIOD)
        // size of image 430x554 = 238220
        dina_i = 430;
        addra_i = 2'b10 << 18;
        wea_i = 1;
        ena_i = 1;
        #(CLK_PERIOD)
        dina_i = 554;
        addra_i = 2'b11 << 18;
        wea_i = 1;
        ena_i = 1;
        #(CLK_PERIOD)
        // start median filter
        dina_i = 1;
        addra_i = 2'b01 << 18;
        wea_i = 1;
        ena_i = 1;
        #(CLK_PERIOD)

        while (douta_o != 32'd1) begin
            #(CLK_PERIOD);
            ena_i = 1;
            wea_i = 0;
            addra_i = 2'b01 << 18;
        end
        #(10*CLK_PERIOD);
        f_out = $fopen("/home/ntnhacker/Downloads/De_Tai_Median_Filter_Mon_HDL/removed_noisyimg.txt", "w");
        for (i = 0; i < 238220; i = i + 1) begin
            #(CLK_PERIOD);
            ena_i = 1;
            wea_i = 0;
            addra_i = i;
            #(CLK_PERIOD);
            read_file_out_mem[i] = douta_o;
            $fwrite(f_out, "%02x\n", douta_o);
        end
        $fclose(f_out);
        #(CLK_PERIOD);
        $finish;

    end
endmodule