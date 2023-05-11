/*
 * Detects which of the powers recieved from the Goertzel modules is the strongest and sends that result
 * Uses a moving window to sample the results and returns a value if the result is the same for a specified number of times in the window
 * Sienna Brent, Rajat Tyagi, Alex Yu
 * Columbia University
 */

//takes in 4 power inputs and outputs either "silence" or one of the 4 bins
`define INTERVAL 15
`define INTERVAL_WIDTH 5
`define SHIFT 8 //how much greater the signal we're looking for has to be than the other signals

`define GREATER_THAN 8

module detector #(
    parameter ARR_WIDTH=16
)
(
input clk,
input reset,
input advance1, advance2, advance3, advance4,
input logic signed [63:0] power_1,
input logic signed [63:0] power_2,
input logic signed [63:0] power_3,
input logic signed [63:0] power_4,
output logic [2:0] result, //00 for silence, 1-4 for powers 1-4 respectively
output logic [2:0] overall_result,
output logic flag
);
    logic advance;

    logic ratio_12;
    logic ratio_13;
    logic ratio_14;
    logic ratio_21;
    logic ratio_23;
    logic ratio_24;
    logic ratio_31;
    logic ratio_32;
    logic ratio_34;
    logic ratio_41;
    logic ratio_42;
    logic ratio_43;
    logic [2:0] last_bin = 3'b111;

    logic [`INTERVAL_WIDTH-1:0] pw1_count = 0;
    logic [`INTERVAL_WIDTH-1:0] pw2_count = 0;
    logic [`INTERVAL_WIDTH-1:0] pw3_count = 0;
    logic [`INTERVAL_WIDTH-1:0] pw4_count = 0;
    logic [`INTERVAL_WIDTH-1:0] silence_count = 0;

    logic [`INTERVAL_WIDTH-1:0] overall_count;

    logic pw1_count_greatest;
    logic pw2_count_greatest;
    logic pw3_count_greatest;
    logic pw4_count_greatest;
    logic silence_count_greatest;

    logic [2:0] result_array [ARR_WIDTH-1 : 0];
    
	
    
always @(posedge clk) begin

    flag <= advance;
    
    if(ratio_12 && ratio_13 && ratio_14)begin
        result <= 3'b01;
    end
    else if(ratio_21 && ratio_23 && ratio_24)begin
        result <= 3'b10;
    end
    else if(ratio_31 && ratio_32 && ratio_34)begin
        result <= 3'b11;
    end
    else if(ratio_41 && ratio_42 && ratio_43)begin
        result <= 3'b100;
    end
    else begin
        result <= 3'b00;
    end

    if(flag)begin

        result_array[0] <= result;
        for (int i = 1; i < ARR_WIDTH; i++) begin
            result_array[i] <= result_array[i-1]; 
        end
        if(result_array[ARR_WIDTH-1]) begin
            if (pw1_count >= `GREATER_THAN)
                overall_result <= 3'b01;
            else if (pw2_count >= `GREATER_THAN)
                overall_result <= 3'b10;
            else if (pw3_count >= `GREATER_THAN)
                overall_result <= 3'b11;
            else if (pw4_count >= `GREATER_THAN)
                overall_result <= 3'b100;
            else
                overall_result <= 3'b00;
        end

        if(result_array[ARR_WIDTH-1] != result) begin

            case(result) 
                3'b00:  silence_count <= silence_count + 1;
                3'b01:  pw1_count <= pw1_count + 1;
                3'b10:  pw2_count <= pw2_count + 1;
                3'b11:  pw3_count <= pw3_count + 1;
                3'b100: pw4_count <= pw4_count + 1;        
            endcase

            case(result_array[ARR_WIDTH-1]) 
                3'b00:  silence_count <= silence_count - 1;
                3'b01:  pw1_count <= pw1_count - 1;
                3'b10:  pw2_count <= pw2_count - 1;
                3'b11:  pw3_count <= pw3_count - 1;
                3'b100: pw4_count <= pw4_count - 1;
            endcase

        end

    end
        

end

    assign ratio_12 = power_1/(`SHIFT) > power_2;
    assign ratio_13 = power_1/(`SHIFT) > power_3;
    assign ratio_14 = power_1/(`SHIFT) > power_4;
    assign ratio_21 = power_2/`SHIFT > power_1;
    assign ratio_23 = power_2/`SHIFT > power_3;
    assign ratio_24 = power_2/`SHIFT > power_4;
    assign ratio_31 = power_3/(`SHIFT>>1) > power_1;
    assign ratio_32 = power_3/(`SHIFT>>1) > power_2;
    assign ratio_34 = power_3/(`SHIFT>>1) > power_4;
    assign ratio_41 = power_4/`SHIFT > power_1;
    assign ratio_42 = power_4/`SHIFT > power_2;
    assign ratio_43 = power_4/`SHIFT > power_3;

    assign overall_count = pw1_count + pw2_count + pw3_count + pw4_count + silence_count;

    assign advance = (advance1||advance2||advance3||advance4);
endmodule
