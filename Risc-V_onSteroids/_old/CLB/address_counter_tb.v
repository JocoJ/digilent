
module address_counter_tb();

	reg clk, cnt, res;
	wire[5:0] address;
	
	address_counter inst(.clk(clk), .res(res), .cnt(cnt), .address(address));
	
	initial begin 
	
		clk = 0;
		forever #5 clk = ~clk;
	
	end 
	
	initial begin
		
		cnt = 0;
		res = 0;
		
		#12
		res = 1;
		
		#10 res = 0;
		
		#10 cnt = 1;
		
		#70 cnt = 0;
		
		#20 $finish();
		
	end

endmodule