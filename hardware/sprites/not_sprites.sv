/*
	Sprite lookup table
	Color lookup table
	takes in a spirte id and line number
	sprites are no larger than 8*8
	returns a color for each pixel in the line
*/
module notsprites(
	input logic [3:0]          	sprite_id,
	input logic [3:0]          	line,
	input logic                	clk,
	output logic [7:0]		bit_pattern
	);
	
	logic [31:0] bit_pattern;
	always_ff @(posedge clk) begin
		case (sprite_id)
			4'd1 : begin // top left corner of 
				case (line)
					4'h0 : bit_pattern <= 8'b00000000;
					4'h1 : bit_pattern <= 8'b00000000;
					4'h2 : bit_pattern <= 8'b00000000;
					4'h3 : bit_pattern <= 8'b00000000;
					4'h4 : bit_pattern <= 8'b00001111;
					4'h5 : bit_pattern <= 8'b00001111;
					4'h6 : bit_pattern <= 8'b00001111;
					4'h7 : bit_pattern <= 8'b00001111;
				endcase
			end
			4'd2 : begin //top right corner
				case (line)
					16'h0 : bit_pattern <= 8'b00000000;
					16'h1 : bit_pattern <= 8'b00000000;
					16'h2 : bit_pattern <= 8'b00000000;
					16'h3 : bit_pattern <= 8'b00000000;
					16'h4 : bit_pattern <= 8'b11110000;
					16'h5 : bit_pattern <= 8'b11110000;
					16'h6 : bit_pattern <= 8'b11110000;
					16'h7 : bit_pattern <= 8'b11110000;
				endcase
			end
			4'd3 : begin //bottom left corner
				case (line)
					16'h0 : bit_pattern <= 8'b00001111;
					16'h1 : bit_pattern <= 8'b00001111;
					16'h2 : bit_pattern <= 8'b00001111;
					16'h3 : bit_pattern <= 8'b00001111;
					16'h4 : bit_pattern <= 8'b00000000;
					16'h5 : bit_pattern <= 8'b00000000;
					16'h6 : bit_pattern <= 8'b00000000;
					16'h7 : bit_pattern <= 8'b00000000;
				endcase
			end
			4'd3 : begin //bottom left corner
				case (line)
					16'h0 : bit_pattern <= 8'b11110000;
					16'h1 : bit_pattern <= 8'b11110000;
					16'h2 : bit_pattern <= 8'b11110000;
					16'h3 : bit_pattern <= 8'b11110000;
					16'h4 : bit_pattern <= 8'b00000000;
					16'h5 : bit_pattern <= 8'b00000000;
					16'h6 : bit_pattern <= 8'b00000000;
					16'h7 : bit_pattern <= 8'b00000000;
				endcase
			end
			4'd4 : begin // top edge
				case (line)
					4'h0 : bit_pattern <= 8'b00000000;
					4'h1 : bit_pattern <= 8'b00000000;
					4'h2 : bit_pattern <= 8'b00000000;
					4'h3 : bit_pattern <= 8'b00000000;
					4'h4 : bit_pattern <= 8'b11111111;
					4'h5 : bit_pattern <= 8'b11111111;
					4'h6 : bit_pattern <= 8'b11111111;
					4'h7 : bit_pattern <= 8'b11111111;
				endcase
			end
			4'd5 : begin // right edge
				case (line)
					16'h0 : bit_pattern <= 8'b11110000;
					16'h1 : bit_pattern <= 8'b11110000;
					16'h2 : bit_pattern <= 8'b11110000;
					16'h3 : bit_pattern <= 8'b11110000;
					16'h4 : bit_pattern <= 8'b11110000;
					16'h5 : bit_pattern <= 8'b11110000;
					16'h6 : bit_pattern <= 8'b11110000;
					16'h7 : bit_pattern <= 8'b11110000;
				endcase
			end
			4'd6 : begin // left edge
				case (line)
					16'h0 : bit_pattern <= 8'b00001111;
					16'h1 : bit_pattern <= 8'b00001111;
					16'h2 : bit_pattern <= 8'b00001111;
					16'h3 : bit_pattern <= 8'b00001111;
					16'h4 : bit_pattern <= 8'b00001111;
					16'h5 : bit_pattern <= 8'b00001111;
					16'h6 : bit_pattern <= 8'b00001111;
					16'h7 : bit_pattern <= 8'b00001111;
				endcase
			end
			4'd7 : begin // bottom edge
				case (line)
					16'h0 : bit_pattern <= 8'b11111111;
					16'h1 : bit_pattern <= 8'b11111111;
					16'h2 : bit_pattern <= 8'b11111111;
					16'h3 : bit_pattern <= 8'b11111111;
					16'h4 : bit_pattern <= 8'b00000000;
					16'h5 : bit_pattern <= 8'b00000000;
					16'h6 : bit_pattern <= 8'b00000000;
					16'h7 : bit_pattern <= 8'b00000000;
				endcase
			end
			4'd7 : begin // filled
				case (line)
					16'h0 : bit_pattern <= 8'b11111111;
					16'h1 : bit_pattern <= 8'b11111111;
					16'h2 : bit_pattern <= 8'b11111111;
					16'h3 : bit_pattern <= 8'b11111111;
					16'h4 : bit_pattern <= 8'b11111111;
					16'h5 : bit_pattern <= 8'b11111111;
					16'h6 : bit_pattern <= 8'b11111111;
					16'h7 : bit_pattern <= 8'b11111111;
				endcase
			end
			default : begin
				bit_pattern <= 8'b00000000;
			end
		endcase
	end
