`timescale 1ns / 1ps
`include "common.vh"

// Define missing address offsets (set these as needed)
`define WIDTH_ADDR  40'h4    // example offset for width register
`define HEIGHT_ADDR 40'h8    // example offset for height register
`define START_ADDR  40'hC    // example offset for start command
`define VALID_ADDR  40'h10   // example offset for valid status
`define READ_BASE   40'h100  // example offset for read data base address

module MY_IP_tb();

    parameter integer C_S_AXI_ID_WIDTH    = 1;
    parameter integer C_S_AXI_DATA_WIDTH  = 32;
    parameter integer C_S_AXI_ADDR_WIDTH  = 40;
    parameter integer C_S_AXI_AWUSER_WIDTH = 0;
    parameter integer C_S_AXI_ARUSER_WIDTH = 0;
    parameter integer C_S_AXI_WUSER_WIDTH  = 0;
    parameter integer C_S_AXI_RUSER_WIDTH  = 0;
    parameter integer C_S_AXI_BUSER_WIDTH  = 0;

    reg S_AXI_ACLK;
    reg S_AXI_ARESETN;
    reg [C_S_AXI_ID_WIDTH-1:0] S_AXI_AWID;
    reg [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;
    reg [7:0] S_AXI_AWLEN;
    reg [2:0] S_AXI_AWSIZE;
    reg [1:0] S_AXI_AWBURST;
    reg S_AXI_AWLOCK;
    reg [3:0] S_AXI_AWCACHE;
    reg [2:0] S_AXI_AWPROT;
    reg [3:0] S_AXI_AWQOS;
    reg [3:0] S_AXI_AWREGION;
    reg [C_S_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER;
    reg S_AXI_AWVALID;
    reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;
    reg [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB;
    reg S_AXI_WLAST;
    reg [C_S_AXI_WUSER_WIDTH-1:0] S_AXI_WUSER;
    reg S_AXI_WVALID;
    reg S_AXI_BREADY;
    reg [C_S_AXI_ID_WIDTH-1:0] S_AXI_ARID;
    reg [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;
    reg [7:0] S_AXI_ARLEN;
    reg [2:0] S_AXI_ARSIZE;
    reg [1:0] S_AXI_ARBURST;
    reg S_AXI_ARLOCK;
    reg [3:0] S_AXI_ARCACHE;
    reg [2:0] S_AXI_ARPROT;
    reg [3:0] S_AXI_ARQOS;
    reg [3:0] S_AXI_ARREGION;
    reg [C_S_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER;
    reg S_AXI_ARVALID;
    reg S_AXI_RREADY;

    wire S_AXI_AWREADY;
    wire S_AXI_WREADY;
    wire [C_S_AXI_ID_WIDTH-1:0] S_AXI_BID;
    wire [1:0] S_AXI_BRESP;
    wire [C_S_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER;
    wire S_AXI_BVALID;
    wire S_AXI_ARREADY;
    wire [C_S_AXI_ID_WIDTH-1:0] S_AXI_RID;
    wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
    wire [1:0] S_AXI_RRESP;
    wire S_AXI_RLAST;
    wire [C_S_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER;
    wire S_AXI_RVALID;

    integer i;
    integer file_in, file_out;
    reg [7:0] test_image [0:1023]; // 32x32 image
    reg [7:0] output_image [0:1023];

    MY_IP #(
        .C_S_AXI_ID_WIDTH(C_S_AXI_ID_WIDTH),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .C_S_AXI_AWUSER_WIDTH(C_S_AXI_AWUSER_WIDTH),
        .C_S_AXI_ARUSER_WIDTH(C_S_AXI_ARUSER_WIDTH),
        .C_S_AXI_WUSER_WIDTH(C_S_AXI_WUSER_WIDTH),
        .C_S_AXI_RUSER_WIDTH(C_S_AXI_RUSER_WIDTH),
        .C_S_AXI_BUSER_WIDTH(C_S_AXI_BUSER_WIDTH)
    ) uut (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWID(S_AXI_AWID),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWLEN(S_AXI_AWLEN),
        .S_AXI_AWSIZE(S_AXI_AWSIZE),
        .S_AXI_AWBURST(S_AXI_AWBURST),
        .S_AXI_AWLOCK(S_AXI_AWLOCK),
        .S_AXI_AWCACHE(S_AXI_AWCACHE),
        .S_AXI_AWPROT(S_AXI_AWPROT),
        .S_AXI_AWQOS(S_AXI_AWQOS),
        .S_AXI_AWREGION(S_AXI_AWREGION),
        .S_AXI_AWUSER(S_AXI_AWUSER),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WLAST(S_AXI_WLAST),
        .S_AXI_WUSER(S_AXI_WUSER),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BID(S_AXI_BID),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BUSER(S_AXI_BUSER),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARID(S_AXI_ARID),
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARLEN(S_AXI_ARLEN),
        .S_AXI_ARSIZE(S_AXI_ARSIZE),
        .S_AXI_ARBURST(S_AXI_ARBURST),
        .S_AXI_ARLOCK(S_AXI_ARLOCK),
        .S_AXI_ARCACHE(S_AXI_ARCACHE),
        .S_AXI_ARPROT(S_AXI_ARPROT),
        .S_AXI_ARQOS(S_AXI_ARQOS),
        .S_AXI_ARREGION(S_AXI_ARREGION),
        .S_AXI_ARUSER(S_AXI_ARUSER),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RID(S_AXI_RID),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RLAST(S_AXI_RLAST),
        .S_AXI_RUSER(S_AXI_RUSER),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY)
    );

    // Clock generation
    initial begin
        S_AXI_ACLK = 0;
        forever #5 S_AXI_ACLK = ~S_AXI_ACLK;  // 100MHz clock
    end

    // Task to write AXI data (blocking assignments)
    task axi_write;
        input [C_S_AXI_ADDR_WIDTH-1:0] addr;
        input [C_S_AXI_DATA_WIDTH-1:0] data;
        begin
            @(posedge S_AXI_ACLK);
            S_AXI_AWADDR = addr;
            S_AXI_AWVALID = 1'b1;
            S_AXI_AWID = 0;
            S_AXI_AWLEN = 0;
            S_AXI_AWSIZE = 3'b010;
            S_AXI_AWBURST = 2'b01;
            S_AXI_AWLOCK = 1'b0;
            S_AXI_AWCACHE = 4'b0000;
            S_AXI_AWPROT = 3'b000;
            S_AXI_AWQOS = 4'b0000;
            S_AXI_AWREGION = 4'b0000;
            S_AXI_AWUSER = 0;

            S_AXI_WDATA = data;
            S_AXI_WSTRB = 4'b1111;
            S_AXI_WLAST = 1'b1;
            S_AXI_WUSER = 0;
            S_AXI_WVALID = 1'b1;

            // Wait for slave to accept AW and W
            wait(S_AXI_AWREADY);
            wait(S_AXI_WREADY);

            @(posedge S_AXI_ACLK);
            S_AXI_AWVALID = 1'b0;
            S_AXI_WVALID = 1'b0;

            // Wait for write response
            S_AXI_BREADY = 1'b1;
            wait(S_AXI_BVALID);
            @(posedge S_AXI_ACLK);
            S_AXI_BREADY = 1'b0;

            // Clear inputs
            S_AXI_AWADDR = 0;
            S_AXI_WDATA = 0;
            S_AXI_WSTRB = 0;
            S_AXI_WLAST = 0;
        end
    endtask

    // Task to read AXI data (blocking assignments)
    task axi_read;
        input [C_S_AXI_ADDR_WIDTH-1:0] addr;
        output [C_S_AXI_DATA_WIDTH-1:0] data;
        begin
            @(posedge S_AXI_ACLK);
            S_AXI_ARADDR = addr;
            S_AXI_ARVALID = 1'b1;
            S_AXI_ARID = 0;
            S_AXI_ARLEN = 0;
            S_AXI_ARSIZE = 3'b010;
            S_AXI_ARBURST = 2'b01;
            S_AXI_ARLOCK = 1'b0;
            S_AXI_ARCACHE = 4'b0000;
            S_AXI_ARPROT = 3'b000;
            S_AXI_ARQOS = 4'b0000;
            S_AXI_ARREGION = 4'b0000;
            S_AXI_ARUSER = 0;

            wait(S_AXI_ARREADY);

            @(posedge S_AXI_ACLK);
            S_AXI_ARVALID = 1'b0;

            S_AXI_RREADY = 1'b1;
            wait(S_AXI_RVALID);

            data = S_AXI_RDATA;

            @(posedge S_AXI_ACLK);
            S_AXI_RREADY = 1'b0;

            // Clear read address
            S_AXI_ARADDR = 0;
        end
    endtask

    initial begin
        // Reset
        S_AXI_ARESETN = 0;
        S_AXI_AWID = 0; S_AXI_AWADDR = 0; S_AXI_AWLEN = 0; S_AXI_AWSIZE = 0;
        S_AXI_AWBURST = 0; S_AXI_AWLOCK = 0; S_AXI_AWCACHE = 0; S_AXI_AWPROT = 0;
        S_AXI_AWQOS = 0; S_AXI_AWREGION = 0; S_AXI_AWUSER = 0; S_AXI_AWVALID = 0;
        S_AXI_WDATA = 0; S_AXI_WSTRB = 0; S_AXI_WLAST = 0; S_AXI_WUSER = 0; S_AXI_WVALID = 0;
        S_AXI_BREADY = 0;
        S_AXI_ARID = 0; S_AXI_ARADDR = 0; S_AXI_ARLEN = 0; S_AXI_ARSIZE = 0;
        S_AXI_ARBURST = 0; S_AXI_ARLOCK = 0; S_AXI_ARCACHE = 0; S_AXI_ARPROT = 0;
        S_AXI_ARQOS = 0; S_AXI_ARREGION = 0; S_AXI_ARUSER = 0; S_AXI_ARVALID = 0;
        S_AXI_RREADY = 0;

        #20;
        S_AXI_ARESETN = 1;
        #20;

        // Load test image file
        file_in = $fopen("d:/median/HDL/noisyimg.txt", "r");
        if (file_in == 0) begin
            $display("Error: Could not open input file");
            $finish;
        end

        for (i = 0; i < 1024; i = i + 1) begin
            if ($fscanf(file_in, "%h", test_image[i]) != 1) begin
                $display("Error reading input file at %d", i);
                $finish;
            end
        end
        $fclose(file_in);

        $display("Writing image data to memory...");
        for (i = 0; i < 1024; i = i + 1) begin
            axi_write(40'h00A0000000 + (i*4), {24'b0, test_image[i]});
        end

        $display("Configuring filter parameters...");
        axi_write(40'h00A0000000 + `WIDTH_ADDR, 32);
        axi_write(40'h00A0000000 + `HEIGHT_ADDR, 32);

        $display("Starting filter operation...");
        axi_write(40'h00A0000000 + `START_ADDR, 1);

        $display("Waiting for processing completion...");
        reg [31:0] valid_data;
        while (1) begin
            axi_read(40'h00A0000000 + `VALID_ADDR, valid_data);
            if (valid_data == 0) begin
                $display("Filter processing completed");
                break;
            end
            #100;
        end

        $display("Reading processed image data...");
        for (i = 0; i < 1024; i = i + 1) begin
            axi_read(40'h00A0000000 + `READ_BASE + (i*4), valid_data);
            output_image[i] = valid_data[7:0];
        end

        file_out = $fopen("d:/median/SOC/RTL/tb_output_image.txt", "w");
        if (file_out == 0) begin
            $display("Error: Could not open output file");
            $finish;
        end

        for (i = 0; i < 1024; i = i + 1) begin
            $fwrite(file_out, "%02X\n", output_image[i]);
        end
        $fclose(file_out);

        $display("Sample output pixels:");
        $display("Pixel[10,10] = %h", output_image[10*32+10]);
        $display("Pixel[20,20] = %h", output_image[20*32+20]);

        #100;
        $display("Testbench completed.");
        $finish;
    end

endmodule
