//takes in 4 power inputs and outputs either "silence" or one of the 4 bins
`define INTERVAL 10
`define INTERVAL_WIDTH 4
`define SHIFT 8

module detector(

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
    // logic flag;

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
    
    logic advance;
	
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
        
        case(result) 
            3'b00: silence_count <= silence_count + 1;
            3'b01: pw1_count <= pw1_count + 1;
            3'b10: pw2_count <= pw2_count + 1;
            3'b11: pw3_count <= pw3_count + 1;
            3'b100: pw4_count <= pw4_count + 1;
        
        endcase
    end

    if (overall_count == `INTERVAL)begin
        if (pw1_count_greatest)
            overall_result <= 3'b01;
        else if (pw2_count_greatest)
            overall_result <= 3'b10;
        else if (pw3_count_greatest)
            overall_result <= 3'b11;
        else if (pw4_count_greatest)
            overall_result <= 3'b100;
        else if (silence_count_greatest)
            overall_result <= 3'b00;

        pw1_count <= 0;
        pw2_count <= 0;
        pw3_count <= 0;
        pw4_count <= 0;
        silence_count <= 0;
    end
        

end

    assign ratio_12 = (power_1/`SHIFT) > power_2;
    assign ratio_13 = power_1/`SHIFT > power_3;
    assign ratio_14 = power_1/`SHIFT > power_4;
    assign ratio_21 = power_2/`SHIFT > power_1;
    assign ratio_23 = power_2/`SHIFT > power_3;
    assign ratio_24 = power_2/`SHIFT > power_4;
    assign ratio_31 = power_3/`SHIFT > power_1;
    assign ratio_32 = power_3 /`SHIFT > power_2;
    assign ratio_34 = power_3 /`SHIFT > power_4;
    assign ratio_41 = power_4 /`SHIFT > power_1;
    assign ratio_42 = power_4 /`SHIFT > power_2;
    assign ratio_43 = power_4 /`SHIFT > power_3;

    assign overall_count = pw1_count + pw2_count + pw3_count + pw4_count + silence_count;
    assign pw1_count_greatest = (pw1_count >= pw2_count) && (pw1_count >= pw3_count) && (pw1_count >= pw4_count) && (pw1_count >= silence_count);
    assign pw2_count_greatest = (pw2_count >= pw1_count) && (pw2_count >= pw3_count) && (pw2_count >= pw4_count) && (pw1_count >= silence_count);
    assign pw3_count_greatest = (pw3_count >= pw1_count) && (pw3_count >= pw2_count) && (pw3_count >= pw4_count) && (pw1_count >= silence_count);
    assign pw4_count_greatest = (pw4_count >= pw1_count) && (pw4_count >= pw2_count) && (pw4_count >= pw3_count) && (pw1_count >= silence_count);
    assign silence_count_greatest = (silence_count >= pw1_count) && (silence_count >= pw2_count) && (silence_count >= pw3_count) && (silence_count >= pw4_count);
    assign advance = (advance1||advance2||advance3||advance4);

endmodule
