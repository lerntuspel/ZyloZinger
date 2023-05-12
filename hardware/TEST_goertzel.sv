`include "goertzel_int.sv"
`include "detector.sv"

`define FFT_WIDTH 10 //2^10 = 1024 polongint FFT
`define FFT_MAG 1024
`define BIN_NUM 3

`define FILE_LENGTH 48000

`define SIGNAL_IN_FN "audio_samples/piano8_1.txt"

module testbench();

logic clk = 0;
logic reset;
int input_sig_32;
logic signed [23:0] input_sig;
int ret_read;

longint power_34;
longint power_43;
longint power_51;
longint power_9;
longint power_67;

int i;
int signal_in_file;

longint max_power;

logic [2:0] detection_result;
logic [2:0] overall_result;

//piano 1
goertzel goertzel_34(
    .clk(clk),
    .reset(reset),
    .input_sig(input_sig),
	.bin_coeff(16413441),
    .power(power_34),
    .advance(advance_34)
);

//piano 3
goertzel goertzel_43(
    .clk(clk),
    .reset(reset),
    .input_sig(input_sig),
	.bin_coeff(16196631),
    .power(power_43),
    .advance(advance_43)
);

//piano 5
goertzel goertzel_51(
    .clk(clk),
    .reset(reset),
    .input_sig(input_sig),
	.bin_coeff(15962430),
    .power(power_51),
    .advance(advance_51)
);

//piano 8
goertzel goertzel_67(
    .clk(clk),
    .reset(reset),
    .input_sig(input_sig),
	.bin_coeff(15379322),
    .power(power_67),
    .advance(advance_67)
);

detector #(16) my_detector(
    .clk(clk),
    .reset(reset),
    .advance(advance_67),
    .power_1(power_34),
    .power_2(power_43),
    .power_3(power_51),
    .power_4(power_67),
    .result(detection_result),
    .overall_result(overall_result)
);

initial
	begin
        signal_in_file = $fopen(`SIGNAL_IN_FN,"r");
		if (!signal_in_file) begin
			$display("Couldn't open the signal file.");
			$finish;
		end
		clk <= 0;
		reset <= 1; //Reset all modules
		
		#1 //posedge
		#1 //negedge
		
		#1 //posedge
		#1 //negedge
		
		reset <= 0;

        //load the signal array
    @(posedge clk);
    for (i=0; i<`FILE_LENGTH; i=i+1)begin
		//$display("Reading...");
        ret_read <= $fscanf(signal_in_file, "%x", input_sig_32);
		input_sig <= input_sig_32[23:0];
        //$display("Input is %d", input_sig);
        @(posedge clk);

    end


    #10;


	$fclose(signal_in_file);
	$finish;

	end

    //Clock toggling
	always begin
		#1  //2-step period
		clk <= ~clk;
	end	

endmodule
