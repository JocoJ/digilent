module register_tb();

	reg clk;
	reg [31:0] dataIn;
	wire [31:0] dataOut;
	
	register32 inst(.clk(clk), .dataIn(dataIn), .dataOut(dataOut));
	
	initial begin
	
	clk = 0;
	forever #5 clk = ~clk;
	
	end
	
	initial begin
		
		dataIn = 0;
		
		#12 dataIn = 32'hAAAA_AAAA;
		
		#2 dataIn = 32'h0101_9111;
		
		#1 dataIn = 32'hBBBB_BBBB;
		
		#20 $finish;
	
	end

endmodule
