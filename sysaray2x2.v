module
    mac (
        input clk,
        input  a_in, 
        input b_in,
        input valid,
        input clear,
        output aout,
        output bout,
        output reg acc
    );
    
    
    always@(posedge clk )
    begin
        if(clear)
            begin
                acc <= 0;
                aout<= 0;
                bout <= 0;
            end
         else if(valid)
        begin
            acc <= acc + (a_in*b_in);
            aout <= a_in;
            bout <= b_in;
        end
                   
    end
endmodule