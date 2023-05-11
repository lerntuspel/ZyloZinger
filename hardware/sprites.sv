/*
 * Sprite ROM seletor and color decoders as well as syncronous ROM module
 * Alex Yu
 * Columbia University
 */
 
 module sprites(
	input logic [5:0]          	n_sprite,
	input logic [9:0]          	line,
	input logic [5:0]			pixel,
	input logic                	clk,
	output logic [3:0]			color_code);
	
	logic [9:0] spr_rom_addr ;

	assign spr_rom_addr = (line<<5) + pixel;
	
	logic [3:0] spr_rom_data [31:0];
	// sprites indevidually stored in roms

	// numbers
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/1.mem")
    ) num_1 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd1])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/2.mem")
    ) num_2 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd2])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/3.mem")
    ) num_3 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd3])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/4.txt")
    ) num_4 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd4])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/5.txt")
    ) num_5 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd5])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/6.txt")
    ) num_6 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd6])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/7.txt")
    ) num_7 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd7])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/8.txt")
    ) num_8 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd8])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/9.txt")
    ) num_9 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd9])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/0.mem")
    ) num_10 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd10])
    );

	// Letters 
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/B.txt")
    ) num_11 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd11])
    );
	
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/C.txt")
    ) num_12 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd12])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/E.txt")
    ) num_13 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd13])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/M.txt")
    ) num_14 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd14])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/O.txt")
    ) num_15 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd15])
    );
	
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/R.txt")
    ) num_16 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd16])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/S.txt")
    ) num_17(
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd17])
    );
	// NOTE BLOCKS
	rom_sync #( //blue
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Blue-left.txt")
    ) num_18 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd20])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Blue-right.txt")
    ) num_19 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd21])
    );
	rom_sync #( //orange
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Orange-left.txt")
    ) num_20 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd18])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Orange-right.txt")
    ) num_21 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd19])
    );
	rom_sync #( //pink
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Pink-left.txt")
    ) num_22 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd22])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Pink-right.txt")
    ) num_23 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd23])
    );
	rom_sync #(//purple
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Purple-left.txt")
    ) num_24 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd24])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/Purple-right.txt")
    ) num_25 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd25])
    );
	rom_sync #(//purple
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/A.txt")
    ) num_26 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd26])
    );
	rom_sync #(
        .WIDTH(4),
        .WORDS(1024),
        .INIT_F("./sprites/Sprite_rom/X.txt")
    ) num_27 (
	.clk(clk),
        .addr(spr_rom_addr),
        .data(spr_rom_data[6'd27])
    );


	always_comb begin
		case (n_sprite)
			// numbers
			6'd1  : color_code = spr_rom_data[6'd1];  // 1
			6'd2  : color_code = spr_rom_data[6'd2];  // 2 
			6'd3  : color_code = spr_rom_data[6'd3];  // 3
			6'd4  : color_code = spr_rom_data[6'd4];  // 4
			6'd5  : color_code = spr_rom_data[6'd5];  // 5
			6'd6  : color_code = spr_rom_data[6'd6];  // 6
			6'd7  : color_code = spr_rom_data[6'd7];  // 7
			6'd8  : color_code = spr_rom_data[6'd8];  // 8
			6'd9  : color_code = spr_rom_data[6'd9];  // 9
			6'd10 : color_code = spr_rom_data[6'd10]; // 10
			// letters 
			6'd11 : color_code = spr_rom_data[6'd11]; // B
			6'd12 : color_code = spr_rom_data[6'd12]; // C
			6'd13 : color_code = spr_rom_data[6'd13]; // E
			6'd14 : color_code = spr_rom_data[6'd14]; // M
			6'd15 : color_code = spr_rom_data[6'd15]; // O 
			6'd16 : color_code = spr_rom_data[6'd16]; // R
			6'd17 : color_code = spr_rom_data[6'd17]; // S
			// notes
			6'd18 : color_code = spr_rom_data[6'd18]; // orange l
			6'd19 : color_code = spr_rom_data[6'd19]; // orange r
			6'd20 : color_code = spr_rom_data[6'd20]; // blue l
			6'd21 : color_code = spr_rom_data[6'd21]; // blue r
			6'd22 : color_code = spr_rom_data[6'd22]; // pink l
			6'd23 : color_code = spr_rom_data[6'd23]; // pink r
			6'd24 : color_code = spr_rom_data[6'd24]; // purple l
			6'd25 : color_code = spr_rom_data[6'd25]; // purple r
			// A/X added later
			6'd26 : color_code = spr_rom_data[6'd26]; // A
			6'd27 : color_code = spr_rom_data[6'd27]; // X
			
			default : begin
				color_code <= 4'h0;
			end
		endcase
	end
endmodule

module sprite_color_pallete(
	input logic [3:0] 	color_code_o,
	input logic [3:0] 	color_code_e,
	input logic 		select,
	output logic [23:0]	color
	);
	logic [3:0] color_code;
	assign color_code = (select) ? color_code_o : color_code_e;
	always_comb begin
		case(color_code)
			//sprite colors
			4'h0 : color = 24'h222222;
			4'h1 : color = 24'hffddb6;
			4'h2 : color = 24'hff881f;
			4'h3 : color = 24'hffceb6;
			4'h4 : color = 24'hcc7a7a;
			4'h5 : color = 24'hb6efff;
			4'h6 : color = 24'h5bc4de;
			4'h7 : color = 24'hdab6ff;
			4'h8 : color = 24'h7d6ba8;
			4'h9 : color = 24'hffb6b6;
			4'ha : color = 24'hb6ffc3;
			//background colors
			4'hb : color = 24'h203090;
			4'hc : color = 24'h2040A0;
			4'hd : color = 24'h2060C0;
			4'he : color = 24'h2090E0;
			4'hf : color = 24'h64a460;
			default : color = 24'h000000;
		endcase
	end
endmodule

module rom_sync #(
    parameter WIDTH=4,
    parameter WORDS=1024,
    parameter INIT_F="",
    parameter ADDRW=10
    ) (
    input wire logic clk,
    input wire logic [ADDRW-1:0] addr,
    output     logic [WIDTH-1:0] data
    );

    logic [WIDTH-1:0] memory [WORDS];

    initial begin
        if (INIT_F != 0) begin
            $display("Creating rom_sync from init file '%s'.", INIT_F);
            $readmemh(INIT_F, memory);
        end
    end

    always_ff @(posedge clk) begin
        data <= memory[addr];
    end
endmodule
