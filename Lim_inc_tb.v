`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:16 AM
// Design Name:     EE3 lab1
// Module Name:     Lim_Inc_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool Versions:   Vivado 2016.4
// Description:     Limited incrementor test bench
// 
// Dependencies:    Lim_Inc
// 
// Revision:        3.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Lim_Inc_tb();

    reg [3:0] a; 
    reg ci, correct, loop_was_skipped;
    wire [3:0] sum;
    wire co;
    
    integer ai,cii;
    
    // Instantiate the UUT (Unit Under Test)
    
    localparam L = 7;
    Lim_Inc #(.N(4), .L(L)) uut (
        .a(a), 
        .ci(ci), 
        .sum(sum), 
        .co(co)
    );
    
    initial begin
        correct = 1;
        loop_was_skipped = 1;
        #1
        for (ai = 0; ai < 16; ai = ai + 1) begin
            for (cii = 0; cii <= 1; cii = cii + 1) begin
                a = ai;
                ci = cii;
                #10;
                
                if (a + ci >= L) begin
                    if (sum !== 0 || co !== 1) correct = 0;
                end else begin
                    if (sum !== a + ci || co !== 0) correct = 0;
                end
                loop_was_skipped = 0;
            end
        end
        #5
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
endmodule
