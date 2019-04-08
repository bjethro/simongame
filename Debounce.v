`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/25/2016 01:57:43 PM
// Design Name:
// Module Name: Debounce
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

//wire PB_idle = (PB_state==PB_sync_1);
//wire PB_cnt_max = &PB_cnt;
module Debounce(
    output level_out,
    input clk,
    input n_reset,
    input button_in
    );
reg DB_out;

    /*
    Parameter N defines the debounce time. Assuming 50 KHz clock,
    the debounce time is 2^(11-1)/ 50 KHz = 20 ms

    For 50 MHz clock increase value of N accordingly to 21.

    */
   /*
   Parameter N defines the debounce time. Assuming 50 KHz clock,
   the debounce time is 2^(11-1)/ 50 KHz = 20 ms

   For 50 MHz clock increase value of N accordingly to 21.

   */
   parameter N = 11 ;

   reg  [N-1 : 0]  delaycount_reg;
   reg  [N-1 : 0]  delaycount_next;

   reg DFF1, DFF2;
   wire q_add;
   wire q_reset;


reg  delay_reg ; // Registers for detecting level change of DB_out

       always @ ( posedge clk or negedge n_reset )
       begin
           if(n_reset ==  0) // At reset initialize FF and counter
               begin
                   DFF1 <= 1'b0;
                   DFF2 <= 1'b0;
                   // For level change detection
                   delay_reg  <=  1'b0;

                   delaycount_reg <= { N {1'b0} };
               end
           else
               begin
                   DFF1 <= button_in;
                   DFF2 <= DFF1;
                   delaycount_reg <= delaycount_next;



                   delay_reg  <=  DB_out;// to detect level change
               end
       end


   assign q_reset = (DFF1  ^ DFF2); // Ex OR button_in on conecutive clocks
                                    // to detect level change

   assign  q_add = ~(delaycount_reg[N-1]); // Check count using MSB of counter


   always @ ( q_reset, q_add, delaycount_reg)
       begin
           case( {q_reset , q_add})
               2'b00 :
                       delaycount_next <= delaycount_reg;
               2'b01 :
                       delaycount_next <= delaycount_reg + 1;
               default :
               // In this case q_reset = 1 => change in level. Reset the counter
                       delaycount_next <= { N {1'b0} };
           endcase
       end


   always @ ( posedge clk )
       begin
           if(delaycount_reg[N-1] == 1'b1)
                   DB_out <= DFF2;
           else
                   DB_out <= DB_out;
       end


   assign  level_out  =  (delay_reg)  &  (~DB_out);

endmodule
