`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2016 01:57:43 PM
// Design Name: 
// Module Name: Timer_check
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
module Timer_check(
    output times_up,
    input clock,
    input start     // Start timer
    );
    
reg [31:0] i;
reg times_up_reg;

initial i <= 0;

assign times_up = times_up_reg;
    
always @(posedge clock) begin
    if(start == 1) begin
        if(i < 32'hffffffff) begin 
            i <= i + 1;
            times_up_reg <= 1;      // 1 = not times up
            end
        else begin
            times_up_reg <= 0;
            end
        end
    else if(start == 0) begin
        times_up_reg <= 1;
        i <= 0;
        end
    end  
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////
module Timer_delay(
    output times_up,
    input clock,
    input start     // Start timer
    );
    
reg [19:0] i;
reg times_up_reg;

initial i <= 0;

assign times_up = times_up_reg;
    
always @(posedge clock) begin
    if(start == 1) begin
        if(i < 20'hfffff) begin 
            i <= i + 1;
            times_up_reg <= 1;      // 1 = not times up
            end
        else begin
            times_up_reg <= 0;
            end
        end
    else if(start == 0) begin
        times_up_reg <= 1;
        i <= 0;
        end
    end  
endmodule