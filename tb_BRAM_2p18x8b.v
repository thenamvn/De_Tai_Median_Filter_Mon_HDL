`include "common.vh"
`timescale 1ps/1ps

module tb_BRAM_2p18x8b();
    reg clka;
    reg wea;
    reg ena;
    reg [`ADDR_WIDTH-1:0] addra;
    reg [`BIT_WIDTH-1:0] dina;
    wire [`BIT_WIDTH-1:0] douta;
    
    // Instantiate the Unit Under Test (UUT)
    BRAM_2p18x8b uut(
        .clka(clka),
        .wea(wea),
        .ena(ena),
        .addra(addra),
        .dina(dina),
        .douta(douta)
    );
    
    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clka = ~clka;
    
    // Task for writing to memory
    task write_mem;
        input [`ADDR_WIDTH-1:0] addr;
        input [`BIT_WIDTH-1:0] data;
        begin
            wea = 1;
            ena = 1;
            addra = addr;
            dina = data;
            @(posedge clka);
        end
    endtask
    
    // Task for reading from memory - accounts for memory read latency
    task read_mem;
        input [`ADDR_WIDTH-1:0] addr;
        output [`BIT_WIDTH-1:0] data;
        begin
            wea = 0;
            ena = 1;
            addra = addr;
            @(posedge clka); // Wait for one clock cycle for BRAM read latency
            @(posedge clka); // Might need to wait for second cycle based on BRAM implementation
            data = douta;    // Capture output data
        end
    endtask
    
    reg [`BIT_WIDTH-1:0] read_data;
    
    initial begin
        // Initialize inputs
        clka = 0;
        wea = 0;
        ena = 0;
        addra = 0;
        dina = 0;
        read_data = 0;
        
        // Wait for a few clock cycles
        repeat(2) @(posedge clka);
        
        // Write some data to various addresses
        $display("Writing data to memory...");
        write_mem(18'd0, 8'd123);
        write_mem(18'd1, 8'd45);
        write_mem(18'd2, 8'd67);
        
        // Add a small delay before reading
        repeat(2) @(posedge clka);
        
        // Read back the data
        $display("Reading data from memory...");
        read_mem(18'd0, read_data);
        if(read_data == 8'd123)
            $display("PASS: Read correct data at address 0: %d", read_data);
        else
            $display("ERROR: Read incorrect data at address 0: %d, expected 123", read_data);
        
        read_mem(18'd1, read_data);
        if(read_data == 8'd45)
            $display("PASS: Read correct data at address 1: %d", read_data);
        else
            $display("ERROR: Read incorrect data at address 1: %d, expected 45", read_data);
        
        read_mem(18'd2, read_data);
        if(read_data == 8'd67)
            $display("PASS: Read correct data at address 2: %d", read_data);
        else
            $display("ERROR: Read incorrect data at address 2: %d, expected 67", read_data);
        
        // Test disable
        ena = 0;
        @(posedge clka);
        
        // Finish simulation
        repeat(2) @(posedge clka);
        $finish;
    end
    
    // Monitor the outputs
    initial begin
        $monitor("Time: %t, ena: %b, wea: %b, addra: %d, dina: %d, douta: %d", 
                 $time, ena, wea, addra, dina, douta);
    end
endmodule