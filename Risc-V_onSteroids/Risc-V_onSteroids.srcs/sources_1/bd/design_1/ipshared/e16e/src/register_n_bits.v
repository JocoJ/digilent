module register_n_bits(
    clk,
    res,
    par_load,
    data_in,
    data_out
    );
    
    parameter WIDTH = 32;
    input clk, par_load, res;
    input [WIDTH-1 : 0] data_in;
    output reg [WIDTH - 1 : 0] data_out;
    
    always @(posedge clk) begin
        
        if (res)
            data_out <= 0;
        else if (par_load)
            data_out <= data_in;
                    
    end 
    
endmodule