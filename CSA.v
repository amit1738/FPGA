`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     11/10/2018 08:59:38 PM
// Design Name:     EE3 lab1
// Module Name:     CSA
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Variable length binary adder. The parameter N determines
//                  the bit width of the operands. Implemented according to 
//                  Conditional Sum Adder.
// 
// Dependencies:    FA
// 
// Revision:        2.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CSA(a, b, ci, sum, co);

    parameter N=4;
    parameter K = N >> 1;
    
    input [N-1:0] a;
    input [N-1:0] b;
    input ci;
    output [N-1:0] sum;
    output co;
    
	
    generate
        if (N == 1) begin : base_case
            FA fa_inst (
                .a(a[0]), 
                .b(b[0]), 
                .ci(ci), 
                .sum(sum[0]), 
                .co(co)
            );
        end else begin : recursive_step
            wire [K-1:0] sum_lower;
            wire co_lower;
            
            wire [N-1:K] sum_upper_0, sum_upper_1;
            wire co_upper_0, co_upper_1;
            
            // Lower half
            CSA #(K) csa_lower (
                .a(a[K-1:0]), 
                .b(b[K-1:0]), 
                .ci(ci), 
                .sum(sum_lower), 
                .co(co_lower)
            );
            
            // Upper half with cin=0
            CSA #(N-K) csa_upper_0 (
                .a(a[N-1:K]), 
                .b(b[N-1:K]), 
                .ci(1'b0), 
                .sum(sum_upper_0), 
                .co(co_upper_0)
            );
            
            // Upper half with cin=1
            CSA #(N-K) csa_upper_1 (
                .a(a[N-1:K]), 
                .b(b[N-1:K]), 
                .ci(1'b1), 
                .sum(sum_upper_1), 
                .co(co_upper_1)
            );
            
            // Muxing
            assign sum[K-1:0] = sum_lower;
            assign sum[N-1:K] = (co_lower) ? sum_upper_1 : sum_upper_0;
            assign co = (co_lower) ? co_upper_1 : co_upper_0;
        end
    endgenerate

    
endmodule
