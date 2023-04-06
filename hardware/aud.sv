/*
 * Avalon memory-mapped peripheral that controls audio
 * Top Level Module
 * 
 * Columbia University
 */

`include "global_variables.sv"
`include "./AudioCodecDrivers/audio_driver.sv"

// 7-Seg dispaly for debugging
module hex7seg(input logic  [3:0] a,
	       output logic [6:0] y);

   /* Replace this comment and the code below it with your solution */
	always_comb
		case (a)		//	   gfe_dcba
			4'h0:		y = 7'b100_0000;
			4'h1:		y = 7'b111_1001;
			4'h2:		y = 7'b010_0100;
			4'h3:		y = 7'b011_0000;
			4'h4:		y = 7'b001_1001;
			4'h5:		y = 7'b001_0010;
			4'h6:		y = 7'b000_0010;
			4'h7:		y = 7'b111_1000;
			4'h8:		y = 7'b000_0000;
			4'h9:		y = 7'b001_0000;
			4'hA:		y = 7'b000_1000;
			4'hB:		y = 7'b000_0011;
			4'hC:		y = 7'b100_0110;
			4'hD:		y = 7'b010_0001;
			4'hE:		y = 7'b000_0110;
			4'hF:		y = 7'b000_1110;
			default:	y = 7'b111_1111;
		endcase
endmodule

module audio_control( 
		  
		  input logic [3:0] 	KEY, // Pushbuttons; KEY[0] is rightmost
		  // 7-segment LED displays; HEX0 is rightmost
		  output logic [6:0] 	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
		  
		  //Audio pin assignments
		  //Used because Professor Scott Hauck and Kyle Gagner
		  output logic 			FPGA_I2C_SCLK,
		  inout					FPGA_I2C_SDAT,
		  output logic 			AUD_XCK,
		  input logic 			AUD_DACLRCK,
		  input logic 			AUD_ADCLRCK,
		  input logic 			AUD_BCLK,
		  input logic 			AUD_ADCDAT,
		  output logic 			AUD_DACDAT,
		  
		  //Driver IO ports
		  input logic 			clk,
		  input logic 			reset,
		  input logic [15:0]	writedata,
		  input logic 			write,
		  input logic 			read,
		  input 				chipselect,
		  input logic [15:0] 	address,
		  output logic [15:0] 	readdata
		  );

	//Audio Controller
	reg [23:0] dac_left_in;
	reg [23:0] dac_right_in;
	wire [23:0] adc_left_out;
	wire [23:0] adc_right_out;
	wire advance;
	reg [23:0] adc_out_buffer = 0;	
	reg [24:0] counter = 0;  //downsample adance signal
	
	//Device drivers from Altera modified by Professor Scott Hauck and Kyle Gagner in Verilog
	audio_driver aDriver(
		.CLOCK_50(clk), 
		.reset(reset), 
	 	.dac_left(dac_left_in), 
	 	.dac_right(dac_right_in), 
	 	.adc_left(adc_left_out), 
	 	.adc_right(adc_right_out), 
	 	.advance(advance), 
	 	.FPGA_I2C_SCLK(FPGA_I2C_SCLK), 
	 	.FPGA_I2C_SDAT(FPGA_I2C_SDAT), 
	 	.AUD_XCK(AUD_XCK), 
	 	.AUD_DACLRCK(AUD_DACLRCK), 
	 	.AUD_ADCLRCK(AUD_ADCLRCK), 
	 	.AUD_BCLK(AUD_BCLK), 
	 	.AUD_ADCDAT(AUD_ADCDAT), 
	 	.AUD_DACDAT(AUD_DACDAT)
	 	);

	//Instantiate hex decoders
	hex7seg h5( .a(adc_out_buffer[23:20]),.y(HEX5) ), // left digit
			h4( .a(adc_out_buffer[19:16]),.y(HEX4) ), 
			h3( .a(adc_out_buffer[15:12]),.y(HEX3) ), 
			h2( .a(adc_out_buffer[11:8]),.y(HEX2) ),
			h1( .a(adc_out_buffer[7:4]),.y(HEX1) ),
			h0( .a(adc_out_buffer[3:0]),.y(HEX0) );	

	//Convert stereo input to mono		
	reg [23:0] audioInMono;
	always @ (*) begin
		audioInMono = (adc_right_out/2) + (adc_left_out/2);
	end

	//Determine when the driver is in the middle of pulling a sample
	logic [7:0] driverReading = 8'd0;
	always @(posedge clk) begin
		if (chipselect && write) begin
			driverReading <= writedata;
		end	
		if (chipselect && read) begin
			if (address == 5) begin 
				readdata <= audioInMono[23:8];
			end
		end
	end
	
	wire sampleBeingTaken;
	assign sampleBeingTaken = driverReading[0];
	
	//Map timer(Sample) counter output
	parameter readOutSize = 2048;

	//Sample inputs/Audio passthrough
	always @(posedge advance) begin
		counter <= counter + 1;
		dac_left_in <= adc_left_out;
		dac_right_in <= adc_right_out;
	end
	
	always @(posedge counter[13]) begin
		adc_out_buffer <= audioInMono;
	end
endmodule






















