module
    mac (
        input clk,
        input rst_n,    // _n: negative logic
        input  [7:0] a_in,     // int8
        input [7:0] b_in,
        input valid,
        input clear,
        output reg[7:0] a_out,
        output reg[7:0]b_out,
        output reg[20:0] acc
    );
    
    
  always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
    begin
      a_out<= 8'h00;
      b_out<= 8'h00;
      acc<= 8'h00;
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