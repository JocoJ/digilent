module address_counter(clk, cnt, res, address);

	input clk, res, cnt;
	
	output wire[5:0] address;
	
	reg[5:0] internAddr;
	
	always @(posedge clk) begin
	
		if (res)
			internAddr <= 6'b100000;
		else if (cnt)
			internAddr <= (internAddr == 6'b100100) ? 6'b100000 : (internAddr + 1);
	
	end
	
	assign address = internAddr;

endmodule
