`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     Ctl
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     Control module that receives reset,trig and split inputs from the buttons
//                  outpputs the init_regs and count_enabled level signals that should govern the 
//                  operation of the Counter module.
// Dependencies:    None
//
// Revision:  	    3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl(clk, reset, trig, split, init_regs, count_enabled);

   input clk, reset, trig, split;
   output init_regs, count_enabled;
   
   //-------------Internal Constants--------------------------
   localparam SIZE = 2;
   localparam IDLE  = 2'b10, COUNTING = 2'b01, PAUSED = 2'b00 ;
   reg [SIZE-1:0] 	  state;

   //-------------Transition Function (Delta) ----------------
   always @(posedge clk)
     begin
        if (reset)
          state <= IDLE;
        else
          case (state)
            IDLE: begin
                if (trig) state <= COUNTING;
                else state <= IDLE;
            end
            COUNTING: begin
                if (trig) state <= PAUSED;
                else state <= COUNTING;
            end
            PAUSED: begin
                if (trig) state <= COUNTING;
                else if (split) state <= IDLE; // Assuming split acts as reset in PAUSED based on "001/00 -> Go to IDLE"
                else state <= PAUSED;
            end
            default: state <= IDLE;
          endcase
     end
     
   //-------------Output Function (Lambda) ----------------
	 assign init_regs     = reset || (state == IDLE && !trig);
	 assign count_enabled = !reset && ((state == COUNTING && !trig) || (state == PAUSED && trig) || (state == IDLE && trig));

endmodule
