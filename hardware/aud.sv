/*
 * Avalon memory-mapped peripheral that controls audio
 * Top Level Module
 * 
 * Storage procedure

normal: read from source, ram write/read disabled
    start = 0
    ram_e = 0
store into bram sequencially: write enabled read enabled
    start = 1
    ram_e = 1
read from bram sequencially: write disabled read enabled 
as read commands come in
    start = 0
    ram_e = 1
return to normal
    start = 0
    ram_e = 0

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

module bram
    #(
        parameter                           RAM_WIDTH = 24,
        parameter                           RAM_ADDR_BITS = 11,
        parameter                           RAM_WORDS = 2048
    )(
    input logic                             clk,
    input logic                             write_enable,          // Write din to addr
    input logic                             ram_enable,            // choose between din and mem[addr]
    input logic [RAM_ADDR_BITS-1:0]         addr,                  // Address to read/write
    input logic [RAM_WIDTH-1:0]             din,                   // Data to write
    output logic [RAM_WIDTH-1:0]            dout
    );

    logic [RAM_WIDTH-1:0]                   mem[RAM_WORDS-1:0];  // The RAM itself

    always_ff @(posedge clk) begin
        if (ram_enable) begin
            if (write_enable) begin
                mem[addr] <= din;
            end
            dout <= mem[addr];
        end
        else begin
            dout <= din;
        end   
    end
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
          output logic [31:0]       readdata         
          );

    //Audio Controller
    reg [23:0]      dac_left_in;
    reg [23:0]      dac_right_in;
    wire [23:0]     adc_left_out;
    wire [23:0]     adc_right_out;
    wire advance;
    
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

    //Instantiate block ram
    logic [23:0]    adc_out_buffer;
    logic [23:0]    buffer;
    logic [15:0]    ramAddr;
    logic           ram_e = 0;
    logic           start = 0;

    bram my_bram(
        .clk(clk),
        .write_enable(start),
        .ram_enable(ram_e),
        .addr(ramAddr),
        .din(adc_out_buffer[23:0]),
        .dout(buffer[23:0])    
        );

    //Instantiate hex decoders
    logic [23:0] hexout_buffer;
    hex7seg h5( .a(hexout_buffer[23:20]),.y(HEX5) ), // left digit
            h4( .a(hexout_buffer[19:16]),.y(HEX4) ), 
            h3( .a(hexout_buffer[15:12]),.y(HEX3) ), 
            h2( .a(hexout_buffer[11:8]),.y(HEX2) ),
            h1( .a(hexout_buffer[7:4]),.y(HEX1) ),
            h0( .a(hexout_buffer[3:0]),.y(HEX0) );    

    //Convert stereo input to mono        
    logic [23:0]    audioInMono;
    logic [15:0]    counter = 16'd0;

    always @ (*) begin
        audioInMono = (adc_right_out>>1) + (adc_left_out>>1);
    end

    //Determine when the driver is in the middle of pulling a sample
    logic [31:0]    driverReading = 31'd0;
    logic [15:0]    limit;
    logic [15:0]    writeCounter =  16'd0;
    logic [15:0]    readCounter =   16'd0;

    always @(posedge clk) begin
        // iowrite recieved
        if (chipselect && write) begin
            case (address)
                3'h6 : begin
                    // initiate storage of audio samples into bram
                    // enable ram and ram write
                    limit <= writedata[15:0];
                    start <= 1;
                    ram_e <= 1;
                    ramAddr <= writeCounter;
                    writeCounter <= writeCounter + 1;
                end
            endcase
        end   
        // ioread recieved
        if (chipselect && read) begin
            case (address)
                3'h5 : begin
                    // incirments read ramAddr if done writing to ram on a read command
                    if (ram_e && !start) begin
                        if (readCounter == limit) begin 
                            ram_e <= 0;
                            readCounter <= 0;
                            writeCounter <= 0;
                        end 
                        else begin
                            ramAddr <= readCounter;
                            readCounter <= readCounter + 1;
                        end
                    end
                    // Always if read signal will output the current buffer
                    // Which is the current result of bram
                    //    if ram_e = 1   dout = current bram[addr] 
                    //    if ram_e = 0   dout = din 
                    // pads for 2s compliment int
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
        if (advance) begin
            // bram is on main clk
            // according to bram, write enable is toggled on forever
            // every clock set adc_out_buffer to current audioInMono
            adc_out_buffer <= audioInMono;
            // runs only if still in memory writing stage
            // does not happen if current reciving a ioread/write
            if (start && ram_e && !write && !read) begin
                // check if limit number of samples has been reached
                if (writeCounter == limit) begin 
                    start <= 0;
                    ramAddr <= readCounter;
                    readCounter <= readCounter + 1;
                end
                // otherwise incirment the address
                else begin
                    ramAddr <= writeCounter;
                    writeCounter <= writeCounter + 1;
                end
            end
            // Hex display control
            if (counter[14]) begin
                hexout_buffer <= audioInMono;
            end
            counter <= counter + 1;
        end
    end

    wire sampleBeingTaken;
    assign sampleBeingTaken = driverReading[0];
    
    //Map timer(Sample) counter output
    parameter readOutSize = 2048;
    //Sample inputs/Audio passthrough

endmodule






















