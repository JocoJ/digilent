/*
* sel - 2 bits -> the value of this signal specifies which input will NOT be found in the outputs
	  0 - output in1, in2 and in3
	  1 - output in0, in2 and in3
	  2 - output in0, in1 and in3
	  3 - output in0, in1 and in2
*/

module CLB_out_stage(
	in0,
	in1,
	in2,
	in3,
	sel,
	out0,
	out1,
	out2
	);
	
	parameter WIDTH = 32;
	
	input [(WIDTH - 1) : 0] in0;
	input [(WIDTH - 1) : 0] in1;
	input [(WIDTH - 1) : 0] in2;
	input [(WIDTH - 1) : 0] in3;
	
	input [1:0] sel;
	
	output reg[(WIDTH - 1) : 0] out0;
	output reg[(WIDTH - 1) : 0] out1;
	output reg[(WIDTH - 1) : 0] out2;

	always @* begin
		
		case (sel)
		
		0 : {out0, out1, out2} = {in1, in2, in3};
		1 : {out0, out1, out2} = {in0, in2, in3};
		2 : {out0, out1, out2} = {in0, in1, in3};
		3 : {out0, out1, out2} = {in0, in1, in2};
		
		endcase
		
	end
	
endmodule
