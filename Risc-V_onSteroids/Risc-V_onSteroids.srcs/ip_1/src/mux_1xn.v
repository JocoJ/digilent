
// Parameterized mux module
// Parameter: WIDTH - represents the width of the input and output buses
// Default: WIDTH = 32

module mux_1x8(
	in0,	//I: The 8 inputs
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	sel,	//I: Selection signal
	out		//O: Output
	);
	
	parameter WIDTH = 32;
	input[(WIDTH-1):0] in0;
	input[(WIDTH-1):0] in1;
	input[(WIDTH-1):0] in2;
	input[(WIDTH-1):0] in3;
	input[(WIDTH-1):0] in4;
	input[(WIDTH-1):0] in5;
	input[(WIDTH-1):0] in6;
	input[(WIDTH-1):0] in7;
	input[2:0] sel;
	output reg[(WIDTH-1):0] out;
	
	always @* begin
		
		case (sel)
		
			0 : out = in0;
			1 : out = in1;
			2 : out = in2;
			3 : out = in3;
			4 : out = in4;
			5 : out = in5;
			6 : out = in6;
			7 : out = in7;
			
		endcase
		
	end
	
endmodule