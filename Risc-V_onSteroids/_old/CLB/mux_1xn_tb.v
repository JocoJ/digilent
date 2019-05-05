module mux_tb();

	reg[7:0] in0, in1, in2, in3, in4, in5, in6, in7;
	reg[2:0] sel;
	wire[7:0] out;
	integer i;
	
	mux_1x8 #(8) mux(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .sel(sel), .out(out));
	
	initial begin
		
		in0 = 8'h00;
		in1 = 8'h11;
		in2 = 8'h22;
		in3 = 8'h33;
		in4 = 8'h44;
		in5 = 8'h55;
		in6 = 8'h66;
		in7 = 8'h77;
		sel = 0;
		
		for(i = 0; i<8; i=i+1) begin
			#10 sel = sel+1;
		end

		#10 $finish;
	end

endmodule
