`timescale 1ns/1ps

module tb_sysarray;

    //--------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------

    logic clk;
    logic rst_n;
    logic valid;
    logic clear;

    logic signed [7:0] a_in [2];
    logic signed [7:0] b_in [2];

    logic signed [20:0] results [4];

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    sysarray dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .clear(clear),
        .a_in(a_in),
        .b_in(b_in),
        .results(results)
    );

    //--------------------------------------------------
    // Clock Generation
    //--------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // Waveform Dump
    //--------------------------------------------------

    initial begin
        $dumpfile("sysarray.vcd");
        $dumpvars(0, tb_sysarray);
    end

    //--------------------------------------------------
    // Monitor
    //--------------------------------------------------

    initial begin
        $display("---------------------------------------------------------------");
        $display(" Time | A0 A1 | B0 B1 | R00 R01 R10 R11");
        $display("---------------------------------------------------------------");

        forever begin
            @(posedge clk);

            $display("%4t | %3d %3d | %3d %3d | %4d %4d %4d %4d",
                     $time,
                     a_in[0], a_in[1],
                     b_in[0], b_in[1],
                     results[0], results[1],
                     results[2], results[3]);
        end
    end

    //--------------------------------------------------
    // Stimulus
    //--------------------------------------------------

    initial begin

        //---------------- Reset ----------------

        rst_n = 0;
        valid = 0;
        clear = 0;

        a_in[0] = 0;
        a_in[1] = 0;
        b_in[0] = 0;
        b_in[1] = 0;

        repeat(2) @(posedge clk);

        rst_n = 1;

        //---------------- Cycle 1 ----------------

        @(posedge clk);

        valid = 1;

        a_in[0] = 1;
        a_in[1] = 3;

        b_in[0] = 5;
        b_in[1] = 6;

        //---------------- Cycle 2 ----------------

        @(posedge clk);

        a_in[0] = 2;
        a_in[1] = 4;

        b_in[0] = 7;
        b_in[1] = 8;

        //---------------- Stop ----------------

        @(posedge clk);

        valid = 0;

        a_in[0] = 0;
        a_in[1] = 0;

        b_in[0] = 0;
        b_in[1] = 0;

        //---------------- Wait ----------------

        repeat(5) @(posedge clk);

        $finish;

    end

endmodule