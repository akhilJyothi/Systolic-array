`timescale 1ps/1ps

module tb_mac;

reg clk;
reg rst_n;
reg signed [7:0] a_in,b_in;
wire signed [20:0]acc ;
reg valid,clear;
wire signed[7:0] a_out, b_out;
 mac dut (
        .clk(clk),
        .rst_n(rst_n),
        .a_in(a_in),
        .b_in(b_in),
        .valid(valid),
        .clear(clear),
        .a_out(a_out),
        .b_out(b_out),
        .acc(acc)
    );


initial begin
    $monitor("Time=%0t | a=%0d b=%0d | a_out=%0d b_out=%0d | valid=%b clear=%b | acc=%0d",
             $time, a_in, b_in, a_out, b_out, valid, clear, acc);
end

initial begin
    clk= 0;
    forever begin
        #5 clk= ~clk;
    end
end

   initial begin
        $dumpfile("mac.vcd");
        $dumpvars(0, tb_mac);
    end

    //--------------------------------------------------
    // Test sequence
    //--------------------------------------------------
    initial begin

        // Initialize
        rst_n = 0;
        clear = 0;
        valid = 0;
        a_in = 0;
        b_in = 0;

        #12;

        //--------------------------------------------
        // Release reset
        //--------------------------------------------
        rst_n = 1;

        //--------------------------------------------
        // Test 1
        // 3 × 4 = 12
        //--------------------------------------------
        @(posedge clk);
        valid = 1;
        a_in = 3;
        b_in = 4;

        //--------------------------------------------
        // Test 2
        // +2 × 5 = 10
        //--------------------------------------------
        @(posedge clk);
        a_in = 2;
        b_in = 5;

        //--------------------------------------------
        // Test 3
        // valid = 0
        //--------------------------------------------
        @(posedge clk);
        valid = 0;
        a_in = 7;
        b_in = 7;

        //--------------------------------------------
        // Test 4
        // Clear accumulator
        //--------------------------------------------
        @(posedge clk);
        clear = 1;

        @(posedge clk);
        clear = 0;

        //--------------------------------------------
        // Test 5
        // -2 × 6 = -12
        //--------------------------------------------
        @(posedge clk);
        valid = 1;
        a_in = -2;
        b_in = 6;

        //--------------------------------------------
        // Finish
        //--------------------------------------------
        @(posedge clk);
        $finish;

    end

endmodule