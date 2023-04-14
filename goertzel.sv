`define FFT_WIDTH 10 //2^10 = 1024 point FFT
`define FFT_MAG 1024
`define NORMALIZE 8388608 //2^23, dependent on width of incoming signal

module goertzel(

    input clk,
    input reset,
    input logic signed [23:0] input_sig,
    input logic signed [31:0] bin_coeff,
    output logic signed [63:0] power,
    output logic advance
);

//store previous output variables
logic signed [63:0] v_1;
logic signed [63:0] v_2;

logic signed [63:0] input_sig_64;
logic signed [63:0] bin_coeff_64;

//this is to ensure the first input signal gets padded before it's used in a calculation
logic padding_flag = 0;

logic [`FFT_WIDTH-1:0] signal_counter = 0;

always_ff @ (posedge clk) begin

    if (input_sig < 0)
        input_sig_64 <= {40'b1111111111111111111111111111111111111111, input_sig};
    else
        input_sig_64 <= {40'b0, input_sig};
    padding_flag <= 1;

    if (padding_flag) begin
        advance <= 0;
        v_1 <= input_sig_64 + bin_coeff_64*v_1/`NORMALIZE - v_2;
        v_2 <= v_1;

        if (signal_counter == `FFT_MAG-1) begin
            power <= v_1*v_1/`NORMALIZE + v_2*v_2/`NORMALIZE - (v_1*v_2)/(`NORMALIZE)*bin_coeff_64/`NORMALIZE;
            v_1 <= 0;
            v_2 <= 0;
            advance <=1;
        end

        signal_counter = signal_counter + 1;
    end
end

assign bin_coeff_64 = {32'b0, bin_coeff};

endmodule