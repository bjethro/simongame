`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/26/2016 01:28:29 AM
// Design Name:
// Module Name: Display_flash_bits
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

//module Display_input_bit(
//    output [3:0] led_input_flash,
//    input clock,
//    input button_pressed
//    );

//reg [3:0] led_input_reg;


/////////////////////////////////////////////////////////////////////////////////
module Display_flash_bits(
    output [1:0]    led_flash,
    output          display_done,
    input           clock,
    input           enable,
    input  [2:0]    bit_count,
    input  [7:0]    bit_gen
    );

reg [3:0]   i;
reg [26:0]  j;
reg [1:0]   led_stat;
reg         done;

assign led_flash    = led_stat;
assign display_done = done;

initial begin
    i <= 0;
    j <= 0;
    end

always @(posedge clock) begin
    if(enable == 1) begin
        if(i > bit_count) begin
            done        <= 1;
            led_stat    <= 2'b00;
            i           <= i;
            end
        else begin
            if (j < 27'o777777777) begin
                j       <= j + 1;
                if(j[26] == 1) begin
                    if(bit_gen[i] == 1)
                        led_stat    <= 2'b01;  // left off and right on
                    else if(bit_gen[i] == 0)
                        led_stat    <= 2'b10;   // left on and right off
                    end
                else
                    led_stat        <= 2'b00;
                end
            else if(j >= 27'o777777777) begin
                i       <= i + 1;
                j       <= 0;
                end
            done    <= 0;
            end
        end
    else if (enable == 0) begin
        led_stat    <= 2'b00;
        i           <= 0;
        done        <= 0;
        end
    end

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Display_message(
    output [3:0]    an_stat,
    output [6:0]    seg_stat,
    output          display_finish,  // Finish displaying message
    input           clock,
    input           start,          // Start displaying message
    input           result          // result of input : win or lose
    );

reg [27:0]  i;   // Time counter
reg [3:0]   an_reg;
reg [6:0]   seg_reg;
reg         finish;

assign an_stat          = an_reg;
assign seg_stat         = seg_reg;
assign display_finish   = finish;

initial begin
    i <= 0;
    end

always @(posedge clock) begin
    if(start == 0) begin
        an_reg  <= 4'b1111;
        seg_reg <= 7'b1111111;
        i       <= 0;
        finish  <= 0;
        end
    else if(start == 1) begin
        if(i < 28'hfffffff) begin
            case(i[16:15])
                2'b00:  begin
                    an_reg          <= 4'b0111;
                    if(result == 0)    //result: win = 1, lose = 0
                        seg_reg     <= 7'b1000111;
                    else
                        seg_reg     <= 7'b0011001;
                    end
                2'b01:  begin
                    an_reg          <= 4'b1011;
                    if(result == 0)
                        seg_reg     <= 7'b1000000;
                    else
                        seg_reg     <= 7'b0000110;
                    end
                2'b10:  begin
                    an_reg          <= 4'b1101;
                    if(result == 0)
                        seg_reg     <= 7'b0010010;
                    else
                        seg_reg     <= 7'b0001000;
                    end
                2'b11:  begin
                    an_reg          <= 4'b1110;
                    if(result == 0)
                        seg_reg     <= 7'b0000110;
                    else
                        seg_reg     <= 7'b0001001;
                    end
                default:begin
                    an_reg          <= 4'b1111;
                    seg_reg         <= 7'b1111111;
                    end
                endcase
            i       <= i + 1;
            finish  <= 0;
            end
        else begin
            an_reg  <= 4'b1111;
            seg_reg <= 7'b1111111;
            finish  <= 1;
            i       <= i;
            end
        end
    end

 endmodule
