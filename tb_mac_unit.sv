`timescale 1ns/1ps

module tb_mac_unit;

    localparam DATA_WIDTH  = 8;
    localparam ACCUM_WIDTH = 21;
    localparam CLK_PERIOD  = 10;

    // DUT I/O
    logic clk;
    logic rst_n;
    logic signed [DATA_WIDTH-1:0]  a_in;
    logic signed [DATA_WIDTH-1:0]  b_in;
    logic valid;
    logic clear;
    logic signed [DATA_WIDTH-1:0]  a_out;
    logic signed [DATA_WIDTH-1:0]  b_out;
    logic signed [ACCUM_WIDTH-1:0] accum_out;

    // Reference (golden) model state — same widths as DUT so overflow/wraparound
    // behaves identically to the hardware
    logic signed [DATA_WIDTH-1:0]  exp_a;
    logic signed [DATA_WIDTH-1:0]  exp_b;
    logic signed [ACCUM_WIDTH-1:0] exp_accum;

    integer errors;
    integer tests;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    mac_unit #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ACCUM_WIDTH (ACCUM_WIDTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .a_in      (a_in),
        .b_in      (b_in),
        .valid     (valid),
        .clear     (clear),
        .a_out     (a_out),
        .b_out     (b_out),
        .accum_out (accum_out)
    );

    // ---------------------------------------------------------
    // Clock generation
    // ---------------------------------------------------------
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---------------------------------------------------------
    // Async reset task
    // ---------------------------------------------------------
    task automatic do_reset();
        begin
            rst_n = 0;
            a_in  = '0;
            b_in  = '0;
            valid = 0;
            clear = 0;
            exp_a     = '0;
            exp_b     = '0;
            exp_accum = '0;
            @(negedge clk);
            @(negedge clk);
            rst_n = 1;
            @(negedge clk);
        end
    endtask

    // ---------------------------------------------------------
    // Drive one cycle of stimulus and self-check against the
    // golden model, mirroring the DUT's priority:
    //   !rst_n > clear > valid > hold
    // ---------------------------------------------------------
    task automatic drive_and_check(
        input logic signed [DATA_WIDTH-1:0] a,
        input logic signed [DATA_WIDTH-1:0] b,
        input logic v,
        input logic c,
        input string label
    );
        begin
            // Apply stimulus right after a clock edge, well before the next one
            a_in  = a;
            b_in  = b;
            valid = v;
            clear = c;

            // Predict next state exactly like the DUT's synchronous logic
            if (c) begin
                exp_a     = '0;
                exp_b     = '0;
                exp_accum = '0;
            end
            else if (v) begin
                exp_a     = a;
                exp_b     = b;
                exp_accum = exp_accum + ACCUM_WIDTH'(a * b);
            end
            // else: hold (no change to exp_* )

            @(posedge clk);
            #1; // let non-blocking assignments settle

            tests = tests + 1;
            if (a_out !== exp_a || b_out !== exp_b || accum_out !== exp_accum) begin
                errors = errors + 1;
                $display("FAIL [%s]: a=%0d b=%0d valid=%0b clear=%0b -> a_out=%0d(exp %0d) b_out=%0d(exp %0d) accum=%0d(exp %0d)",
                          label, a, b, v, c,
                          a_out, exp_a, b_out, exp_b, accum_out, exp_accum);
            end
        end
    endtask

    // ---------------------------------------------------------
    // Stimulus
    // ---------------------------------------------------------
    integer i;
    reg signed [DATA_WIDTH-1:0] rand_a, rand_b;

    initial begin
        errors = 0;
        tests  = 0;

        $display("---------------------------------------------------");
        $display(" Reset check");
        $display("---------------------------------------------------");
        do_reset();
        tests = tests + 1;
        if (a_out !== 0 || b_out !== 0 || accum_out !== 0) begin
            errors = errors + 1;
            $display("FAIL [reset]: outputs not zero after reset");
        end

        $display("---------------------------------------------------");
        $display(" Directed tests: single MAC ops");
        $display("---------------------------------------------------");
        drive_and_check(5, 3, 1, 0, "single_pos");
        drive_and_check(-5, 3, 1, 0, "single_neg");
        drive_and_check(0, 0, 1, 0, "zero_op");

        $display("---------------------------------------------------");
        $display(" Directed tests: valid=0 should hold state");
        $display("---------------------------------------------------");
        drive_and_check(100, 100, 0, 0, "hold_ignored_inputs");
        drive_and_check(-7, 9, 0, 0, "hold_ignored_inputs2");

        $display("---------------------------------------------------");
        $display(" Directed tests: accumulation over multiple cycles");
        $display("---------------------------------------------------");
        do_reset();
        drive_and_check(10, 10, 1, 0, "accum1");   // +100
        drive_and_check(-10, 10, 1, 0, "accum2");  // -100 -> back to 0
        drive_and_check(20, 5, 1, 0, "accum3");    // +100
        drive_and_check(3, 3, 1, 0, "accum4");     // +9 -> 109

        $display("---------------------------------------------------");
        $display(" Directed tests: clear behavior (mid-accumulation)");
        $display("---------------------------------------------------");
        drive_and_check(0, 0, 0, 1, "clear_mid_accum");
        tests = tests + 1;
        if (accum_out !== 0) begin
            errors = errors + 1;
            $display("FAIL [clear_mid_accum]: accum_out=%0d expected 0", accum_out);
        end
        drive_and_check(4, 4, 1, 0, "accum_after_clear"); // +16

        $display("---------------------------------------------------");
        $display(" Directed tests: clear takes priority over valid same cycle");
        $display("---------------------------------------------------");
        drive_and_check(50, 50, 1, 1, "clear_and_valid_same_cycle");

        $display("---------------------------------------------------");
        $display(" Directed tests: extreme values (max positive / negative)");
        $display("---------------------------------------------------");
        do_reset();
        drive_and_check(127, 127, 1, 0, "max_pos_sq");     // +16129
        drive_and_check(-128, -128, 1, 0, "max_neg_sq");   // +16384
        drive_and_check(-128, 127, 1, 0, "min_max_prod");  // -16256
        drive_and_check(127, -128, 1, 0, "max_min_prod");  // -16256

        $display("---------------------------------------------------");
        $display(" Directed test: async reset mid-accumulation");
        $display("---------------------------------------------------");
        drive_and_check(10, 10, 1, 0, "pre_reset_accum");
        // apply async reset directly, not through do_reset(), to hit it mid-cycle
        rst_n = 0;
        exp_a = '0; exp_b = '0; exp_accum = '0;
        #(CLK_PERIOD);
        tests = tests + 1;
        if (a_out !== 0 || b_out !== 0 || accum_out !== 0) begin
            errors = errors + 1;
            $display("FAIL [async_reset]: outputs not zero after async reset");
        end
        rst_n = 1;
        @(negedge clk);

        $display("---------------------------------------------------");
        $display(" Overflow / wraparound test (accumulator saturates its width)");
        $display("---------------------------------------------------");
        do_reset();
        // ACCUM_WIDTH=21 -> max positive = 2^20 - 1 = 1048575
        // Repeatedly add 127*127=16129 until it wraps past the positive limit
        for (i = 0; i < 70; i = i + 1) begin
            drive_and_check(127, 127, 1, 0, $sformatf("overflow_%0d", i));
        end

        $display("---------------------------------------------------");
        $display(" Randomized tests: mixed valid/clear/hold sequences");
        $display("---------------------------------------------------");
        do_reset();
        for (i = 0; i < 3000; i = i + 1) begin
            rand_a = $random;
            rand_b = $random;
            drive_and_check(rand_a, rand_b,
                             ($random % 10) != 0,   // valid ~90% of the time
                             ($random % 25) == 0,   // occasional clear
                             $sformatf("rand_%0d", i));
        end

        $display("=====================================================");
        if (errors == 0)
            $display(" ALL %0d TESTS PASSED", tests);
        else
            $display(" %0d / %0d TESTS FAILED", errors, tests);
        $display("=====================================================");

        $finish;
    end

endmodule