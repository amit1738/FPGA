`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Stash
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a Stash that stores samples upon sample_in_valid.
//                  sample_out shows selected stored sample, but shows sample_in immediately when sampling.
// Dependencies:    Lim_Inc
//////////////////////////////////////////////////////////////////////////////////

module Stash(clk, reset, sample_in, sample_in_valid, next_sample, sample_out);

   parameter DEPTH = 5;

   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;

   reg [7:0] mem [0:DEPTH-1];

   localparam PTR_W = (DEPTH <= 2) ? 1 : $clog2(DEPTH);

   reg  [PTR_W-1:0] wr_ptr;
   reg  [PTR_W-1:0] rd_ptr;

   wire [PTR_W-1:0] wr_ptr_next;
   wire [PTR_W-1:0] rd_ptr_next;
   wire wr_co;
   wire rd_co;

   Lim_Inc #(.L(DEPTH)) inc_wr (
      .a(wr_ptr),
      .ci(1'b1),
      .sum(wr_ptr_next),
      .co(wr_co)
   );

   Lim_Inc #(.L(DEPTH)) inc_rd (
      .a(rd_ptr),
      .ci(1'b1),
      .sum(rd_ptr_next),
      .co(rd_co)
   );

   assign sample_out = (sample_in_valid) ? sample_in : mem[rd_ptr];

   integer i;

   always @(posedge clk) begin
      if (reset) begin
         wr_ptr <= {PTR_W{1'b0}};
         rd_ptr <= {PTR_W{1'b0}};
         for (i = 0; i < DEPTH; i = i + 1)
            mem[i] <= 8'h00;
      end else begin
         if (sample_in_valid) begin
            mem[wr_ptr] <= sample_in;
            wr_ptr <= wr_ptr_next;
            rd_ptr <= wr_ptr;
         end else if (next_sample) begin
            rd_ptr <= rd_ptr_next;
         end
      end
   end

endmodule
