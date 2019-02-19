
// A cell capable of shifting operations and bitwise operations
/* Operations: 	- Shift Left Logic (selOp = 0)
				- Shift Right Logic (selOp = 1)
				- Shift Right Arithmetic (selOp = 2)
				- Bitwise XOR (selOp = 3)
   NOTE: ALL SHIFT OPERATIONS USE THE LOWEST $clog2(WIDTH) BITS OF THE shamt (by default, it means the last 5 things)
*/

module cell_shifter(
	in0,	//I: inputs
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	byPass, //I: bypass signal - if set, the output will be the operand input given by the sel0 selection signal
	sel0,	//I: operands selections
	sel1,
	selOp,	//I: operation selection 
	out		//O: result of shifting operation
);

	parameter WIDTH = 32;
	
	input [(WIDTH - 1) : 0] in0;
	input [(WIDTH - 1) : 0] in1;
	input [(WIDTH - 1) : 0] in2;
	input [(WIDTH - 1) : 0] in3;
	input [(WIDTH - 1) : 0] in4;
	input [(WIDTH - 1) : 0] in5;
	input [(WIDTH - 1) : 0] in6;
	input [(WIDTH - 1) : 0] in7;
	
	input [2:0] sel0;
	input [2:0] sel1;
	input [1:0] selOp;
	input byPass;
	
	output reg[(WIDTH - 1) : 0] out;
	
	wire [WIDTH - 1 : 0] operand0;
	wire [WIDTH - 1 : 0] operand1;
	
	wire [WIDTH - 1 : 0] operationResult;

	mux_1x8 #(WIDTH) mux0(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .sel(sel0), .out(operand0));
	mux_1x8 #(WIDTH) mux1(.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .sel(sel1), .out(operand1));
	
	shift_xor_unit #(WIDTH) unit(.term(operand0), .shamt(operand1), .sel(selOp), .result(operationResult));
	
	always @*
		if (byPass)
			out = operand0;
		else
			out = operationResult;
	
endmodule