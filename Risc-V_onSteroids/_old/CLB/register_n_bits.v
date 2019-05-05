`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2019 04:24:36 PM
// Design Name: 
// Module Name: register_n_bits
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
