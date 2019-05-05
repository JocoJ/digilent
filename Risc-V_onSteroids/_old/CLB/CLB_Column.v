
module CLB_column(
	in0,	//I: inputs
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	bypass,	//I: bypass validation vector of length 4 (one bit per cell)
	sel0_0,	//I: operand selection -- sel0_x - x is the cell from the column
	sel1_0,	// arithmetic
	sel0_1, //arithmetic
	sel1_1, 
	sel0_2, //alternative arithmetic
	sel1_2,
	sel0_3, //shift/xor
	sel1_3,
	selOp0,	//I: operation selection, 2 bits in length, one sel per cell
	selOp1,
	selOp2,
	selOp3,
	out0,	//O: result of cell_0
	out1,	//O: result of cell_1
	out2,	//O: result of cell_2
	out3	//O: result of cell_3
	);
	
	parameter WIDTH = 32;
	
	input [WIDTH - 1:0] in0;
	input [WIDTH - 1:0] in1;
	input [WIDTH - 1:0] in2;
	input [WIDTH - 1:0] in3;
	input [WIDTH - 1:0] in4;
	input [WIDTH - 1:0] in5;
	input [WIDTH - 1:0] in6;
	input [WIDTH - 1:0] in7;
	
	input [3:0] bypass;
	input [2:0] sel0_0;
	input [2:0] sel1_0;
	input [2:0] sel0_1;
	input [2:0] sel1_1;
	input [2:0] sel0_2;
	input [2:0] sel1_2;
	input [2:0] sel0_3;
	input [2:0] sel1_3;

	input [1:0] selOp0;
	input [1:0] selOp1;
	input [1:0] selOp2;
	input [1:0] selOp3;
	
	output [WIDTH-1:0] out0;
	output [WIDTH-1:0] out1;
	output [WIDTH-1:0] out2;
	output [WIDTH-1:0] out3;
	
	cell_arithmetic_logic #(WIDTH) cell_0(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .byPass(bypass[3]), .sel0(sel0_0), .sel1(sel1_0), .selOp(selOp0), .out(out0));
	cell_arithmetic_logic #(WIDTH) cell_1(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .byPass(bypass[2]), .sel0(sel0_1), .sel1(sel1_1), .selOp(selOp1), .out(out1));
	cell_arithmetic_logic_alt #(WIDTH) cell_2(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .byPass(bypass[1]), .sel0(sel0_2), .sel1(sel1_2), .selOp(selOp2), .out(out2));
	cell_shifter #(WIDTH) cell_3(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .byPass(bypass[0]), .sel0(sel0_3), .sel1(sel1_3), .selOp(selOp3), .out(out3));

endmodule