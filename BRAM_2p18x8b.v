`include "common.vh"

module BRAM_2p18x8b (
    input   wire                        clka,
    input   wire                        wea,
    input   wire                        ena,
    input   wire [`ADDR_WIDTH-1:0]      addra,
    input   wire [`BIT_WIDTH-1:0]       dina,
    output  reg  [`BIT_WIDTH-1:0]       douta
);

    // Memory declaration
    reg [`BIT_WIDTH-1:0] memory [0:(2**`ADDR_WIDTH)-1];
    
    // Memory read/write operations
    always @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                // Write operation
                memory[addra] <= dina;
            end
            // Read operation (even during write, we read the previous value)
            douta <= memory[addra];
        end
    end
    
    // Initialize memory with zeros
    integer i;
    initial begin
        for (i = 0; i < (2**`ADDR_WIDTH); i = i + 1) begin
            memory[i] = {`BIT_WIDTH{1'b0}};
        end
    end
    
endmodule