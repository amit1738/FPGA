`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Stash_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the stash.
// Dependencies:    None
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash_tb();

    reg clk, reset, sample_in_valid, next_sample, correct, loop_was_skipped;
    reg [7:0] sample_in;
    wire [7:0] sample_out;
    integer ini;
    
    // Instantiate the UUT (Unit Under Test)
    Stash #(.DEPTH(5)) uut (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_in),
        .sample_in_valid(sample_in_valid),
        .next_sample(next_sample),
        .sample_out(sample_out)
    );
    
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        loop_was_skipped = 1;
        sample_in_valid = 0;
        next_sample = 0;
        sample_in = 0;
        
        #6
        reset = 0;
        
        // Write 7 samples: 0, 1, 2, 3, 4, 5, 6
        for( ini=0; ini<7; ini=ini+1 ) begin
            sample_in = ini;
            sample_in_valid = 1;
            #10
            // Check if sample_out immediately reflects the new sample (Jump feature)
            correct = correct & (sample_out == ini);
            loop_was_skipped = 0;
        end
        
        sample_in_valid = 0;
        
        // Verify Circular Buffer Content
        // Expected state after writing 0..6 into DEPTH=5:
        // The buffer should contain: [5, 6, 2, 3, 4] (assuming overwrite of 0 and 1)
        // Current pointer should be at 6.
        
        // 1. Current sample should be 6
        if (sample_out !== 6) correct = 0;
        
        // 2. Next -> Should be 2
        next_sample = 1; #10; next_sample = 0; #10;
        if (sample_out !== 2) correct = 0;
        
        // 3. Next -> Should be 3
        next_sample = 1; #10; next_sample = 0; #10;
        if (sample_out !== 3) correct = 0;
        
        // 4. Next -> Should be 4
        next_sample = 1; #10; next_sample = 0; #10;
        if (sample_out !== 4) correct = 0;
        
        // 5. Next -> Should be 5
        next_sample = 1; #10; next_sample = 0; #10;
        if (sample_out !== 5) correct = 0;
        
        // 6. Next -> Should be 6 again
        next_sample = 1; #10; next_sample = 0; #10;
        if (sample_out !== 6) correct = 0;

        #5
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
    always #5 clk = ~clk;
endmodule
