`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/25/2016 10:21:12 PM
// Design Name:
// Module Name: Simon
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


module Simon(
    output [3:0]    an,
    output [6:0]    seg,
    output [15:0]   led,
    input  [3:0]    sw,
    input           clk,
    input           btnR,     // Right button
    input           btnL,     // Left button
    input           btnC      // Start button
    );

//--------------------- Debounce buttons -----------------------
wire        right_pressed;
wire        left_pressed;
wire        center_pressed;
reg         resetC;
reg         resetR;
reg         resetL;

//-------------------- Generate bit sequence --------------------
wire [7:0]  ran_gen;
reg  [7:0]  bit_gen;
reg         ran_enable;

// ------------------- Display bit sequence -----------------------
wire [1:0]  led_flash;
wire        flash_done;
reg         flash_enable;
reg         flash_done_reg;


//------------------- Getting and Checking input -----------------
reg         correct;

//-------------------- Display result message -----------------------
wire [3:0]  an_stat;
wire [6:0]  seg_stat;
reg         display_start;
reg         display_finish_reg;

reg  [2:0]  round;
reg  [2:0]  nround;
reg  [2:0]  count;
reg  [2:0]  ncount;
reg  [1:0]  state;
reg  [1:0]  nstate;
reg  [15:0] led_reg;

assign      led = led_reg;
assign      an  = an_stat;
assign      seg = seg_stat;

Debounce                    DR(right_pressed, clk, resetR, btnR);
Debounce                    DL(left_pressed, clk, resetL, btnL);
Debounce                    DC(center_pressed, clk, resetC, btnC);

Random_number_generator     RNG(ran_gen, clk, ran_enable, center_pressed);
Display_flash_bits          DB(led_flash, flash_done, clk, flash_enable, round, bit_gen);
Display_message             DM(an_stat, seg_stat, display_finish, clk, display_start, correct);

always @(posedge clk) begin
    if (sw[3] == 0) begin
        state           <= 2'b00;
        round           <= 3'b000;
        count           <= 3'b000;
        end
    else begin
        state           <= nstate;
        round           <= nround;
        count           <= ncount;
        end
    end

always @* begin
    nstate              = state;
    led_reg [5:4]       = led_flash;

    if (sw[0] == 1)     led_reg [15:8]  = ran_gen;
    else                led_reg [15:8]  = 0;
    if (sw[1] == 1)     led_reg [7:6]   = state;
    else                led_reg [7:6]   = 0;
    if (sw[2] == 1)     led_reg [2:0]   = round;
    else                led_reg [2:0]   = count;

    case (state)
        // Start game and generate random bit sequence
        0: begin
            nround              = 0;
            ncount              = 0;
            resetC              = 1;
            resetR              = 0;
            resetL              = 0;
            ran_enable          = 1;
            correct             = 1;
            flash_enable        = 0;
//            bit_enable          = 0;
            display_start       = 0;
            if (center_pressed == 1) begin
                bit_gen         = ran_gen;
                nstate          = 1;
                end
            else begin
                ran_enable      = 1;
                end
            end
        // Display bit sequemce
        1: begin
            nround              = round;
            ncount              = 0;
            resetC              = 0;
            resetR              = 0;
            resetL              = 0;
            ran_enable          = 0;
            flash_enable        = 1;
            display_start       = 0;
            flash_done_reg      = flash_done;
            if (flash_done_reg == 1) begin
                nstate          = 2;
                end
            else
                nstate          = 1;
            end
        // Get and Check input
        2: begin
            nround              = round;
            ncount              = count;
            resetC              = 0;
            resetR              = 1;
            resetL              = 1;
            ran_enable          = 0;
            flash_enable        = 0;
            display_start       = 0;
            correct             = 1;

            if ((right_pressed == 1 && bit_gen[count] == 0) || (left_pressed == 1 && bit_gen[count] == 1)) begin
                correct         = 0;
                nstate          = 3;
                end
            else if (right_pressed == 0 && left_pressed == 0)
                nstate          = 2;
            else if (count == round) begin
                if (round == 7) begin
                    correct     = 1;
                    nstate      = 3;
                    end
                else begin
                    nround      = round + 1;
                    nstate      = 1;
                    end
                end
            else begin
                ncount          = count + 1;
                nstate          = 2;
                end
            end
        // Display result message
        3: begin
            resetC              = 0;
            resetR              = 0;
            resetL              = 0;
            ran_enable          = 0;
            flash_enable        = 0;
            display_start       = 1;
            display_finish_reg  = display_finish;
            if (display_finish_reg == 1) begin
                nstate          = 0;
                end
            else
                nstate          = 3;
            end
        endcase
    end


endmodule
