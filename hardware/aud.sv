/*
 * Avalon memory-mapped peripheral that handles audio inputs
 * Utilizes a audio driver that handles Altera driver files.
 * Functions to both store 1.5 seconds of 48khz audio data into BRAM for the Avalon bus to read out
 * Also can send to software the readout the result of the detector moudule.
 * Alex Yu, Sienna Brent, Rajat Tyagi, Riona westphal
 * Columbia University
 */

`include "global_variables.sv"
`include "./AudioCodecDrivers/audio_driver.sv"

//`define RAM_ADDR_BITS 5'd16
//`define RAM_WORDS 16'd48000

// 7-Seg dispaly for debugging
module hex7seg(input logic  [3:0] a,
               output logic [6:0] y);

   /* Replace this comment and the code below it with your solution */
    always_comb
        case (a)        //      gfe_dcba
            4'h0:        y = 7'b100_0000;
            4'h1:        y = 7'b111_1001;
            4'h2:        y = 7'b010_0100;
            4'h3:        y = 7'b011_0000;
            4'h4:        y = 7'b001_1001;
            4'h5:        y = 7'b001_0010;
            4'h6:        y = 7'b000_0010;
            4'h7:        y = 7'b111_1000;
            4'h8:        y = 7'b000_0000;
            4'h9:        y = 7'b001_0000;
            4'hA:        y = 7'b000_1000;
            4'hB:        y = 7'b000_0011;
            4'hC:        y = 7'b100_0110;
            4'hD:        y = 7'b010_0001;
            4'hE:        y = 7'b000_0110;
            4'hF:        y = 7'b000_1110;
            default:     y = 7'b111_1111;
        endcase
endmodule

module audio_control( 
        input logic [3:0]         KEY, // Pushbuttons; KEY[0] is rightmost
        // 7-segment LED displays; HEX0 is rightmost
        output logic [6:0]        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
        
        //Audio pin assignments
        //Used because Professor Scott Hauck and Kyle Gagner
        output logic              FPGA_I2C_SCLK,
        inout                     FPGA_I2C_SDAT,
        output logic              AUD_XCK,
        input logic               AUD_ADCLRCK,
        input logic               AUD_DACLRCK,
        input logic               AUD_BCLK,
        input logic               AUD_ADCDAT,
        output logic              AUD_DACDAT,
        
        //Driver IO ports
        input logic               clk,
        input logic               reset,
        input logic [31:0]        writedata,
        input logic               write,
        input logic               read,
        input                     chipselect,
        input logic [15:0]        address,
        output logic [31:0]       readdata,     

        //Bram controls
        output logic [15:0]       bram_wa,
        output logic [15:0]       bram_ra,
        output logic              bram_write = 0,
        output logic [23:0]       bram_data_in,
        input logic [23:0]        bram_data_out,
        
        //goertzel control
        output logic [23:0]       adc_out_buffer,
        output logic              advance,
        
        //detector return
        input logic [2:0]         result,
        input logic [2:0]         overall_result,
        input logic               flag
        );

    //Audio Controller
    reg [23:0]      dac_left_in;
    reg [23:0]      dac_right_in;
    wire [23:0]     adc_left_out;
    wire [23:0]     adc_right_out;
    // wire advance;
    
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
    logic [23:0]    hexout_buffer;
    hex7seg h5( .a(buffer[3:0]),.y(HEX5) ), // left digit
            h4( .a(result_buffer[3:0]),.y(HEX4) ), 
            h3( .a(hexout_buffer[3:0]),.y(HEX3) ), 
            h2( .a({1'b0, result}),.y(HEX2) ),
            h1( .a({3'b0, bram_reading}),.y(HEX1) ),
            h0( .a(bram_input_ctrl[3:0]),.y(HEX0) );    

    //Convert stereo input to mono        
    logic [23:0]    audioInMono;
    logic [15:0]    counter = 16'd0;
    wire  [23:0]     buffer;
    
    logic [3:0]     bram_input_ctrl;
    logic [3:0]     result_buffer;
    logic           write_clk;

    always_comb begin
        audioInMono = (adc_right_out>>1) + (adc_left_out>>1);
        bram_data_in = adc_out_buffer;
        if (bram_reading)
            buffer = bram_data_out;
        else
            buffer = {20'b0, result_buffer};
    end

    //Determine when the driver is in the middle of pulling a sample
    //by default dont use the BRAM module
    logic           bram_writing = 0;
    logic           bram_reading = 0;
    logic [31:0]    driverReading = 31'd0;
    logic [15:0]    limit;
    // logic [23:0]    adc_out_buffer;
    always_ff @(posedge clk) begin : IOcalls
        // iowrite recieved
        if (chipselect && write) begin
            case (address)
                16'h0001 : begin
                    // initiate storage of audio samples into bram
                    // reset bram_wa to 0
                    // writing is the continuous signal that tells 
                    // aud_control that bram is in use
                    if (!bram_writing) begin
                        limit <= writedata[15:0];
                        bram_writing <= 1;
                        // if the write limti sent by software is 0, then dont read from bram otherwise, do read from bram
                        if (writedata[15:0] == 16'h0000)                        
                            bram_reading <= 0;
                        else 
                            bram_reading <= 1;
                        bram_wa <= -1;
                    end
                end
                16'h0002 : begin
                    // choose bram read address
                    bram_ra <= writedata[15:0];
                end
                16'h0003 : begin
                    bram_input_ctrl[3:0] <= writedata[3:0];
                end
            endcase
        end   
        // ioread recieved
        if (chipselect && read) begin
            case (address)
                16'h0000 : begin
                    // return padded buffer
                    if (buffer[23] == 1) begin 
                        readdata[23:0] <= buffer[23:0];
                        readdata[31:24] <= 8'b11111111;
                    end
                    else if (buffer[23] == 0) begin
                        readdata[23:0] <= buffer[23:0];
                        readdata[31:24] <= 8'b00000000;
                    end
                end
            endcase
        end
        // On advance (new audio sample avalable)
        // bram_write signal pulse
        if (bram_write) bram_write <= 0;
        // this clock cycle writes the previous clock cycles 
        // adc_out_buffer into the current bram_wa
        if (advance) begin
            result_buffer <= {1'b0, overall_result};
            // behavior during write bram procedure
            if (bram_writing && !bram_write) begin
                // check if limit number of samples has been reached
                if (bram_wa == limit) begin 
                    bram_writing <= 0;
                end
                // otherwise set bram write and incirment the address
                else begin
                    bram_write <= 1;
                    bram_wa <= bram_wa + 1;
                end
            end
        end
        if (advance) begin
			adc_out_buffer <= audioInMono;  
        // HEX display
            if (counter[13:0] == 0) begin
                hexout_buffer <= result_buffer;
            end
            counter <= counter + 1;
        end
    end

    wire sampleBeingTaken;
    assign sampleBeingTaken = driverReading[0];
    
    //Map timer(Sample) counter output
    parameter readOutSize = 16'hffff;
    //Sample inputs/Audio passthrough

endmodule
