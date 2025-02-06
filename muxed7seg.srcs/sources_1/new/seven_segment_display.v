`timescale 1ns / 1ps
module seven_segment_display (
    input  wire        clk,
    input  wire        rst,
    input wire [3:0] din1, din2, din3, din4, 
    output reg [6:0]   segments, // Seven segment outputs
    output reg [3:0]   anodes    // Anode control signals
);

    reg [3:0] digits [3:0];    // Array of digits to display
    reg [1:0] digit_select;    // Current digit select
    reg [14:0] refresh_counter; // Refresh rate counter

    // Initialize digits to display (1234 in this example)
    always @(din1 or din2 or din3 or din4) begin
        digits[0] = din1;
        digits[1] = din2;
        digits[2] = din3;
        digits[3] = din4;
    end

    // Segment decoder instance
    wire [6:0] decoded_segments;
    segment_decoder seg_dec (
        .digit(digits[digit_select]),
        .segments(decoded_segments)
    );

    // Refresh rate control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            if (refresh_counter == 25000) begin // Adjusted for 0.25 ms refresh rate
                refresh_counter <= 0;
                digit_select <= digit_select + 1;
                if (digit_select == 3)
                    digit_select <= 0;
            end
        end
    end

    // Update segments and anodes
    always @(*) begin
        segments = decoded_segments;
        anodes = 4'b1111;
        anodes[digit_select] = 1'b0; // Enable current digit's anode
    end

endmodule
