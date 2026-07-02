`timescale 1ns/1ps

module tb_sysarray;

reg clk;
reg rst_n;
reg valid;
reg clear;

// Left edge inputs
reg signed [7:0] a_in [1:0];

// Top edge inputs
reg signed [7:0] b_in [1:0];

// Outputs
wire signed [20:0] results [3:0];

// DUT
sysarray dut(
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .clear(clear),
    .a_in(a_in),
    .b_in(b_in),
    .results(results)
);

/////////////////////////////////////////////////////////
// Clock
/////////////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

/////////////////////////////////////////////////////////
// Dump
/////////////////////////////////////////////////////////

initial begin
    $dumpfile("sysarray.vcd");
    $dumpvars(0,tb_sysarray);
end

/////////////////////////////////////////////////////////
// Monitor
/////////////////////////////////////////////////////////

initial begin
    $monitor(
    "T=%0t | A=(%0d,%0d) B=(%0d,%0d) | R00=%0d R01=%0d R10=%0d R11=%0d",
    $time,
    a_in[0],a_in[1],
    b_in[0],b_in[1],
    results[0],
    results[1],
    results[2],
    results[3]
    );
end

/////////////////////////////////////////////////////////
// Stimulus
/////////////////////////////////////////////////////////

initial begin

    rst_n = 0;
    valid = 0;
    clear = 0;

    a_in[0]=0;
    a_in[1]=0;

    b_in[0]=0;
    b_in[1]=0;

    #12;

    rst_n = 1;

    //----------------------------------------------------
    // Cycle 1
    //----------------------------------------------------

    @(posedge clk);

    valid = 1;

    a_in[0]=1;
    a_in[1]=3;

    b_in[0]=5;
    b_in[1]=6;

    //----------------------------------------------------
    // Cycle 2
    //----------------------------------------------------

    @(posedge clk);

    a_in[0]=2;
    a_in[1]=4;

    b_in[0]=7;
    b_in[1]=8;

    //----------------------------------------------------
    // Stop feeding
    //----------------------------------------------------

    @(posedge clk);

    valid=0;

    a_in[0]=0;
    a_in[1]=0;

    b_in[0]=0;
    b_in[1]=0;

    //----------------------------------------------------
    // Wait for data to drain
    //----------------------------------------------------

    repeat(4)
        @(posedge clk);

    //----------------------------------------------------
    // Finish
    //----------------------------------------------------

    $finish;

end

endmodule