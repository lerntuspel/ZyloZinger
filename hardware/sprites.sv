module sprites(
	input logic [5:0]          	n_sprite,
	input logic [9:0]          	line,
	input logic [5:0]			pixel,
	input logic                	clk,
	output logic [3:0]			color_code);
	
	logic [9:0] spr_rom_addr ;

	assign spr_rom_addr = (line<<5) + pixel;
	
	logic [3:0] spr_rom_data [24:0];
	// sprites indevidually stored in bram
	rom_sync #(
        .WIDTH(4),
        .DEPTH(1024),
        .INIT_F("0.mem")
    ) num_0 (
        .addr(spr_rom_addr),
        .data(spr_rom_data[0])
    );
	rom_sync #(
        .WIDTH(4),
        .DEPTH(1024),
        .INIT_F("1.txt")
    ) num_1 (
        .addr(spr_rom_addr),
        .data(spr_rom_data[1])
    );
	rom_sync #(
        .WIDTH(4),
        .DEPTH(1024),
        .INIT_F("2.txt")
    ) num_2 (
        .addr(spr_rom_addr),
        .data(spr_rom_data[2])
    );
	rom_sync #(
        .WIDTH(4),
        .DEPTH(1024),
        .INIT_F("3.txt")
    ) num_3 (
        .addr(spr_rom_addr),
        .data(spr_rom_data[3])
    );
	
	/*
	sprite_color_pallete colors(
		.color_code (color_code),
		.color (pixel_color)	
	);
	*/
	always_comb begin
		case (n_sprite)
			6'd1 : color_code = spr_rom_data[5'd0];
			6'd2 : color_code = spr_rom_data[5'd1];
			6'd3 : color_code = spr_rom_data[5'd2];
			6'd4 : color_code = spr_rom_data[5'd3];
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
			4'h0 : color = 24'h000000;
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
			4'hf : color = 24'h206000;
			default : color = 24'h0;
		endcase
	end
endmodule

module rom_sync #(
    parameter WIDTH=4,
    parameter DEPTH=1024,
    parameter INIT_F="",
    parameter ADDRW=10
    ) (
    input wire logic clk,
    input wire logic [ADDRW-1:0] addr,
    output     logic [WIDTH-1:0] data
    );

    logic [WIDTH-1:0] memory [DEPTH];

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
