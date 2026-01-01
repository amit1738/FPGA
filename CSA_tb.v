module CSA_tb();

    parameter N = 3;

    reg  [N-1:0] a, b;
    reg          ci;
    reg          correct, loop_was_skipped;

    wire [N-1:0] sum;
    wire         co;

    integer ai, bi, cii;

    // Instantiate the UUT (Unit Under Test)
    CSA #(.N(N)) uut (a, b, ci, sum, co);

    initial begin
        correct = 1;
        loop_was_skipped = 1;
        #1
        for (ai = 0; ai < (1<<N); ai = ai + 1) begin
            for (bi = 0; bi < (1<<N); bi = bi + 1) begin
                for (cii = 0; cii <= 1; cii = cii + 1) begin
                    a  = ai[N-1:0];
                    b  = bi[N-1:0];
                    ci = cii[0];

                    #5 correct = correct & ((ai + bi + cii) == {co, sum});
                    loop_was_skipped = 0;
                end
            end
        end

        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end

endmodule
