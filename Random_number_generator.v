`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2016 05:06:49 PM
// Design Name: 
// Module Name: Random_number_generator
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

module Random_number_generator(
    output [7:0]    bit_gen_sequence,
    input           clock,
    input           enable,   // Enable number output
    input           start     // Start the game by generating random 8-bit sequence
    );
    
reg [7:0] ran_bits;
reg [7:0] bit_gen_reg;
    
always @(posedge clock) begin
    if(ran_bits == 8'hff) 
        ran_bits    <= 0;
    else 
        ran_bits    <= ran_bits + 1;
    if((start == 0) && (enable == 1)) 
        bit_gen_reg <= ran_bits;  // 0 if start is pressed
    end
    
assign bit_gen_sequence = bit_gen_reg;

endmodule
