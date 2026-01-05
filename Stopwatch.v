`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019
// Design Name:     EE3 lab1
// Module Name:     Stopwatch
// Project Name:    Electrical Lab 3, FPGA Experiment 1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     Top module for Question 9, Stopwatch with Stash and btnD sample
// Dependencies:    Debouncer, Ctl, Counter, Stash, Seg_7_Display
//////////////////////////////////////////////////////////////////////////////////

module Stopwatch(
    input              clk,
    input              btnC,
    input              btnU,
    input              btnR,
    input              btnL,
    input              btnD,
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp,
    output wire [2:0]  led_left,
    output wire [2:0]  led_right
);

    // Debounced single cycle pulses
    wire dbC, dbU, dbR, dbL, dbD;

    Debouncer debC(.clk(clk), .input_unstable(btnC), .output_stable(dbC));
    Debouncer debU(.clk(clk), .input_unstable(btnU), .output_stable(dbU));
    Debouncer debR(.clk(clk), .input_unstable(btnR), .output_stable(dbR));
    Debouncer debL(.clk(clk), .input_unstable(btnL), .output_stable(dbL));
    Debouncer debD(.clk(clk), .input_unstable(btnD), .output_stable(dbD));

    // select_mode: 0 controls stopwatch, 1 controls stash browsing
    reg select_mode;

    always @(posedge clk) begin
        if (dbC)
            select_mode <= 1'b0;
        else if (dbL)
            select_mode <= ~select_mode;
    end

    // Route btnU according to select_mode
    wire trig_to_ctl          = dbU & ~select_mode;
    wire next_sample_to_stash = dbU &  select_mode;

    // LEDs indicate selection
    assign led_left  = (select_mode == 1'b0) ? 3'b001 : 3'b000;
    assign led_right = (select_mode == 1'b1) ? 3'b001 : 3'b000;

    // Control and Counter
    wire init_regs;
    wire count_enabled;
    wire [7:0] time_reading;

    Ctl ctl_u(
        .clk(clk),
        .reset(dbC),
        .trig(trig_to_ctl),
        .split(dbR),
        .init_regs(init_regs),
        .count_enabled(count_enabled)
    );

    Counter counter_u(
        .clk(clk),
        .init_regs(init_regs),
        .count_enabled(count_enabled),
        .time_reading(time_reading)
    );

    // Split freeze display logic
    reg  [7:0] freeze_val;
    reg        freeze_valid;

    always @(posedge clk) begin
        if (dbC) begin
            freeze_val   <= 8'b0;
            freeze_valid <= 1'b0;
        end else begin
            if (!count_enabled) begin
                freeze_valid <= 1'b0;
            end else if (dbR) begin
                freeze_val   <= time_reading;
                freeze_valid <= 1'b1;
            end
        end
    end

    wire [7:0] stopwatch_display = freeze_valid ? freeze_val : time_reading;

    // Stash
    wire [7:0] sample_out;

    Stash stash_u(
        .clk(clk),
        .reset(dbC),
        .sample_in(time_reading),
        .sample_in_valid(dbD),
        .next_sample(next_sample_to_stash),
        .sample_out(sample_out)
    );

    // Display bus to 7 segment driver
    wire [15:0] x;
    assign x[15:8] = stopwatch_display;
    assign x[7:0]  = sample_out;

    Seg_7_Display seg7_u(
        .x(x),
        .clk(clk),
        .clr(dbC),
        .a_to_g(seg),
        .an(an),
        .dp(dp)
    );

endmodule
