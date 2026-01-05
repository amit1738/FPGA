`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Ctl_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bench for the control.
// Dependencies:    None
//
// Revision:         3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl_tb();

    reg clk, reset, trig, split, correct, loop_was_skipped;
    wire init_regs, count_enabled;

    // Instantiate the UUT
    Ctl uut (
        .clk(clk),
        .reset(reset),
        .trig(trig),
        .split(split),
        .init_regs(init_regs),
        .count_enabled(count_enabled)
    );

    // Expected state encoding for TB model
    localparam IDLE     = 2'd2;
    localparam COUNTING = 2'd1;
    localparam PAUSED   = 2'd0;

    reg [1:0] exp_state;

    // Expected outputs (Mealy)
    // exp_out[1] = init_regs
    // exp_out[0] = count_enabled
    function [1:0] exp_out;
        input [1:0] st;
        input r, t, s;
        begin
            if (r) begin
                exp_out = 2'b10;
            end
            else begin
                case (st)
                    IDLE: begin
                        if (t) exp_out = 2'b01;
                        else    exp_out = 2'b10;
                    end

                    COUNTING: begin
                        if (t)
                            exp_out = 2'b00;
                        else
                            exp_out = 2'b01;
                    end

                    PAUSED: begin
                        if (t)
                            exp_out = 2'b01;
                        else
                            exp_out = 2'b00;
                    end

                    default: begin
                        exp_out = 2'bxx;
                    end
                endcase
            end
        end
    endfunction

    // Expected next state (updated on posedge clk)
    function [1:0] exp_next_state;
        input [1:0] st;
        input r, t, s;
        begin
            case (st)
                IDLE: begin
                    if (r)
                        exp_next_state = IDLE;
                    else if (t)
                        exp_next_state = COUNTING;
                    else
                        exp_next_state = IDLE;
                end

                COUNTING: begin
                    if (r)
                        exp_next_state = IDLE;
                    else if (t)
                        exp_next_state = PAUSED;
                    else
                        exp_next_state = COUNTING;
                end

                PAUSED: begin
                    if (r)
                        exp_next_state = IDLE;
                    else if (t)
                        exp_next_state = COUNTING;
                    else if (s)
                        exp_next_state = IDLE;
                    else
                        exp_next_state = PAUSED;
                end

                default: begin
                    exp_next_state = IDLE;
                end
            endcase
        end
    endfunction

    // Apply inputs, check outputs, then update expected state
    task apply_and_check;
        input r, t, s;
        reg [1:0] eo;
        begin
            @(negedge clk);
            reset = r;
            trig  = t;
            split = s;

            #1;
            eo = exp_out(exp_state, reset, trig, split);

            correct = correct &
                      (init_regs == eo[1]) &
                      (count_enabled == eo[0]);

            @(posedge clk);
            exp_state = exp_next_state(exp_state, reset, trig, split);
        end
    endtask

    initial begin
        correct = 1;
        loop_was_skipped = 0;

        clk   = 0;
        reset = 1;
        trig  = 0;
        split = 0;

        // TB model starts in IDLE
        exp_state = IDLE;

        #10;
        reset = 0;

        #1;
        correct = correct & init_regs & ~count_enabled;

        #20;

        $display("Starting Directed Tests...");

        // 1. IDLE State Tests
        // IDLE self loop (reset=0, trig=0)
        apply_and_check(0, 0, 0);
        // IDLE self loop via Reset (reset=1)
        apply_and_check(1, 0, 0);

        // 2. IDLE -> COUNTING
        apply_and_check(0, 1, 0);

        // 3. COUNTING State Tests
        // COUNTING self loop (reset=0, trig=0)
        apply_and_check(0, 0, 0);
        
        // Check being in COUNTING and get rise of trig
        // This should transition to PAUSED and disable counting
        apply_and_check(0, 1, 0);
        
        // COUNTING -> IDLE via Reset
        apply_and_check(1, 0, 0);

        // Return to COUNTING
        apply_and_check(0, 1, 0);

        // 4. COUNTING -> PAUSED
        apply_and_check(0, 1, 0);

        // 5. PAUSED State Tests
        // PAUSED self loop (reset=0, trig=0, split=0)
        apply_and_check(0, 0, 0);

        // PAUSED -> COUNTING
        apply_and_check(0, 1, 0);

        // Return to PAUSED
        apply_and_check(0, 1, 0);

        // PAUSED -> IDLE via Split
        apply_and_check(0, 0, 1);

        // 6. PAUSED -> IDLE via Reset
        // Get back to PAUSED first
        apply_and_check(0, 1, 0); // IDLE -> COUNTING
        apply_and_check(0, 1, 0); // COUNTING -> PAUSED
        // Now test Reset from PAUSED
        apply_and_check(1, 0, 0);

        #10;

        if (correct)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");

        $finish;
    end

    always #5 clk = ~clk;

endmodule
