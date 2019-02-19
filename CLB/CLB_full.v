
module CLB_full(
	
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
	out_00,
	out_01,
	out_02,
	out_03,
	out_10,
	out_11,
	out_12,
	out_13,
	out_20,
	out_21,
	out_22,
	out_23,
	out_30,
	out_31,
	out_32,
	out_33,
	
	selOut0,
	selOut1,
	selOut2,
	
	result0,
	result1,
	result2
	);
	
	parameter WIDTH = 32;
	
	input [WIDTH - 1 : 0] in0;		
	input [WIDTH - 1 : 0] in1;
	input [WIDTH - 1 : 0] in2;
	input [WIDTH - 1 : 0] in3;
	input [WIDTH - 1 : 0] in4;
	input [WIDTH - 1 : 0] in5;
	input [WIDTH - 1 : 0] in6;
	input [WIDTH - 1 : 0] in7;

	input [3:0] bypass_0;			
	input [3:0] bypass_1;
	input [3:0] bypass_2;
	input [3:0] bypass_3;
	
	input [2:0] sel0_00;
	input [2:0] sel1_00;
	input [2:0] sel0_01;
	input [2:0] sel1_01;
	input [2:0] sel0_02;
	input [2:0] sel1_02;
	input [2:0] sel0_03;
	input [2:0] sel1_03;
	input [2:0] sel0_10;
	input [2:0] sel1_10;
	input [2:0] sel0_11;
	input [2:0] sel1_11;
	input [2:0] sel0_12;
	input [2:0] sel1_12;
	input [2:0] sel0_13;
	input [2:0] sel1_13;
	input [2:0] sel0_20;
	input [2:0] sel1_20;
	input [2:0] sel0_21;
	input [2:0] sel1_21;
	input [2:0] sel0_22;
	input [2:0] sel1_22;
	input [2:0] sel0_23;
	input [2:0] sel1_23;
	input [2:0] sel0_30;
	input [2:0] sel1_30;
	input [2:0] sel0_31;
	input [2:0] sel1_31;
	input [2:0] sel0_32;
	input [2:0] sel1_32;
	input [2:0] sel0_33;
	input [2:0] sel1_33;
	
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
	input [1:0] selOp_33;
	
	output reg [WIDTH - 1 : 0] out_00;
	output reg [WIDTH - 1 : 0] out_01;
	output reg [WIDTH - 1 : 0] out_02;
	output reg [WIDTH - 1 : 0] out_03;
	output reg [WIDTH - 1 : 0] out_10;
	output reg [WIDTH - 1 : 0] out_11;
	output reg [WIDTH - 1 : 0] out_12;
	output reg [WIDTH - 1 : 0] out_13;
	output reg [WIDTH - 1 : 0] out_20;
	output reg [WIDTH - 1 : 0] out_21;
	output reg [WIDTH - 1 : 0] out_22;
	output reg [WIDTH - 1 : 0] out_23;
	output reg [WIDTH - 1 : 0] out_30;
	output reg [WIDTH - 1 : 0] out_31;
	output reg [WIDTH - 1 : 0] out_32;
	output reg [WIDTH - 1 : 0] out_33;
	
	input [1:0] selOut0;
	input [1:0] selOut1;
	input [1:0] selOut2;
	
	output reg [WIDTH - 1: 0] result0;
	output reg [WIDTH - 1: 0] result1;
	output reg [WIDTH - 1: 0] result2;
	
	CLB_column #(WIDTH) column0 (.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .bypass(bypass_0), .sel0_0(sel0_00), .sel1_0(sel1_00), .sel0_1(sel0_10), .sel1_1(sel1_10), .sel0_2(sel0_20), .sel1_2(sel1_20), .sel0_3(sel0_30), .sel1_3(sel1_30), .out0(out00), .out1(out10), .out2(out20), .out3(out30));
	CLB_column #(WIDTH) column1 (.in0(out00), .in1(out10), .in2(out20), .in3(out30), .in4(out00), .in5(out10), .in6(out20), .in7(out30), .bypass(bypass_1), .sel0_0(sel0_01), .sel1_0(sel1_01), .sel0_1(sel0_11), .sel1_1(sel1_11), .sel0_2(sel0_21), .sel1_2(sel1_21), .sel0_3(sel0_31), .sel1_3(sel1_31), .out0(out01), .out1(out11), .out2(out21), .out3(out31));
	CLB_column #(WIDTH) column2 (.in0(out01), .in1(out11), .in2(out21), .in3(out31), .in4(out01), .in5(out11), .in6(out21), .in7(out31), .bypass(bypass_2), .sel0_0(sel0_02), .sel1_0(sel1_02), .sel0_1(sel0_12), .sel1_1(sel1_12), .sel0_2(sel0_22), .sel1_2(sel1_22), .sel0_3(sel0_32), .sel1_3(sel1_32), .out0(out02), .out1(out12), .out2(out22), .out3(out32));
	CLB_column #(WIDTH) column3 (.in0(out02), .in1(out12), .in2(out22), .in3(out32), .in4(out02), .in5(out12), .in6(out22), .in7(out32), .bypass(bypass_3), .sel0_0(sel0_02), .sel1_0(sel1_03), .sel0_1(sel0_13), .sel1_1(sel1_13), .sel0_2(sel0_23), .sel1_2(sel1_23), .sel0_3(sel0_33), .sel1_3(sel1_33), .out0(out03), .out1(out13), .out2(out23), .out3(out33));
	
	mux_1x4 #(WIDTH) mux0(.sel(selOut0), .in0(out03), .in1(out13), .in2(out23), .in3(out33), .out(result0));
	mux_1x4 #(WIDTH) mux1(.sel(selOut1), .in0(out03), .in1(out13), .in2(out23), .in3(out33), .out(result1));
	mux_1x4 #(WIDTH) mux2(.sel(selOut2), .in0(out03), .in1(out13), .in2(out23), .in3(out33), .out(result2));
	
endmodule
