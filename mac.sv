module
    mac (
parameter ARRAY_SIZE = 8,  //array size nxn mac units
parameter DATA_WIDTH = 8,   // int8 input width
parameter ACCUM_WIDTH = 21
)(
        input logic clk,
        input  logic rst_n,    // _n: negative logic
        input logic signed [(DATA_WIDTH-1):0] a_in,     // int8
        input logic signed [(DATA_WIDTH-1):0] b_in,
        input logic valid,
        input logic clear,
        output logic  signed [(DATA_WIDTH-1):0] a_out,
        output logic  signed [(DATA_WIDTH-1):0]b_out,
        output logic  signed [ACCUM_WIDTH-1:0] acc
    );
    
    
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
    begin
      a_out<= 8'h00;
      b_out<= 8'h00;
      acc<= 0;
    end
    else
    begin
      a_out<=a_in;
      b_out<=b_in;
      if(clear)
      begin
        acc<=0;
      end
      else if (valid) 
      begin
      acc<=acc +(a_in*b_in);  
      end
    end
  end

endmodule