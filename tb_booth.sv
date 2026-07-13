`timescale 1ns/1ps

module tb_booth_multiplier;

    localparam DATA_WIDTH = 8;

    logic signed [DATA_WIDTH-1:0]     multiplicand;
    logic signed [DATA_WIDTH-1:0]     multiplier;
    logic signed [(2*DATA_WIDTH)-1:0] product;

    integer errors;
    integer tests;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    booth_multiplier #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .multiplicand (multiplicand),
        .multiplier   (multiplier),
        .product      (product)
    );

    // ---------------------------------------------------------
    // Reference check task
    // ---------------------------------------------------------
    task automatic check(input signed [DATA_WIDTH-1:0] a,
                          input signed [DATA_WIDTH-1:0] b);
        logic signed [(2*DATA_WIDTH)-1:0] expected;
        begin
            multiplicand = a;
            multiplier   = b;
            #1; // settle combinational logic
            expected = a * b;
            tests = tests + 1;
            if (product !== expected) begin
                errors = errors + 1;
                $display("FAIL: %0d * %0d = %0d (DUT) vs %0d (expected)",
                          a, b, product, expected);
            end
        end
    endtask

    integer i;
    reg signed [DATA_WIDTH-1:0] rand_a, rand_b;

    initial begin
        errors = 0;
        tests  = 0;

        $display("---------------------------------------------------");
        $display(" Directed edge-case tests (DATA_WIDTH = %0d)", DATA_WIDTH);
        $display("---------------------------------------------------");

        // Basic sanity
        check(0, 0);
        check(1, 1);
        check(1, -1);
        check(-1, -1);
        check(5, 3);
        check(-5, 3);
        check(5, -3);
        check(-5, -3);

        // Powers of two / shift-heavy cases (stress Booth +2M/-2M paths)
        check(2, 2);
        check(-2, 2);
        check(2, -2);
        check(-2, -2);
        check(4, 4);
        check(-4, 4);

        // Extreme values for signed 8-bit range [-128, 127]
        check(127, 127);     // max positive * max positive
        check(-128, -128);   // min negative * min negative -> largest positive product
        check(-128, 127);    // min * max -> most negative product
        check(127, -128);    // same, operands swapped
        check(-128, 1);      // min * 1
        check(-128, -1);     // min * -1 (classic two's complement edge case)
        check(127, -1);      // max * -1
        check(127, 0);
        check(-128, 0);
        check(0, -128);
        check(0, 127);

        // All +1/-1 boundary bit patterns per booth group
        check(8'b01010101, 8'b10101010);
        check(8'b01111111, 8'b00000001);
        check(8'b10000000, 8'b11111111);

        $display("---------------------------------------------------");
        $display(" Randomized tests (full signed 8-bit range)");
        $display("---------------------------------------------------");

        for (i = 0; i < 2000; i = i + 1) begin
            rand_a = $random;
            rand_b = $random;
            check(rand_a, rand_b);
        end

        $display("---------------------------------------------------");
        $display(" Exhaustive sweep of full signed 8-bit range (%0d x %0d = %0d cases)",
                   256, 256, 256*256);
        $display("---------------------------------------------------");

        for (i = -128; i <= 127; i = i + 1) begin
            integer j;
            for (j = -128; j <= 127; j = j + 1) begin
                check(i[DATA_WIDTH-1:0], j[DATA_WIDTH-1:0]);
            end
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