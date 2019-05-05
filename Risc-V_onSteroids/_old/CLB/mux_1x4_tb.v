module mux_1x4_tb();

	reg [1:0] sel;
	reg [31:0] in0, in1, in2, in3;
	wire[31:0] out;
	
	mux_1x4 inst(.sel(sel), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out));
	
	initial begin
		
		sel = 2'b0;
		in0 = 32'hAAAA_AAAA;
		in1 = 32'h5555_5555;
		in2 = 32'h0000_0000;
		in3 = 32'hFFFF_FFFF;
		
		#20
		in0 = 32'hCCCC_CCCC;
		
		#20 sel = sel+1;
		
		#20
		in1 = 32'h7777_7777;
		
		#20 sel = sel+1;
		
		#20
		in2 = 32'h1111_1111;
		
		#20 sel = sel+1;
		
		#20 
		in3 = 32'h4444_4444;
		
		#20 $finish;
		
	end

endmodule
