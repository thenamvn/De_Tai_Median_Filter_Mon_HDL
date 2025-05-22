`include "common.vh"

// Define missing macros (adjust to your design!)

module MY_IP #
	(
		parameter integer C_S_AXI_ID_WIDTH	= 1,
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 40,
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		parameter integer C_S_AXI_BUSER_WIDTH	= 0
	)
	(
		input wire  S_AXI_ACLK,
		input wire  S_AXI_ARESETN,
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		input wire [7 : 0] S_AXI_AWLEN,
		input wire [2 : 0] S_AXI_AWSIZE,
		input wire [1 : 0] S_AXI_AWBURST,
		input wire  S_AXI_AWLOCK,
		input wire [3 : 0] S_AXI_AWCACHE,
		input wire [2 : 0] S_AXI_AWPROT,
		input wire [3 : 0] S_AXI_AWQOS,
		input wire [3 : 0] S_AXI_AWREGION,
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		input wire  S_AXI_AWVALID,
		output wire  S_AXI_AWREADY,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input wire  S_AXI_WLAST,
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		input wire  S_AXI_WVALID,
		output wire  S_AXI_WREADY,
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		output wire [1 : 0] S_AXI_BRESP,
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		output wire  S_AXI_BVALID,
		input wire  S_AXI_BREADY,
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		input wire [7 : 0] S_AXI_ARLEN,
		input wire [2 : 0] S_AXI_ARSIZE,
		input wire [1 : 0] S_AXI_ARBURST,
		input wire  S_AXI_ARLOCK,
		input wire [3 : 0] S_AXI_ARCACHE,
		input wire [2 : 0] S_AXI_ARPROT,
		input wire [3 : 0] S_AXI_ARQOS,
		input wire [3 : 0] S_AXI_ARREGION,
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		input wire  S_AXI_ARVALID,
		output reg  S_AXI_ARREADY,
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		output reg [1 : 0] S_AXI_RRESP,
		output reg  S_AXI_RLAST,
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		output reg  S_AXI_RVALID,
		input wire  S_AXI_RREADY
	);

	// Internal regs and wires
	reg  [C_S_AXI_ID_WIDTH-1:0] done_r;
	reg  [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
	reg   axi_awready;
	reg   axi_wready;
	reg  [1 : 0] axi_bresp;
	reg  [C_S_AXI_BUSER_WIDTH-1 : 0] axi_buser;
	reg   axi_bvalid;
	reg  [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
	wire [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata_w;
	reg   axi_arready;
	reg   axi_arready2;
	reg  [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
	reg  [1 : 0] axi_rresp;
	reg  [1 : 0] axi_rresp2;
	reg   axi_rlast;
	reg   axi_rlast2;
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] axi_ruser;
	reg   axi_rvalid;
	reg   axi_rvalid2;

	wire aw_wrap_en;
	wire ar_wrap_en;
	wire [31:0]  aw_wrap_size ; 
	wire [31:0]  ar_wrap_size ; 

	reg axi_awv_awr_flag;
	reg axi_arv_arr_flag; 

	reg [7:0] axi_awlen_cntr;
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 12;
	localparam integer USER_NUM_MEM = 256;

	wire [OPT_MEM_ADDR_BITS:0] mem_address;
	wire [USER_NUM_MEM-1:0] mem_select;
	reg [C_S_AXI_DATA_WIDTH-1:0] mem_data_out[0 : USER_NUM_MEM-1];

	genvar i;
	genvar mem_byte_index;

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY		= axi_wready;
	assign S_AXI_BRESP		= axi_bresp;
	assign S_AXI_BUSER		= axi_buser;
	assign S_AXI_BVALID		= axi_bvalid;

	assign S_AXI_BID 		= S_AXI_AWID;
	assign S_AXI_RID 		= S_AXI_ARID;
	assign S_AXI_RUSER		= axi_ruser;

	assign aw_wrap_size 	= (C_S_AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign ar_wrap_size 	= (C_S_AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign aw_wrap_en 		= ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign ar_wrap_en 		= ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	// Read handshake signals assigned in always block, so no assign outside
	// Removed commented assign lines for S_AXI_ARREADY, S_AXI_RDATA, S_AXI_RRESP, S_AXI_RLAST, S_AXI_RVALID

	// Reset and pipeline registers for read channel signals
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
			S_AXI_ARREADY 	<= 1'b0;
			S_AXI_RVALID	<= 1'b0;
			S_AXI_RLAST		<= 1'b0;
			S_AXI_RRESP		<= 2'b0;
			axi_arready2	<= 1'b0;
			axi_rvalid2		<= 1'b0;
			axi_rlast2		<= 1'b0;
			axi_rresp2		<= 2'b0;		  

	    end 
		else begin
			axi_arready2	<= axi_arready;
			axi_rvalid2		<= axi_rvalid;
			axi_rlast2		<= axi_rlast;	
			axi_rresp2		<= axi_rresp;	
			S_AXI_ARREADY 	<= axi_arready;
			S_AXI_RVALID	<= axi_rvalid;
			S_AXI_RLAST		<= axi_rlast;
			S_AXI_RRESP		<= axi_rresp;
		end
	end
	  
	// axi_awready generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      axi_awv_awr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_awready <= 1'b1;
	          axi_awv_awr_flag  <= 1'b1; 
	        end
	      else if (S_AXI_WLAST && axi_wready)
	        begin
	          axi_awv_awr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// axi_awaddr latching
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	      axi_awlen_cntr <= 0;
	      axi_awburst <= 0;
	      axi_awlen <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag)
	        begin
	          axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];  
	          axi_awburst <= S_AXI_AWBURST; 
	          axi_awlen <= S_AXI_AWLEN;     
	          axi_awlen_cntr <= 0;
	        end   
	      else if((axi_awlen_cntr <= axi_awlen) && axi_wready && S_AXI_WVALID)        
	        begin
	          axi_awlen_cntr <= axi_awlen_cntr + 1;

	          case (axi_awburst)
	            2'b00: // fixed burst
	              begin
	                axi_awaddr <= axi_awaddr;          
	              end   
	            2'b01: //incremental burst
	              begin
	                axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	              end   
	            2'b10: //Wrapping burst
	              if (aw_wrap_en)
	                begin
	                  axi_awaddr <= (axi_awaddr - aw_wrap_size); 
	                end
	              else 
	                begin
	                  axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
	                end                      
	            default:
	              begin
	                axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	              end
	          endcase              
	        end
	    end 
	end       

	// axi_wready generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && axi_awv_awr_flag)
	        begin
	          axi_wready <= 1'b1;
	        end
	      else if (S_AXI_WLAST && axi_wready)
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Write response generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid <= 0;
	      axi_bresp <= 2'b0;
	      axi_buser <= 0;
	    end 
	  else
	    begin    
	      if (axi_awv_awr_flag && axi_wready && S_AXI_WVALID && ~axi_bvalid && S_AXI_WLAST )
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	        end                   
	      else if (S_AXI_BREADY && axi_bvalid) 
	        begin
	          axi_bvalid <= 1'b0; 
	        end  
	    end
	 end   

	// axi_arready generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_arready <= 1'b1;
	          axi_arv_arr_flag <= 1'b1;
	        end
	      else if (axi_rvalid && S_AXI_RREADY && axi_arlen_cntr == axi_arlen)
	        begin
	          axi_arv_arr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// axi_araddr latching and read burst management
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_araddr <= 0;
	      axi_arlen_cntr <= 0;
	      axi_arburst <= 0;
	      axi_arlen <= 0;
	      axi_rlast <= 1'b0;
	      axi_ruser <= 0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_arv_arr_flag)
	        begin
	          axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0]; 
	          axi_arburst <= S_AXI_ARBURST; 
	          axi_arlen <= S_AXI_ARLEN;     
	          axi_arlen_cntr <= 0;
	          axi_rlast <= 1'b0;
	        end   
	      else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY)        
	        begin
	          axi_arlen_cntr <= axi_arlen_cntr + 1;
	          axi_rlast <= 1'b0;
	          case (axi_arburst)
	            2'b00: 
	              begin
	                axi_araddr <= axi_araddr;        
	              end   
	            2'b01: 
	              begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	              end   
	            2'b10: 
	              if (ar_wrap_en) 
	                begin
	                  axi_araddr <= (axi_araddr - ar_wrap_size); 
	                end
	              else 
	                begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                end                      
	            default:
	              begin
	                axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	              end
	          endcase              
	        end
	      else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag )   
	        begin
	          axi_rlast <= 1'b1;
	        end          
	      else if (S_AXI_RREADY)   
	        begin
	          axi_rlast <= 1'b0;
	        end          
	    end 
	end       

	// axi_rvalid generation
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arv_arr_flag && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
			  axi_rresp  <= 2'b0; 
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end            
	    end
	end 

	// User logic memory example

	generate
	  if (USER_NUM_MEM >= 1)
	    begin
	      assign mem_select  = {USER_NUM_MEM{1'b1}}; // corrected assign to all ones
	      assign mem_address = (axi_arv_arr_flag? axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:(axi_awv_awr_flag? axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]:0));
	    end
	endgenerate

	generate 
	  for(i=0; i<= USER_NUM_MEM-1; i=i+1)
	    begin:BRAM_GEN
	      wire mem_rden;
	      wire mem_wren;
	
	      assign mem_wren = axi_wready && S_AXI_WVALID ;
	      assign mem_rden = axi_arv_arr_flag;

	      for(mem_byte_index=0; mem_byte_index<= (C_S_AXI_DATA_WIDTH/8-1); mem_byte_index=mem_byte_index+1)
	      begin:BYTE_BRAM_GEN
	        wire [7:0] data_in ;
	        wire [7:0] data_out;
	        reg  [7:0] byte_ram [0 : 15];

	        assign data_in  = S_AXI_WDATA[(mem_byte_index*8+7) -: 8];
	        assign data_out = byte_ram[mem_address];
	     
	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_wren && S_AXI_WSTRB[mem_byte_index])
	            begin
	              byte_ram[mem_address] <= data_in;
	            end   
	        end    

	        always @( posedge S_AXI_ACLK )
	        begin
	          if (mem_rden)
	            begin
	              mem_data_out[i][(mem_byte_index*8+7) -: 8] <= data_out;
	            end   
	        end    
	      end
	  end       
	endgenerate

	always @( mem_data_out, axi_rvalid)
	begin
	  if (axi_rvalid) 
	    begin
	      axi_rdata <= mem_data_out[0];
	    end   
	  else
	    begin
	      axi_rdata <= {C_S_AXI_DATA_WIDTH{1'b0}};
	    end       
	end    

	// AXI read data output
	assign S_AXI_RDATA = axi_rdata;

	//-----------------------------------------------------//
	//          			Input Signals                    // 
	//-----------------------------------------------------//	

	reg [`MODE_ADDR_WIDTH + `ADDR_WIDTH-1:0] AXI_addra_r;
	reg [`AXI_DATA_WIDTH-1:0] AXI_dina_r;
	reg AXI_ena_r;
	reg AXI_wea_r;

	wire [`MODE_ADDR_WIDTH + `ADDR_WIDTH-1:0] AXI_addra_w;
	wire [`AXI_DATA_WIDTH-1:0] AXI_dina_w;
	wire AXI_ena_w;
	wire AXI_wea_w;

	assign AXI_addra_w = AXI_addra_r;
	assign AXI_dina_w = AXI_dina_r;
	assign AXI_ena_w = AXI_ena_r;
	assign AXI_wea_w = AXI_wea_r;

    wire [`AXI_DATA_WIDTH-1:0]	AXI_dout_w;

	always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	   	if (S_AXI_ARESETN == 1'b0) begin
	       	AXI_addra_r	<= 0;
		   	AXI_dina_r	<= 0;
			AXI_ena_r	<= 1'b0;
			AXI_wea_r	<= 1'b0;
	   	end
	   	else begin
			if(S_AXI_WREADY && axi_awv_awr_flag && axi_awaddr[39:28] == 12'h00A) begin
				AXI_addra_r <= axi_awaddr[`MODE_ADDR_WIDTH+`ADDR_WIDTH-1:0]; 
				AXI_dina_r	<= S_AXI_WDATA;
				AXI_ena_r	<= axi_awv_awr_flag;
				AXI_wea_r	<= axi_awv_awr_flag;
			end
			else if (axi_arv_arr_flag && axi_araddr[39:28] == 12'h00A) begin
				AXI_addra_r <= axi_araddr[`MODE_ADDR_WIDTH+`ADDR_WIDTH-1:0];
				AXI_dina_r	<= 0;
				AXI_ena_r	<= axi_arv_arr_flag;
				AXI_wea_r	<= 1'b0;
	   		end
			else begin
				AXI_addra_r	<= AXI_addra_w;
		   	    AXI_dina_r	<= AXI_dina_w;
				AXI_ena_r	<= 1'b0;
				AXI_wea_r	<= 1'b0;
			end
		end
	end

	assign S_AXI_RDATA	= AXI_dout_w;

	// User logic module instantiation
	median_filter_unit medium_filter_inst (
		.CLK(S_AXI_ACLK),
		.RST(S_AXI_ARESETN),
		.dina_i(AXI_dina_w),
		.addra_i(AXI_addra_w),
		.wea_i(AXI_wea_w),
		.ena_i(AXI_ena_w),
		.douta_o(AXI_dout_w)
	);

endmodule
