`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Counter
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a counter that advances its reading as long as time_reading 
//                  signal is high and zeroes its reading upon init_regs=1 input.
//                  the time_reading output represents: 
//                  {dekaseconds,seconds}
// Dependencies:    Lim_Inc
//
// Revision         3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Counter(clk, init_regs, count_enabled, time_reading);

   parameter CLK_FREQ = 100000000;// in Hz
   
   input clk, init_regs, count_enabled;
   output [7:0] time_reading;

   reg [$clog2(CLK_FREQ)-1:0] clk_cnt;
   reg [3:0] ones_seconds;    
   reg [3:0] tens_seconds;      
   
   wire [$clog2(CLK_FREQ)-1:0] next_clk_cnt;
   wire [3:0] next_ones, next_tens;
   wire co_ones, co_tens;
   wire tick;

   // Clock Divider (0 to CLK_FREQ-1)
   Lim_Inc #(.N($clog2(CLK_FREQ)), .L(CLK_FREQ)) clk_divider_inst (
       .a(clk_cnt),
       .ci(count_enabled),
       .sum(next_clk_cnt),
       .co(tick)
   );

   // Ones Counter (0-9)
   Lim_Inc #(.L(10)) counter_ones_inst (
       .a(ones_seconds),
       .ci(tick),
       .sum(next_ones),
       .co(co_ones)
   );

   // Tens Counter (0-9)
   Lim_Inc #(.L(10)) counter_tens_inst (
       .a(tens_seconds),
       .ci(co_ones),
       .sum(next_tens),
       .co(co_tens)
   );
   
   assign time_reading = {tens_seconds, ones_seconds};
   
   //------------- Synchronous ----------------
   always @(posedge clk)
     begin
        if (init_regs) begin
            clk_cnt <= 0;
            ones_seconds <= 0;
            tens_seconds <= 0;
        end else if (count_enabled) begin
            clk_cnt <= next_clk_cnt;
            ones_seconds <= next_ones;
            tens_seconds <= next_tens;
        end
     end

endmodule
