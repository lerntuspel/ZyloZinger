/*
 * Avalon memory-mapped peripheral that generates VGA 
 * Sprite generation method heavily inspired from touhou project from spring 2022 by Xinye Jiang and Po-Cheng Liu.
 * lightly modified by Alex you to 
 * Alex Yu
 * Columbia University
 */

module vga_zylo(
    input logic         clk,
    input logic         reset,
    input logic [31:0]  writedata,
    input logic         write,
    input logic         chipselect,
    input logic [15:0]  address,
                
    //vga ports
    output logic [7:0]  VGA_R, VGA_G, VGA_B,
    output logic        VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n,
    output logic        VGA_SYNC_n
    );

    // Display
    logic [10:0]        hcount;
    logic [9:0]         vcount;

    vga_counters counters(.clk50(clk), .*);

    //avalon bus address data mapping

    // display up to 16 falling notes on screen
    // writedata note packet
    // |  31:26  |      25:20      |      19:10       |      9:0       | 
    // |  index  |  note_id 6 bits |   y cord 10 bits | x-cord 10 bits | 
    // |  0-63   |      0-63       |      0-639       |     0-479      |
    // ex:   32h'1a004101 => en = 1, id = 10, type = 0100, y-cord = 256.

    //store up to 16 notes. each note is built with 32 8x8 pixel sprites
    logic           sprites_write;
    logic [5:0]     sprites_write_address;
    logic [5:0]     sprites_read_address;
    logic [9:0]     sprites_x_cord;
    logic [9:0]     sprites_y_cord;
    logic [5:0]     sprites_n_value;
    logic [9:0]     x, y;
    logic [5:0]     n;
    twoportbram #(
        .RAM_WIDTH(10),
        .RAM_ADDR_BITS(6),
        .RAM_WORDS(6'h3f)
    ) sprites_x (
        .clk(clk),
        .ra(sprites_read_address), 
        .wa(sprites_write_address),
        .write(sprites_write),
        .data_in(sprites_x_cord),
        .data_out(x)
    );
    twoportbram #(
        .RAM_WIDTH(10),
        .RAM_ADDR_BITS(6),
        .RAM_WORDS(6'h3f)
    ) sprites_y (
        .clk(clk),
        .ra(sprites_read_address), 
        .wa(sprites_write_address),
        .write(sprites_write),
        .data_in(sprites_y_cord),
        .data_out(y)
    );
    twoportbram #(
        .RAM_WIDTH(6),
        .RAM_ADDR_BITS(6),
        .RAM_WORDS(6'h3f)
    ) sprites_n (
        .clk(clk),
        .ra(sprites_read_address), 
        .wa(sprites_write_address),
        .write(sprites_write),
        .data_in(sprites_n_value),
        .data_out(n)
    );

    logic [15:0]        score;
    logic [15:0]        combo;
    logic [31:0]        menu;    // | 1 bit   | 8 bits |   8 bits  |s
                                // | display | item   | submenu # |
    logic [31:0]        gamedata;
    logic               reset_sw;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            score       <=  16'h0;
            combo       <=  16'h0;

        // data from avalon bus writes a piece of data to vram
        end else if (chipselect && write) begin
            case (address)
                4'h4 : begin
                    score <= writedata[15:0];
                    combo <= writedata[31:16];
                end
                4'h5 : begin
                    gamedata <= writedata;
                    reset_sw <= writedata[0];
                end
                    // note sprite sent             //32'h |000|00000|
                4'h6 :    begin                     //     |id | y x |
                    // store all top right corner coods of a "note"
                    sprites_x_cord          <= writedata[9:0];
                    sprites_y_cord          <= writedata[19:10];
                    sprites_n_value         <= writedata[25:20];
                    sprites_write_address   <= writedata[31:26];
                    sprites_write           <= 1;
                end
            endcase
        end else if (sprites_write) begin
            sprites_write <= 0;
        end
    end

    logic [9:0]         line;
    logic [31:0][23:0]  pattern;
    assign line = vcount - y;
	sprites sprites0(
        .n_sprite (n),
        .clk (clk),
        .line (line),
        .pattern (pattern)
        );


    logic [3:0] stage;
    logic [5:0] pixel;
    logic [9:0] xposition;  //on written buffer
	logic [23:0] buf_o_in, buf_e_in;
	logic [23:0] buf_o_out, buf_e_out;
    logic [23:0] buf_o1_in, buf_e1_in;
    logic [23:0] buf_o1_out, buf_e1_out;
    logic [23:0] buf_o2_in, buf_e2_in;
    logic [23:0] buf_o2_out, buf_e2_out;
    logic done;
    assign xposition = x + {4'd0, pixel};

    logic buf_o_w;
    logic buf_e_w;
	logic [9:0] xposition1,xposition2,xposition3,xposition4;  //on written buffer
	//4 line cycle
	//	o1    e1    o2    e2 
	//0 edit  idle  flush print
	//1	print edit  idle  flush
	//2	flush print edit  idle
	//3	idle  flush print edit
	always_comb begin
		case (vcount[1:0])
		    4'd0: begin
		    	buf_o1_in = buf_o_in;
		        buf_o2_in = 24'h000000;
		        buf_e1_in = 24'h000000;
		        buf_e2_in = 24'h000000;
		        buf_e_out = buf_e2_out;
		        buf_o_out = buf_o1_out;
		        xposition1 = xposition;
		        xposition2 = hcount[10:1];
		        xposition3 = hcount[10:1];
		        xposition4 = hcount[10:1];
		    end
		    4'd1: begin
		        buf_o1_in = 24'h000000;
		        buf_o2_in = 24'h000000;
		        buf_e1_in = buf_e_in;
		        buf_e2_in = 24'h000000;
		        buf_e_out = buf_e1_out;
		        buf_o_out = buf_o1_out;
		        xposition1 = hcount[10:1];
		        xposition2 = xposition;
		        xposition3 = hcount[10:1];
		        xposition4 = hcount[10:1];
		    end
		    4'd2: begin
		        
		        buf_o1_in = 24'h000000;
		        buf_o2_in = buf_o_in;
		        buf_e1_in = 24'h000000;
		        buf_e2_in = 24'h000000;
		        buf_e_out = buf_e1_out;
		        buf_o_out = buf_o2_out;
		        xposition1 = hcount[10:1];
		        xposition2 = hcount[10:1];
		        xposition3 = xposition;
		        xposition4 = hcount[10:1];
		    end
		    4'd3: begin
		        buf_o1_in = 24'h000000;
		        buf_o2_in = 24'h000000;
		        buf_e1_in = 24'h000000;
		        buf_e2_in = buf_e_in;
		        buf_o_out = buf_o2_out;
		        buf_e_out = buf_e2_out;
			    xposition1 = hcount[10:1];
		        xposition2 = hcount[10:1];
		        xposition3 = hcount[10:1];
			    xposition4 = xposition;
		    end
		endcase
	end
	
	
    twoportbram #(
        .RAM_WIDTH(24),
        .RAM_ADDR_BITS(10),
        .RAM_WORDS(10'h280)
    ) buf_o1_bram (
        .clk(clk),
        .ra(hcount[10:1]), 
        .wa(xposition1),
        .write(buf_o_w),
        .data_in(buf_o1_in),
        .data_out(buf_o1_out)
    );
    twoportbram #(
        .RAM_WIDTH(24),
        .RAM_ADDR_BITS(10),
        .RAM_WORDS(10'h280)
    ) buf_e1_bram (
        .clk(clk),
        .ra(hcount[10:1]), 
        .wa(xposition2),
        .write(buf_e_w),
        .data_in(buf_e1_in),
        .data_out(buf_e1_out)
    );
    twoportbram #(
        .RAM_WIDTH(24),
        .RAM_ADDR_BITS(10),
        .RAM_WORDS(10'h280)
    ) buf_o2_bram (
        .clk(clk),
        .ra(hcount[10:1]), 
        .wa(xposition3),
        .write(buf_o_w),
        .data_in(buf_o2_in),
        .data_out(buf_o2_out)
    );
    twoportbram #(
        .RAM_WIDTH(24),
        .RAM_ADDR_BITS(10),
        .RAM_WORDS(10'h280)
    ) buf_e2_bram (
        .clk(clk),
        .ra(hcount[10:1]), 
        .wa(xposition4),
        .write(buf_e_w),
        .data_in(buf_e2_in),
        .data_out(buf_e2_out)
    );



    //paint basic background
    logic [23:0] bg_color;
    logic [23:0] buf_bg_color;
    always_ff @(posedge clk) begin
        if      (vcount == 10'd0)   bg_color <= 24'h223399;
        else if (vcount == 10'd80)  bg_color <= 24'h2244AA;
        else if (vcount == 10'd140) bg_color <= 24'h2255BB;
        else if (vcount == 10'd190) bg_color <= 24'h2266CC;
        else if (vcount == 10'd230) bg_color <= 24'h2277DD;
        else if (vcount == 10'd265) bg_color <= 24'h2299EE;
        else if (vcount == 10'd295) bg_color <= 24'h22BBFF;
        else if (vcount == 10'd320) bg_color <= 24'h226600;
    end

    always_ff @(posedge clk) begin
        if(reset) begin
            stage <= 0;
            sprites_read_address <= 0;
            pixel <= 0;
            done <= 1;
        end else begin
            if (vcount[0]) begin     // output buffer_odd, edit buffer_even
                buf_o_w <= 0;
                buf_e_w <= 1;
            end else begin           // output buffer_even, edit buffer_odd
                buf_o_w <= 1;
                buf_e_w <= 0;
            end

            if (hcount == 11'd1) begin
                done <= 0;                  // 0/1
                stage <= 0;                 // 0-2
                sprites_read_address <= 0;  // 0-63
                pixel <= 0;                 // 0-31
            end

            if(~done)begin
                case(stage)
                    4'd0 : begin
                        sprites_read_address <= 6'd0;
                        pixel <= 0;
                        stage <= stage + 4'd1;
                        // x,y,n usable in following clock cycle 
                    end
                    4'd1 : begin    //skips a sprite or check for end of sprite addresses 
                        if ((n == 0) || (vcount - y >= 32)) begin   // target sprite not in this line
                            pixel <= 6'd0;                          // reset pixel
                            stage <= 4'd0;                          // reset stage
                            if (sprites_read_address < 9'd32) // check if there are more sprites to check (existance of 32 potential sprites)
                                sprites_read_address <= sprites_read_address + 8'd1;
                            else
                                done <= 1;
                        end else begin // move to next stage if is in line
                            stage <= stage + 4'd1;
                        end
                        // line ready
                    end
                    4'd2 : begin
                        if (vcount[0]) begin        // output buffer_odd, edit buffer_even
                            if (xposition < 10'd640) begin
                                if (pattern[pixel] == 24'h0) 
                                    buf_e_in <= bg_color;
                                else
                                    buf_e_in <= pattern[pixel];
                            end
                        end else begin              // output buffer_even, edit buffer_odd
                            if (xposition < 10'd640) begin
                                if (pattern[pixel] == 24'h0) 
                                    buf_o_in <= bg_color;
                                else
                                    buf_o_in <= pattern[pixel];
                            end
                        end
						// repeat writing stage pixel is 30 or under
                        if (pixel < 6'd31) begin
                            pixel <= pixel + 1;
                            stage <= stage;
                        // or 
                        end else begin		//WHEN pixels are done writing to buf set stage to 0
                            pixel <= 6'd0;
                            stage <= 4'd0;
                            if (sprites_read_address < 9'd32)
                                sprites_read_address <= sprites_read_address + 8'd1;
                            else
                                done <= 1;
                        end
                    end
                    default:;
                endcase
            end
        end
    end

    always_comb begin
        {VGA_R, VGA_G, VGA_B} = {bg_color};
        if (VGA_BLANK_n )
            if (vcount < 10'd480) begin
                if (vcount[0]) begin    // output buffer_odd, edit buffer_even
                    if ((buf_o_out != bg_color) && (buf_o_out != 24'h0))
                        {VGA_R, VGA_G, VGA_B} = buf_o_out;
                    else 
                        {VGA_R, VGA_G, VGA_B} = {bg_color};
                end else begin            // output buffer_even, edit buffer_odd
                    if ((buf_e_out != bg_color) && (buf_e_out != 24'h0))
                        {VGA_R, VGA_G, VGA_B} = buf_e_out;
                    else 
                        {VGA_R, VGA_G, VGA_B} = {bg_color};
                end
            end
    end
    

endmodule

module vga_counters(
    input logic              clk50, reset,
    output logic [10:0]     hcount,  // hcount[10:1] is pixel column
    output logic [9:0]      vcount,  // vcount[9:0] is pixel row
    output logic              VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);

/*
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 * 
 * HCOUNT 1599 0             1279       1599 0
 *             _______________              ________
 * ___________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 */
// Parameters for hcount
    parameter 
          HACTIVE      = 11'd 1280,
          HFRONT_PORCH = 11'd 32,
          HSYNC        = 11'd 192,
          HBACK_PORCH  = 11'd 96,   
          HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC +
          HBACK_PORCH; // 1600

          // Parameters for vcount
          parameter 
          VACTIVE      = 10'd 480,
          VFRONT_PORCH = 10'd 10,
          VSYNC        = 10'd 2,
          VBACK_PORCH  = 10'd 33,
          VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC +
          VBACK_PORCH; // 525

          logic endOfLine;

    always_ff @(posedge clk50 or posedge reset)
        if (reset)          hcount <= 0;
        else if (endOfLine) hcount <= 0;
        else               hcount <= hcount + 11'd 1;

    assign endOfLine = hcount == HTOTAL - 1;

    logic endOfField;

    always_ff @(posedge clk50 or posedge reset)
        if (reset)          vcount <= 0;
        else if (endOfLine)
            if (endOfField)   vcount <= 0;
            else              vcount <= vcount + 10'd 1;

    assign endOfField = vcount == VTOTAL - 1;

    // Horizontal sync: from 0x520 to 0x5DF (0x57F)
    // 101 0010 0000 to 101 1101 1111
    assign VGA_HS = !( (hcount[10:8] == 3'b101) &
                    !(hcount[7:5] == 3'b111));
    assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);

    assign VGA_SYNC_n = 1'b0; // For putting sync on the green signal; unused

    // Horizontal active: 0 to 1279     Vertical active: 0 to 479
    // 101 0000 0000  1280           01 1110 0000  480
    // 110 0011 1111  1599           10 0000 1100  524
    assign VGA_BLANK_n =     !( hcount[10] & (hcount[9] | hcount[8]) ) &
                            !( vcount[9] | (vcount[8:5] == 4'b1111) );

        /* VGA_CLK is 25 MHz
         *             __    __    __
         * clk50    __|  |__|  |__|
         *        
         *             _____       __
         * hcount[0]__|     |_____|
         */
    assign VGA_CLK = hcount[0]; // 25 MHz clock: rising edge sensitive

endmodule

