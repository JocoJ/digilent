module CLB_full(
	
	register_clk,
	register_reset,
	register_par_load,
	
	result_sel,
	
	in0,		//I: inputs
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	/*
	I: column bypass
	- one 4 bit vector for each column
	- bypass_<t> -> <t> = respective column
	- bypass_<t>[0:1] -> arithmetic_logic bypass
	- bypass_<t>[2] -> arithmetic_logic_alternative bypass
	- bypass_<t>[3] -> shifter bypass
	*/
	bypass_0,			
	bypass_1,
	bypass_2,
	bypass_3,
	
	/*
	I: operand selection, 3 bits
	- sel<x>_<y><z> -> <x> - 0/1: the first or second operand of the respective cell
					-> <y> - the line coordinate in the CLB cell matrix
					-> <z> - the column coordinate in the CLB cell matrix
	- for columns 1:3, the MSB is indifferent, still using a 3 bit selection for possible future reconfiguration
	*/
	sel0_00,
	sel1_00,
	sel0_01,
	sel1_01,
	sel0_02,
	sel1_02,
	sel0_03,
	sel1_03,
	sel0_10,
	sel1_10,
	sel0_11,
	sel1_11,
	sel0_12,
	sel1_12,
	sel0_13,
	sel1_13,
	sel0_20,
	sel1_20,
	sel0_21,
	sel1_21,
	sel0_22,
	sel1_22,
	sel0_23,
	sel1_23,
	sel0_30,
	sel1_30,
	sel0_31,
	sel1_31,
	sel0_32,
	sel1_32,
	sel0_33,
	sel1_33,
	
	/*
	I: operation selection for each cell
	- selOp_<x><y> -> <x> - the line coordinate of the respective cell in the matrix
				   -> <y> - the column coordinate of the respective cell in the matrix
	*/
	selOp_00,
	selOp_01,
	selOp_02,
	selOp_03,
	selOp_10,
	selOp_11,
	selOp_12,
	selOp_13,
	selOp_20,
	selOp_21,
	selOp_22,
	selOp_23,
	selOp_30,
	selOp_31,
	selOp_32,
	selOp_33,
	
	/*
	O: every output of every cell
	*/
	buff0, 
	buff1, 
	buff2, 
	buff3,
	
	result0,
	result1,
	result2
	
	);
	
	parameter WIDTH = 32;
	
	input register_clk;
	input register_reset;
	input register_par_load;
	
	input [1:0] result_sel;	//2 bits
	
	input [(WIDTH - 1) : 0] in0;		
	input [(WIDTH - 1) : 0] in1;
	input [(WIDTH - 1) : 0] in2;
	input [(WIDTH - 1) : 0] in3;
	input [(WIDTH - 1) : 0] in4;
	input [(WIDTH - 1) : 0] in5;
	input [(WIDTH - 1) : 0] in6;
	input [(WIDTH - 1) : 0] in7;

	input [3:0] bypass_0;			
	input [3:0] bypass_1;
	input [3:0] bypass_2;
	input [3:0] bypass_3;	//16 bits
	
	input [2:0] sel0_00;
	input [2:0] sel1_00;
	input [2:0] sel0_10;
	input [2:0] sel1_10;
	input [2:0] sel0_20;
	input [2:0] sel1_20;
	input [2:0] sel0_30;
	input [2:0] sel1_30; 	//24 bits
	
	input [1:0] sel0_01;
	input [1:0] sel1_01;
	input [1:0] sel0_02;
	input [1:0] sel1_02;
	input [1:0] sel0_03;
	input [1:0] sel1_03;
	input [1:0] sel0_11;
	input [1:0] sel1_11;
	input [1:0] sel0_12;
	input [1:0] sel1_12;
	input [1:0] sel0_13;
	input [1:0] sel1_13;
	input [1:0] sel0_21;
	input [1:0] sel1_21;
	input [1:0] sel0_22;
	input [1:0] sel1_22;
	input [1:0] sel0_23;
	input [1:0] sel1_23;
	input [1:0] sel0_31;
	input [1:0] sel1_31;
	input [1:0] sel0_32;
	input [1:0] sel1_32;
	input [1:0] sel0_33;
	input [1:0] sel1_33;	//24*2 = 48 bits
	
	input [1:0] selOp_00;
	input [1:0] selOp_01;
	input [1:0] selOp_02;
	input [1:0] selOp_03;
	input [1:0] selOp_10;
	input [1:0] selOp_11;
	input [1:0] selOp_12;
	input [1:0] selOp_13;
	input [1:0] selOp_20;
	input [1:0] selOp_21;
	input [1:0] selOp_22;
	input [1:0] selOp_23;
	input [1:0] selOp_30;
	input [1:0] selOp_31;
	input [1:0] selOp_32;
	input [1:0] selOp_33;	//16*2 = 32 bits
							//TOTAL: 122 bits for configuring
	
	wire [(WIDTH - 1) : 0] out_00;
	wire [(WIDTH - 1) : 0] out_01;
	wire [(WIDTH - 1) : 0] out_02;
	wire [(WIDTH - 1) : 0] out_03;
	wire [(WIDTH - 1) : 0] out_10;
	wire [(WIDTH - 1) : 0] out_11;
	wire [(WIDTH - 1) : 0] out_12;
	wire [(WIDTH - 1) : 0] out_13;
	wire [(WIDTH - 1) : 0] out_20;
	wire [(WIDTH - 1) : 0] out_21;
	wire [(WIDTH - 1) : 0] out_22;
	wire [(WIDTH - 1) : 0] out_23;
	wire [(WIDTH - 1) : 0] out_30;
	wire [(WIDTH - 1) : 0] out_31;
	wire [(WIDTH - 1) : 0] out_32;
	wire [(WIDTH - 1) : 0] out_33;
	
	output [(WIDTH - 1) : 0] result0;
	output [(WIDTH - 1) : 0] result1;
	output [(WIDTH - 1) : 0] result2;
	
	CLB_column #(WIDTH) column0 (.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .bypass(bypass_0), .sel0_0(sel0_00), .sel1_0(sel1_00), .sel0_1(sel0_10), .sel1_1(sel1_10), .sel0_2(sel0_20), .sel1_2(sel1_20), .sel0_3(sel0_30), .sel1_3(sel1_30), .out0(out_00), .out1(out_10), .out2(out_20), .out3(out_30), .selOp0(selOp_00), .selOp1(selOp_10), .selOp2(selOp_20), .selOp3(selOp_30));
	CLB_column #(WIDTH) column1 (.in0(out_00), .in1(out_10), .in2(out_20), .in3(out_30), .in4(out_00), .in5(out_10), .in6(out_20), .in7(out_30), .bypass(bypass_1), .sel0_0({1'b0, sel0_01}), .sel1_0({1'b0, sel1_01}), .sel0_1({1'b0, sel0_11}), .sel1_1({1'b0, sel1_11}), .sel0_2({1'b0, sel0_21}), .sel1_2({1'b0, sel1_21}), .sel0_3({1'b0, sel0_31}), .sel1_3({1'b0, sel1_31}), .out0(out_01), .out1(out_11), .out2(out_21), .out3(out_31), .selOp0(selOp_01), .selOp1(selOp_11), .selOp2(selOp_21), .selOp3(selOp_31));
	
	output [(WIDTH-1) : 0] buff0, buff1, buff2, buff3;
	
	register_n_bits #(4*WIDTH) pipe(.clk(register_clk), .res(register_reset), .par_load(register_par_load), .data_in({out_01, out_11, out_21, out_31}), .data_out({buff0, buff1, buff2, buff3}));
	
	CLB_column #(WIDTH) column2 (.in0(buff0), .in1(buff1), .in2(buff2), .in3(buff3), .in4(buff0), .in5(buff1), .in6(buff2), .in7(buff3), .bypass(bypass_2), .sel0_0({1'b0, sel0_02}), .sel1_0({1'b0, sel1_02}), .sel0_1({1'b0, sel0_12}), .sel1_1({1'b0, sel1_12}), .sel0_2({1'b0, sel0_22}), .sel1_2({1'b0, sel1_22}), .sel0_3({1'b0, sel0_32}), .sel1_3({1'b0, sel1_32}), .out0(out_02), .out1(out_12), .out2(out_22), .out3(out_32), .selOp0(selOp_02), .selOp1(selOp_12), .selOp2(selOp_22), .selOp3(selOp_32));
	CLB_column #(WIDTH) column3 (.in0(out_02), .in1(out_12), .in2(out_22), .in3(out_32), .in4(out_02), .in5(out_12), .in6(out_22), .in7(out_32), .bypass(bypass_3), .sel0_0({1'b0, sel0_02}), .sel1_0({1'b0, sel1_03}), .sel0_1({1'b0, sel0_13}), .sel1_1({1'b0, sel1_13}), .sel0_2({1'b0, sel0_23}), .sel1_2({1'b0, sel1_23}), .sel0_3({1'b0, sel0_33}), .sel1_3({1'b0, sel1_33}), .out0(out_03), .out1(out_13), .out2(out_23), .out3(out_33), .selOp0(selOp_03), .selOp1(selOp_13), .selOp2(selOp_23), .selOp3(selOp_33));
	
	CLB_out_stage #(WIDTH) result_stage(.in0(out_03), .in1(out_13), .in2(out_23), .in3(out_33), .sel(result_sel), .out0(result0), .out1(result1), .out2(result2));
	
endmodule