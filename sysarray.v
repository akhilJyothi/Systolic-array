module sysarray (
    clk,rst_n,a_in,b_in, valid,clear
);
input  signed [7:0] a_in[1:0]; 
input  signed [7:0] b_in[1:0];
input clk;
input rst_n;
input valid;
input clear;
output wire signed[20:0] results[3:0];   // driven by mac module, there wires and not registers
   
wire signed[7:0] a_pe00tope01,b_pe00tope10,a_pe10tope11,b_pe01tope11;

mac pe00(.clk(clk),.rst_n(rst_n),.valid(valid), .clear(clear),.a_in(a_in[0]),.b_in(b_in[0]),.a_out(a_pe00tope01),.b_out(b_pe00tope10), .acc(results[0]));
mac pe01(.clk(clk),.rst_n(rst_n),.valid(valid), .clear(clear),.a_in(a_pe00tope01),.b_in(b_in[1]),.a_out(),.b_out(b_pe01tope11), .acc(results[1]));
mac pe10(.clk(clk),.rst_n(rst_n),.valid(valid), .clear(clear),.a_in(a_in[1]),.b_in(b_pe00tope10),.a_out(a_pe10tope11),.b_out(), .acc(results[2]));
mac pe11(.clk(clk),.rst_n(rst_n),.valid(valid), .clear(clear),.a_in(a_pe10tope11),.b_in(b_pe01tope11),.a_out(),.b_out(), .acc(results[3]));

endmodule




//            b_in[0]           b_in[1]
//               │                 │
//               ▼                 ▼
//         +-----------+     +-----------+
// a_in[0]->|   PE00    |---->|   PE01    |
//          +-----------+     +-----------+
//               │                 │
//               ▼                 ▼
//         +-----------+     +-----------+
// a_in[1]->|   PE10    |---->|   PE11    |
//          +-----------+     +-----------+