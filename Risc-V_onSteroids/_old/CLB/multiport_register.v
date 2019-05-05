module multiport_register_n_bits(
	clk,
	write_enable_basic,		// I: write enable for the single port mode
	write_enable_conf,		// I: write enable for the configuration registers (32->36)
	write_enable_CLB,		// I: write enable for multiport mode
	read_addr1,				// I: read addresses
	read_addr2,
	read_addr3,
	read_addr4,
	read_addr5,
	read_addr6,
	write_addr,				// I: write address for single port mode (NOTE: multiport writing addresses are handled by the configuration registers)
	write_addr_conf,		// I: write address for the configuration registers
	write_data1,			// I: write data for both single port and multiport modes
	write_data2,			// I: write data for multiport mode only
	write_data3,			// I: write data for multiport mode only
	write_data_conf,		// I: write data for the configuration registers
	read_data1,				// O: output data from the regFile
	read_data2,
	read_data3,
	read_data4,
	read_data5,
	read_data6,
	CLB_conf1,				// O: outputs for the CHM
	CLB_conf2,
	CLB_conf3,
	CLB_conf4,
	CLB_conf5
	);

	parameter WIDTH = 32;
	
	input clk, write_enable_basic, write_enable_CLB, write_enable_conf;
	input[5:0] read_addr1, read_addr2, read_addr3, read_addr4, read_addr5, read_addr6;
	input[5:0] write_addr, write_addr_conf;
	
	output wire [WIDTH - 1 : 0] read_data1, read_data2, read_data3, read_data4, read_data5, read_data6;
	output wire [WIDTH - 1 : 0] CLB_conf1, CLB_conf2, CLB_conf3, CLB_conf4, CLB_conf5;
	input [WIDTH - 1 : 0] write_data1, write_data2, write_data3, write_data_conf;
	
	wire [5:0] write_addr1, write_addr2, write_addr3;
	
	assign write_addr1 = CLB_conf1[31:27];
	assign write_addr2 = CLB_conf2[31:27];
	assign write_addr3 = CLB_conf3[31:27];
	
	reg[WIDTH - 1 : 0] memory[0:63];
	
	always @(posedge clk) begin
		if (write_enable_basic && write_addr)
			memory[write_addr] <= write_data1;
		if (write_addr_conf && write_enable_conf)
			memory[write_addr_conf] <= write_data_conf;
		if (write_enable_CLB) begin
			if (write_addr1)
				memory[{1'b0, write_addr1}] <= write_data1;
			if (write_addr2)
				memory[{1'b0, write_addr2}] <= write_data2;
			if (write_addr3)
				memory[{1'b0, write_addr3}] <= write_data3;
		end
		memory[0] <= 0;
	end
	
	assign CLB_conf1 = memory[32];
	assign CLB_conf2 = memory[33];
	assign CLB_conf3 = memory[34];
	assign CLB_conf4 = memory[35];
	assign CLB_conf5 = memory[36];
	
	assign read_data1 = memory[read_addr1];
	assign read_data2 = memory[read_addr2];
	assign read_data3 = memory[read_addr3];
	assign read_data4 = memory[read_addr4];
	assign read_data5 = memory[read_addr5];
	assign read_data6 = memory[read_addr6];
	
endmodule
