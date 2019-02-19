module register32(clk, dataIn, dataOut);

	input clk;
	input [31:0] dataIn;
	output reg [31:0] dataOut;
	
	always @(posedge clk)
		dataOut = dataIn;

endmodule 
