`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:16 AM
// Design Name:     EE3 lab1
// Module Name:     Lim_Inc
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Incrementor modulo L, where the input a is *saturated* at L 
//                  If a+ci>=L, then the output will be s=0,co=1 anyway.
// 
// Dependencies:    CSA
// 
//////////////////////////////////////////////////////////////////////////////////

module Lim_Inc(a, ci, sum, co);
    
    parameter L = 11;
    localparam N = $clog2(L);
    
    input  [N-1:0] a;
    input          ci;
    output [N-1:0] sum;
    output         co;

    // internal signals
    wire [N-1:0] raw_sum;
    wire         raw_co;
    wire [N:0]   raw_value;
    wire         saturated;

    // add a + ci using CSA (b is zero)
    CSA #(.N(N)) inc_csa (
        .a(a),
        .b({N{1'b0}}),
        .ci(ci),
        .sum(raw_sum),
        .co(raw_co)
    );

    // full value including carry
    assign raw_value = {raw_co, raw_sum};

    // saturation condition
    assign saturated = (raw_value >= L);

    // output logic
    assign sum = saturated ? {N{1'b0}} : raw_sum;
    assign co  = saturated ? 1'b1     : 1'b0;
    
endmodule