endmodule

module notsprite_color_decoder(	
	// if selection is 0, it means transparent
	input logic [7:0]          	pallete,
	input logic [3:0]			color_selection,
	input logic                	clk,
	output logic [23:0]  		color
	);
	always_ff @(posedge clk) begin
		case (pallete)
			16'd1 : begin // g falling note bar (color = ff3333)
				case (color_selection) //red pallete
					4'h1 : color <= 24'hf21922;
					4'h2 : color <= 24'he51522;
					4'h3 : color <= 24'hd71120;
					4'h4 : color <= 24'hca0d1f;
					4'h5 : color <= 24'hbe091e;
					4'h6 : color <= 24'hb1061c;
					4'h7 : color <= 24'ha4041b;
					4'h8 : color <= 24'h980319;
					4'h9 : color <= 24'h8b0117;
					4'ha : color <= 24'h7f0115;
					4'hb : color <= 24'h730013;
					4'hc : color <= 24'h670010;
					4'hd : color <= 24'h5b000d;
					4'he : color <= 24'h500008;
					4'hf : color <= 24'h450003;
				endcase
			end
			16'd2 : begin 
				case (color_selection) //blue pallete
					4'h1 : color <= 24'h00dffc;
					4'h2 : color <= 24'h00d5f9;
					4'h3 : color <= 24'h00caf6;
					4'h4 : color <= 24'h00c0f2;
					4'h5 : color <= 24'h00b5ed;
					4'h6 : color <= 24'h00aae9;
					4'h7 : color <= 24'h009fe3;
					4'h8 : color <= 24'h0094dd;
					4'h9 : color <= 24'h008ad7;
					4'ha : color <= 24'h007fd0;
					4'hb : color <= 24'h0074c8;
					4'hc : color <= 24'h0069bf;
					4'hd : color <= 24'h005eb6;
					4'he : color <= 24'h0052ac;
					4'hf : color <= 24'h0d47a1;
				endcase
			end
			16'd3 : begin 
				case (color_selection) //orange pallete
					4'h1 : color <= 24'h
					4'h2 : color <= 24'h
					4'h3 : color <= 24'h
					4'h4 : color <= 24'h
					4'h5 : color <= 24'h
					4'h6 : color <= 24'h
					4'h7 : color <= 24'h
					4'h8 : color <= 24'h
					4'h9 : color <= 24'h
					4'ha : color <= 24'h
					4'hb : color <= 24'h
					4'hc : color <= 24'h
					4'hd : color <= 24'h
					4'he : color <= 24'h
					4'hf : color <= 24'h
				endcase
			end
			16'd4 : begin 
				case (color_selection) //green pallete
					4'h1 : color <= 24'
					4'h2 : color <= 24'
					4'h3 : color <= 24'
					4'h4 : color <= 24'
					4'h5 : color <= 24'
					4'h6 : color <= 24'
					4'h7 : color <= 24'
					4'h8 : color <= 24'
					4'h9 : color <= 24'
					4'ha : color <= 24'
					4'hb : color <= 24'
					4'hc : color <= 24'
					4'hd : color <= 24'
					4'he : color <= 24'
					4'hf : color <= 24'
				endcase
			end
		endcase
	end
endmodule
