module cbb_d(input clk, input d, output reg o);

	always @(posedge clk)
		o = d;

endmodule
