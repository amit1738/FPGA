`timescale 1ns/1ps

module Debouncer_tb;

   reg clk;
   reg input_unstable;
   wire output_stable;

   // Instantiate the DUT
   Debouncer #(.COUNTER_BITS(4)) dut (
      .clk(clk),
      .input_unstable(input_unstable),
      .output_stable(output_stable)
   );

   // Clock generation: 10ns period
   initial clk = 0;
   always #5 clk = ~clk;

   initial begin
      // Initial state
      input_unstable = 0;
      #40;

      // Bouncing press (should NOT trigger output)
      input_unstable = 1; #10;
      input_unstable = 0; #10;
      input_unstable = 1; #10;
      input_unstable = 0; #10;
      input_unstable = 1; #10;
      input_unstable = 0; #40;

      // Stable press (SHOULD trigger exactly one pulse)
      input_unstable = 1;
      #200;

      // Keep holding (should NOT trigger again)
      input_unstable = 1;
      #200;

      // Release (no pulse)
      input_unstable = 0;
      #200;

      // Second stable press (SHOULD trigger again)
      input_unstable = 1;
      #200;

      $finish;
   end

endmodule
