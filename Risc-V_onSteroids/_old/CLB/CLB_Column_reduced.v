
module CLB_column_reduced(
	in0,	//I: inputs
	in1,
	in2,
	in3,
	bypass,	//I: bypass validation vector of length 4 (one bit per cell)
	sel0_0,	//I: operand selection -- sel0_x - x is the cell from the column x = 0, 1, 2, 3
	sel1_0,	//					   -- sely_0 - y is the operand of the cell, y = 0/1
	sel0_1,
	sel1_1,
	sel0_2,
	sel1_2,
	sel0_3,
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
	
	input [3:0] bypass;
	input [1:0] sel0_0;
	input [1:0] sel1_0;
	input [1:0] sel0_1;
	input [1:0] sel1_1;
	input [1:0] sel0_2;
	input [1:0] sel1_2;
	input [1:0] sel0_3;
	input [1:0] sel1_3;

	input [1:0] selOp0;
	input [1:0] selOp1;
	input [1:0] selOp2;
	input [1:0] selOp3;
	
	output [WIDTH-1:0] out0;
	output [WIDTH-1:0] out1;
	output [WIDTH-1:0] out2;
	output [WIDTH-1:0] out3;
	
	cell_arithmetic_logic_reduced #(WIDTH) cell_0(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .byPass(bypass[3]), .sel0(sel0_0), .sel1(sel1_0), .selOp(selOp0), .out(out0));
	cell_arithmetic_logic_reduced #(WIDTH) cell_1(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .byPass(bypass[2]), .sel0(sel0_1), .sel1(sel1_1), .selOp(selOp1), .out(out1));
	cell_arithmetic_logic_alt_reduced #(WIDTH) cell_2(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .byPass(bypass[1]), .sel0(sel0_2), .sel1(sel1_2), .selOp(selOp2), .out(out2));
	cell_shifter_reduced #(WIDTH) cell_3(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .byPass(bypass[0]), .sel0(sel0_3), .sel1(sel1_3), .selOp(selOp3), .out(out3));

endmodule