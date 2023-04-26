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
    // |  31  |      27:24      |      15:12       |      9:0       | 
    // |  en  |  note_id 4 bits | note_type 4 bits | y-cord 10 bits | 
    // | 1/0  |      0-15       |  notes 1,2,3,4   |     0-479      |
    // ex:   32h'1a004101 => en = 1, id = 10, type = 0100, y-cord = 256.

    //store up to 16 notes. each note is built with 32 8x8 pixel sprites
    logic [31:0][9:0]  sprites_x;
    logic [31:0][9:0]  sprites_y;
    logic [31:0][5:0]  sprites_n;
    
    logic [15:0]        score;
    logic [15:0]        combo;
    logic [31:0]        menu;    // | 1 bit   | 8 bits |   8 bits  |s
                                // | display | item   | submenu # |
    logic [31:0]        gamedata;
    logic               reset_sw;

    always_ff @(posedge clk) begin
        if (reset) begin
            sprites_x   <=  {32{10'd0}}; // up to 31 sprites to display on screen
            sprites_y   <=  {32{10'd0}};
            sprites_n   <=  {32{6'd0}}; // number of active sprites
            score       <=  {4{4'h0}};
            combo       <=  {4{4'h0}};

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
                    sprites_x   [writedata[31:28]][9:0] <=  writedata[9:0];
                    sprites_y   [writedata[31:28]][9:0] <=  writedata[19:10];
                    sprites_n   [writedata[31:28]][5:0] <=  writedata[25:20];
                end

            endcase
        end
    end

    logic [9:0]         line;
    logic [31:0][23:0]  pattern;
    //logic [5:0]         length;
    logic [5:0]         n;
    // sprites in sprites.sv are ordered from least prioety to highest priorety
    
	sprites sprites0(
        .n_sprite (n),
        .clk (clk),
        .line (line),
        .pattern (pattern)
        );
	

    logic [9:0] x, y;
    logic [639:0][23:0] buf_e;
    logic [639:0][23:0] buf_o;
    logic [3:0] stage;
    logic [8:0] count;
    logic [5:0] pixel;
    logic [9:0] xposition;
    logic done;

    assign xposition = x + {4'd0, pixel};
    //paint basic background
    logic [23:0] bg_color;
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
            buf_e <= {640{24'hdd1122}};
            buf_o <= {640{24'hdd1122}};
            stage <= 0;
            count <= 0;
            pixel <= 0;
            done <= 1;
        end else begin
            // create new "canvas" if hcount is over 640 and vcount has just changed
            if (vcount[0]) begin     // output buffer_odd, edit buffer_even
                if ((hcount[10:1] > 640) && (vcount < 10'd480))
                    buf_o <= {640{bg_color}};     // background color
            end else begin         // output buffer_even, edit buffer_odd
                if ((hcount[10:1] > 640) && (vcount < 10'd480))
                    buf_e <= {640{bg_color}};     // background color
            end

            if (hcount == 11'd1) begin
                done <= 0;  // 0/1
                stage <= 0; // 0-2
                count <= 0; // 0-127
                pixel <= 0; // 0-31
            end
            if(~done)begin
                case(stage)
                    4'd0 : begin
                        n <= sprites_n[count];
                        x <= sprites_x[count];
                        y <= sprites_y[count];
                        pixel <= 0;
                        if (vcount >= 10'd479) // if vcount is off the screen -> new screen
                            line <= 10'd32;		// end early
                        else
                            line <= vcount - sprites_y[count];
                        stage <= stage + 4'd1;
                    end
                    4'd1 : begin
                        if ((n == 0) || (line >= 32)) begin // not in this line
                            pixel <= 6'd0;
                            stage <= 4'd0;
                            if (count < 9'd32) // check if there are more sprites to check (existance of 32 potential sprites)
                                count <= count + 8'd1;
                            else
                                done <= 1;
                        end else begin
                            stage <= stage + 4'd1;
                        end
                    end
                    4'd2 : begin
                        if (vcount[0]) begin     // output buffer_odd, edit buffer_even
                            if (pattern[pixel] != 24'h0) begin
                                if (xposition < 10'd640)
                                    buf_e[xposition] <= pattern[pixel];
                            end
                        end else begin             // output buffer_even, edit buffer_odd
                            if (pattern[pixel] != 24'h0) begin
                                if (xposition < 10'd640)
                                    buf_o[xposition] <= pattern[pixel];
                            end
                        end
						// repeat writing stage pixel is 30 or under
                        if (pixel < 6'd31) begin
                            pixel <= pixel + 1;
                            stage <= stage;
                        // or 
                        end else begin
                            pixel <= 6'd0;
                            stage <= 4'd0;
                            if (count < 9'd32)
                                count <= count + 8'd1;
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
                    {VGA_R, VGA_G, VGA_B} = buf_o[hcount[10:1]][23:0];
                end else begin            // output buffer_even, edit buffer_odd
                    {VGA_R, VGA_G, VGA_B} = buf_e[hcount[10:1]][23:0];
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


