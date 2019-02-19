
// Parameterized bitwise logical operations module
// Parameter: WIDTH - represents the width of the input and output buses
// Default: WIDTH = 32 
/* Operations: 	- logic AND (sel = 0)
				- logic OR (sel = 1)
				- logic XOR (sel = 2)
*/

module logical_unit(
	term0,	//I: The inputs
	term1,
	sel,	//I: selection signal for the operation
	result	//O: the result of the bitwise operation
);
	
	parameter WIDTH = 32;
	input [(WIDTH - 1) : 0] term0;
	input [(WIDTH - 1) : 0] term1;
	input [1:0] sel;
	output reg [(WIDTH - 1) : 0] result;
	
	always @* begin
		
		case (sel)
		
		0 : result = term0 & term1;
		1 : result = term0 | term1;
		2, 3 : result = term0 ^ term1;
		
		endcase
		
	end

endmodule