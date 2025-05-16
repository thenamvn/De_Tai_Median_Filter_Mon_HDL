`include "common.vh"

// This file contain 7 ERRORS
module median_filter_unit (
    input   wire                                            CLK,
    input   wire                                            RST,

    input   wire    [`FULL_BIT_WIDTH-1:0]                   dina_i,
    input   wire    [`MODE_ADDR_WIDTH+`ADDR_WIDTH-1:0]      addra_i,
    input   wire                                            wea_i,
    input   wire                                            ena_i,
    output  wire    [`FULL_BIT_WIDTH-1:0]                   douta_o
);

    // Flow for controlling the AXI interface

    // Register for storing: width, height, and start signals

    reg     [9:0]   width_r, height_r;
    wire    [9:0]   width_w, height_w;

    assign width_w = width_r;
    assign height_w = height_r;

    reg         start_r;
    wire        start_w;

    assign start_w = start_r;

    wire    [`MODE_ADDR_WIDTH-1:0]   addra_mode_w;

    assign addra_mode_w = addra_i[`MODE_ADDR_WIDTH+`ADDR_WIDTH-1:`ADDR_WIDTH];

    // Write Type: 00. BRAM_2p18x8b 01. start_r 10. width_r 11. height_r
    // Read Type : 00. BRAM_2p18x8b 01. valid_r

    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            start_r  <= 1'b0;
            width_r  <= 10'd0;
            height_r <= 10'd0;
        end
        else begin
            if(ena_i) begin
                if(wea_i) begin // Write channel
                    if(addra_mode_w == 2'd0) begin
                        start_r  <= start_w;
                        width_r  <= width_w;
                        height_r <= height_w;
                    end
                    else if (addra_mode_w == 2'd1) begin
                        start_r  <= dina_i[0:0];
                        width_r  <= width_w;
                        height_r <= height_w;
                    end
                    else if (addra_mode_w == 2'd2) begin
                        start_r  <= start_w;
                        width_r  <= dina_i[9:0];
                        height_r <= height_w;
                    end
                    else if (addra_mode_w == 2'd3) begin
                        start_r  <= start_w;
                        width_r  <= width_w;
                        height_r <= dina_i[9:0];
                    end
                    else begin
                        start_r  <= start_w;
                        width_r  <= width_w;
                        height_r <= height_w;
                    end
                end
                else begin
                    start_r  <= start_w;
                    width_r  <= width_w;
                    height_r <= height_w;
                end
            end
            else begin
                start_r  <= start_w;
                width_r  <= width_w;
                height_r <= height_w;
            end
        end
    end


    // Counters for controlling the median filter process
    // Counter for row index
    wire [9:0]   counter_i_w;
    reg          counter_i_increment_r;
    wire         counter_i_increment_w;
    reg          counter_i_clear_r;
    wire         counter_i_clear_w;
    

    assign counter_i_increment_w = counter_i_increment_r;
    assign counter_i_clear_w     = counter_i_clear_r;

    
    counter_10_bit counter_10_bit_i_inst(
        .CLK(CLK),
        .RST(RST),
        .increment_i(counter_i_increment_w),
        .clear_i(counter_i_clear_w),
        .count_o(counter_i_w)
    );

    // Counter for column index
    wire [9:0]   counter_j_w;
    reg          counter_j_increment_r;
    wire         counter_j_increment_w;
    reg          counter_j_clear_r;
    wire         counter_j_clear_w;
    

    assign counter_j_increment_w = counter_j_increment_r;
    assign counter_j_clear_w     = counter_j_clear_r;

    
    counter_10_bit counter_10_bit_j_inst(
        .CLK(CLK),
        .RST(RST),
        .increment_i(counter_j_increment_w),
        .clear_i(counter_j_clear_w),
        .count_o(counter_j_w)
    );

    // Counter for filling the filter window
 
    wire [3:0]  counter_window_w;

    reg         counter_window_increment_r;
    wire        counter_window_increment_w;

    reg         counter_window_clear_r;
    wire        counter_window_clear_w;

    assign counter_window_increment_w = counter_window_increment_r;
    assign counter_window_clear_w     = counter_window_clear_r;

    counter_4_bit counter_4_bit_window_inst(
        .CLK(CLK),
        .RST(RST),
        .increment_i(counter_window_increment_w),
        .clear_i(counter_window_clear_w),
        .count_o(counter_window_w)
    );
    // Controlling signals definition

    reg         sel_fsm_r;
    wire        sel_fsm_w;

    assign sel_fsm_w = sel_fsm_r;

    reg         fsm_ena_r, fsm_wea_r;
    wire        fsm_ena_w, fsm_wea_w;

    assign fsm_ena_w = fsm_ena_r;
    assign fsm_wea_w = fsm_wea_r;

    reg  [`BIT_WIDTH-1:0]   window_r [0:8];
    wire [`BIT_WIDTH-1:0]   window_w [0:8];

    genvar i;

    generate 
        for (i = 0; i < 9; i = i + 1) begin : window_gen
            assign window_w[i] = window_r[i];
        end
    endgenerate
        
    wire [`ADDR_WIDTH-1:0]      fsm_addra_w;
    wire [`BIT_WIDTH-1:0]       fsm_dina_w;

    wire [`BIT_WIDTH-1:0]       window_out_w [0:8];

    // BRAM for storing the pictures (one for input picture and one for output picture)


    wire [`BIT_WIDTH-1:0]       bram_dina_w;
    wire [`ADDR_WIDTH-1:0]      bram_addra_w;
    wire                        bram_wea_w, bram_ena_w;

    wire [`BIT_WIDTH-1:0]       bram_douta_w;
    wire [`BIT_WIDTH-1:0]       bram_douta_out_w;


    assign bram_dina_w  = (~sel_fsm_w) ? dina_i[`BIT_WIDTH-1:0]           : fsm_dina_w;
    assign bram_addra_w = (~sel_fsm_w) ? addra_i[`ADDR_WIDTH-1:0]         : fsm_addra_w;
    assign bram_wea_w   = (~sel_fsm_w) ? (wea_i & (addra_mode_w == 2'd0)) : fsm_wea_w;
    assign bram_ena_w   = (~sel_fsm_w) ? (ena_i & (addra_mode_w == 2'd0)) : fsm_ena_w;

    BRAM_2p18x8b bram_2p18x8b_inst(
        .clka(CLK),
        .wea(bram_wea_w & (~sel_fsm_w)),
        .ena(bram_ena_w),
        .addra(bram_addra_w),
        .dina(bram_dina_w),
        .douta(bram_douta_w)
    );

    BRAM_2p18x8b bram_2p18x8b_out_inst(
        .clka(CLK),
        .wea(bram_wea_w),
        .ena(bram_ena_w),
        .addra(bram_addra_w),
        .dina(bram_dina_w),
        .douta(bram_douta_out_w)
    );

    wire    global_valid_w;
    reg     global_valid_r;

    assign global_valid_w = global_valid_r;

    wire    start_bubble_sort_w;
    reg     start_bubble_sort_r;

    assign start_bubble_sort_w = start_bubble_sort_r;

    wire    valid_bubble_sort_w;

    wire    row_based_clear_w;
    reg     row_based_clear_r;

    assign row_based_clear_w = row_based_clear_r;

    wire    row_based_update_w;
    reg     row_based_update_r;

    assign row_based_update_w = row_based_update_r;

    wire    update_window_w;
    reg     update_window_r;

    assign update_window_w = update_window_r;


    wire    write_window_w;
    reg     write_window_r;

    assign write_window_w = write_window_r;

    // FSM for controlling the median filter process

    reg [1:0]   state_r, next_state_r;
    wire [1:0]  state_w, next_state_w;

    assign state_w = state_r;
    assign next_state_w = next_state_r;

    localparam  IDLE        = 2'b00;
    localparam  EXEC        = 2'b01;
    localparam  DONE        = 2'b10;

    // State transition logic

    always @(posedge CLK or negedge RST) begin
        if (~RST) begin
            state_r <= IDLE;
        end
        else begin
            state_r <= next_state_r;
        end
    end

    // Next state logic

    always @(state_w or counter_i_w or counter_j_w or valid_bubble_sort_w or height_w or width_w) begin
        case (state_w)
            IDLE: begin
                if (start_w) begin
                    next_state_r = EXEC;
                end
                else begin
                    next_state_r = IDLE;
                end
            end
            EXEC: begin
                if ((counter_i_w == height_w - 10'd1) && (counter_j_w == width_w - 10'd1) && valid_bubble_sort_w) begin
                    next_state_r = DONE;
                end
                else begin
                    next_state_r = EXEC;
                end
            end
            DONE: begin
                if (~start_w) begin
                    next_state_r = IDLE;
                end
                else begin
                    next_state_r = DONE;
                end
            end
            default: begin
                next_state_r = IDLE;
            end
        endcase
    end


    // Output control logic

    always @(state_w) begin
        case (state_w) 
            IDLE: begin
                counter_i_clear_r           = 1'b1;
                counter_j_clear_r           = 1'b1;
                counter_window_clear_r      = 1'b1;
                counter_i_increment_r       = 1'b0;
                counter_j_increment_r       = 1'b0;
                counter_window_increment_r  = 1'b0;
                sel_fsm_r                   = 1'b0;
                fsm_ena_r                   = 1'b0;
                fsm_wea_r                   = 1'b0;
                start_bubble_sort_r         = 1'b0;
                global_valid_r              = 1'b0;
                row_based_clear_r           = 1'b1;
                row_based_update_r          = 1'b0;
                update_window_r             = 1'b0;
                write_window_r              = 1'b0;
            end
            EXEC: begin
                sel_fsm_r                   = 1'b1;
                global_valid_r              = 1'b0;
                row_based_clear_r           = 1'b0;
                if(counter_window_w == 4'd8) begin
                    start_bubble_sort_r = 1'b1;
                    if(valid_bubble_sort_w) begin
                        counter_window_increment_r = 1'b0;
                        counter_window_clear_r     = 1'b1;
                        fsm_ena_r                  = 1'b1;
                        fsm_wea_r                  = 1'b1;
                        update_window_r            = 1'b1;
                        write_window_r             = 1'b0;
                        if(counter_j_w == width_w - 10'd1) begin
                            counter_i_increment_r = 1'b1;
                            counter_i_clear_r     = 1'b0;
                            counter_j_increment_r = 1'b0;
                            counter_j_clear_r     = 1'b1;
                            row_based_update_r    = 1'b1;
                        end
                        else begin
                            counter_i_increment_r = 1'b0;
                            counter_i_clear_r     = 1'b0;
                            counter_j_increment_r = 1'b1;
                            counter_j_clear_r     = 1'b0;
                            row_based_update_r    = 1'b0;
                        end
                    end
                    else begin
                        update_window_r             = 1'b0;
                        counter_window_increment_r  = 1'b0;
                        counter_window_clear_r      = 1'b0;
                        counter_i_clear_r           = 1'b0;
                        counter_j_clear_r           = 1'b0;
                        counter_i_increment_r       = 1'b0;
                        counter_j_increment_r       = 1'b0;
                        fsm_ena_r                   = 1'b1;
                        fsm_wea_r                   = 1'b0;
                        row_based_update_r          = 1'b0;
                        write_window_r              = 1'b1;
                    end
                end
                else begin
                    start_bubble_sort_r = 1'b0;
                    counter_window_increment_r = 1'b1;
                    counter_window_clear_r     = 1'b0;
                    counter_j_increment_r      = 1'b0;
                    counter_j_clear_r          = 1'b0;
                    counter_i_increment_r      = 1'b0;
                    counter_i_clear_r          = 1'b0;
                    fsm_ena_r                  = 1'b1;
                    fsm_wea_r                  = 1'b0;
                    row_based_update_r         = 1'b0;
                    update_window_r            = 1'b0;
                    write_window_r             = 1'b1;
                end
            end
            DONE: begin
                counter_j_clear_r               = 1'b1;
                counter_i_clear_r               = 1'b1;
                counter_window_clear_r          = 1'b1;
                counter_i_increment_r           = 1'b0;
                counter_j_increment_r           = 1'b0;
                counter_window_increment_r      = 1'b0;
                sel_fsm_r                       = 1'b0;
                fsm_ena_r                       = 1'b0;
                fsm_wea_r                       = 1'b0;
                start_bubble_sort_r             = 1'b0;
                global_valid_r                  = 1'b1;
                row_based_clear_r               = 1'b1;
                row_based_update_r              = 1'b0;
                update_window_r                 = 1'b0;
                write_window_r                  = 1'b0;
            end
            default: begin
                counter_i_clear_r               = 1'b0;
                counter_j_clear_r               = 1'b0;
                counter_window_clear_r          = 1'b0;
                counter_window_increment_r      = 1'b0;
                counter_i_increment_r           = 1'b0;
                counter_j_increment_r           = 1'b0;
                sel_fsm_r                       = 1'b0;
                fsm_ena_r                       = 1'b0;
                fsm_wea_r                       = 1'b0;
                start_bubble_sort_r             = 1'b0;
                global_valid_r                  = 1'b0;
                row_based_clear_r               = 1'b0;
                row_based_update_r              = 1'b0;
                update_window_r                 = 1'b0;
                write_window_r                  = 1'b0;
            end
        endcase
    end

    // Data path logic

    reg [`ADDR_WIDTH-1:0]   row_based_r;
    wire [`ADDR_WIDTH-1:0]  row_based_w;

    assign row_based_w = row_based_r;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            row_based_r <= 18'd0;
        end
        else begin
            if(row_based_clear_w) begin
                row_based_r <= 18'd0;
            end
            else begin
                if(row_based_update_w) begin
                    row_based_r <= row_based_w + width_w;
                end
                else begin
                    row_based_r <= row_based_w;
                end
            end
        end
    end

    // Delay counter_window_w by 1 clock cycle

    reg     [3:0]  delayed_counter_window_r;
    wire    [3:0]  delayed_counter_window_w;

    assign delayed_counter_window_w = delayed_counter_window_r;

    wire    delay_start_bubble_sort_w;
    reg     delay_start_bubble_sort_r;

    assign delay_start_bubble_sort_w = delay_start_bubble_sort_r;

    wire    delay_2clk_start_bubble_sort_w;
    reg     delay_2clk_start_bubble_sort_r;

    assign delay_2clk_start_bubble_sort_w = delay_2clk_start_bubble_sort_r;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            delayed_counter_window_r <= 4'd0;
            delay_start_bubble_sort_r <= 1'b0;
            delay_2clk_start_bubble_sort_r <= 1'b0;
        end
        else begin
            delayed_counter_window_r <= counter_window_w;
            delay_start_bubble_sort_r <= start_bubble_sort_w;
            delay_2clk_start_bubble_sort_r <= delay_start_bubble_sort_w;
        end
    end

    
    bubble_sort_unit bubble_sort_unit_inst (
        .CLK(CLK),
        .RST(RST),

        .start_i(delay_2clk_start_bubble_sort_w),
        .in_data0_i(window_w[0]),
        .in_data1_i(window_w[1]),
        .in_data2_i(window_w[2]),
        .in_data3_i(window_w[3]),
        .in_data4_i(window_w[4]),
        .in_data5_i(window_w[5]),
        .in_data6_i(window_w[6]),
        .in_data7_i(window_w[7]),
        .in_data8_i(window_w[8]),

        .out_data0_o(window_out_w[0]),
        .out_data1_o(window_out_w[1]),
        .out_data2_o(window_out_w[2]),
        .out_data3_o(window_out_w[3]),
        .out_data4_o(window_out_w[4]),
        .out_data5_o(window_out_w[5]),
        .out_data6_o(window_out_w[6]),
        .out_data7_o(window_out_w[7]),
        .out_data8_o(window_out_w[8]),

        .valid_o(valid_bubble_sort_w)
    );

    wire    is_zero_column_w, is_zero_row_w;

    // At colum 0, set the zero column flag to store the window[0] window[3] window[6] to zero
    // At colum width_w - 1, set the zero column flag to store the window[2] window[5] window[8] to zero
    assign is_zero_column_w = ((counter_j_w == 10'd0) & 
                               (delayed_counter_window_w == 4'd0        | 
                                delayed_counter_window_w == 4'd3        | 
                                delayed_counter_window_w == 4'd6    ))  |
                              ((counter_j_w == width_w - 10'd1) & (
                                delayed_counter_window_w == 4'd2        |
                                delayed_counter_window_w == 4'd5        |
                                delayed_counter_window_w == 4'd8    )) ? 1'b1 : 1'b0;

    // At row 0, set the zero row flag to store the window[0] window[1] window[2] to zero    
    // At row height_w - 1, set the zero row flag to store the window[6] window[7] window[8] to zero
    assign is_zero_row_w = ((counter_i_w == 10'd0) & 
                            (delayed_counter_window_w == 4'd0        | 
                             delayed_counter_window_w == 4'd1        | 
                             delayed_counter_window_w == 4'd2    ))  |
                           ((counter_i_w == height_w - 10'd1) & (
                             delayed_counter_window_w == 4'd6        |
                             delayed_counter_window_w == 4'd7        |
                             delayed_counter_window_w == 4'd8    )) ? 1'b1 : 1'b0;
    
    wire is_zero_w;

    assign is_zero_w = is_zero_column_w | is_zero_row_w;

    // Wires for calculating the condition

    wire [18:0] cal_read_addra_w;

    assign cal_read_addra_w =   (counter_window_w == 4'd0) ? {1'b0, row_based_w} - {9'b0, width_w} - 19'd1 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd1) ? {1'b0, row_based_w} - {9'b0, width_w} + 19'd0 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd2) ? {1'b0, row_based_w} - {9'b0, width_w} + 19'd1 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd3) ? {1'b0, row_based_w}                   - 19'd1 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd4) ? {1'b0, row_based_w}                   + 19'd0 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd5) ? {1'b0, row_based_w}                   + 19'd1 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd6) ? {1'b0, row_based_w} + {9'b0, width_w} - 19'd1 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd7) ? {1'b0, row_based_w} + {9'b0, width_w} + 19'd0 + {1'b0, counter_j_w} :
                                (counter_window_w == 4'd8) ? {1'b0, row_based_w} + {9'b0, width_w} + 19'd1 + {1'b0, counter_j_w} : 19'd0;

    assign fsm_addra_w      = (fsm_wea_w) ? row_based_w + counter_j_w : cal_read_addra_w;
    assign fsm_dina_w      =  window_out_w[4];

    
    wire [`BIT_WIDTH-1:0]   cal_bram_douta_w;

    assign cal_bram_douta_w = (is_zero_w == 1'b0) ? bram_douta_w : 8'd0;


    always @(posedge CLK or negedge RST) begin
        if(~RST) begin
            window_r[0] <= 8'd0;
            window_r[1] <= 8'd0;
            window_r[2] <= 8'd0;
            window_r[3] <= 8'd0;
            window_r[4] <= 8'd0;
            window_r[5] <= 8'd0;
            window_r[6] <= 8'd0;
            window_r[7] <= 8'd0;
            window_r[8] <= 8'd0;
        end
        else begin
            if (write_window_w) begin
                case (delayed_counter_window_w)
                    4'd0: begin
                        window_r[0] <= cal_bram_douta_w;
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd1: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= cal_bram_douta_w;
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd2: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= cal_bram_douta_w;
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd3: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= cal_bram_douta_w;
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd4: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= cal_bram_douta_w;
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd5: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= cal_bram_douta_w;
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd6: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= cal_bram_douta_w;
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                    4'd7: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= cal_bram_douta_w;
                        window_r[8] <= window_w[8];
                    end
                    4'd8: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= cal_bram_douta_w;
                    end
                    default: begin
                        window_r[0] <= window_w[0];
                        window_r[1] <= window_w[1];
                        window_r[2] <= window_w[2];
                        window_r[3] <= window_w[3];
                        window_r[4] <= window_w[4];
                        window_r[5] <= window_w[5];
                        window_r[6] <= window_w[6];
                        window_r[7] <= window_w[7];
                        window_r[8] <= window_w[8];
                    end
                endcase
            end
            else if (update_window_w) begin
                window_r[0] <= window_out_w[0];
                window_r[1] <= window_out_w[1];
                window_r[2] <= window_out_w[2];
                window_r[3] <= window_out_w[3];
                window_r[4] <= window_out_w[4];
                window_r[5] <= window_out_w[5];
                window_r[6] <= window_out_w[6];
                window_r[7] <= window_out_w[7];
                window_r[8] <= window_out_w[8];
            end
            else begin
                window_r[0] <= window_w[0];
                window_r[1] <= window_w[1];
                window_r[2] <= window_w[2];
                window_r[3] <= window_w[3];
                window_r[4] <= window_w[4];
                window_r[5] <= window_w[5];
                window_r[6] <= window_w[6];
                window_r[7] <= window_w[7];
                window_r[8] <= window_w[8];
            end
        end
    end

    wire [`FULL_BIT_WIDTH-1:0]  cal_douta_w, cal_douta_valid_w;

    assign cal_douta_w = (global_valid_w == 1'b1) ? {24'd0, bram_douta_out_w} : 32'd0;

    assign cal_douta_valid_w = {31'd0, global_valid_w};

    assign douta_o = (addra_mode_w == 2'd1) ? cal_douta_valid_w : cal_douta_w;
    
endmodule

module counter_10_bit (
    input   wire            CLK,
    input   wire            RST,         // Active-low asynchronous reset
    input   wire            increment_i,
    input   wire            clear_i,
    output  wire     [9:0]  count_o
);

    reg     [9:0] count_r;

    // Assign the registered count value to the output
    assign count_o = count_r;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin // Active-low asynchronous reset
            count_r <= 10'b0;
        end
        else begin // Clocked behavior (RST is high)
            if (clear_i) begin // Synchronous clear has priority
                count_r <= 10'b0;
            end
            else begin // Not clear_i
                if (increment_i) begin
                    count_r <= count_r + 10'd1; // FIX: Increment the counter
                end
                else begin // Not increment_i (and not clear_i)
                    count_r <= count_r; // Hold current value (count_o would also work as it's count_r)
                end
            end
        end
    end
endmodule


module counter_4_bit (
    input   wire            CLK,
    input   wire            RST,         // Active-low asynchronous reset
    input   wire            increment_i,
    input   wire            clear_i,
    output  wire     [3:0]  count_o
);

    reg     [3:0] count_r;

    // Assign the registered count value to the output
    assign count_o = count_r;

    always @(posedge CLK or negedge RST) begin
        if(~RST) begin // Active-low asynchronous reset
            count_r <= 4'b0;
        end
        else begin // Clocked behavior (RST is high)
            if (clear_i) begin // Synchronous clear has priority
                count_r <= 4'b0;
            end
            else begin // Not clear_i
                if (increment_i) begin
                    count_r <= count_r + 4'd1; // Increment the counter (This was already correct)
                end
                else begin // Not increment_i (and not clear_i)
                    count_r <= count_r; // Hold current value (count_o would also work as it's count_r)
                end
            end
        end
    end
endmodule
