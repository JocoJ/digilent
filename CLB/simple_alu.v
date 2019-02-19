
// Parameterized module capable of addition, subtraction, bitwise and, bitwise or
// Parameter: WIDTH - represents the width of the input and output buses
// Default: WIDTH = 32
/* Operations: 	- Addition (term0 + term1)
				- Subtraction (term0 - term1)
				- Bitwise AND
				- Bitwise OR
				
*/

module arithmetic_unit(
	term0,	//I: The terms of the operation
	term1,	
	sel,	//I: The selection for the operation: 0 - addition, 1 - subtraction, 2 - bitwise and, 3 - bitwise or
			//NOTE: The subtraction is done as term0 - term1
	result	//O: The end result
);
	
	parameter WIDTH = 32;
	input [(WIDTH - 1) : 0] term0;
	input [(WIDTH - 1) : 0] term1;
	input [1:0] sel;
	output reg [(WIDTH - 1) : 0] result;
	
	always @* begin
		
		case (sel)
		
		0 : result = term0 + term1;
		1 : result = term0 - term1;
		2 :	result = term0 & term1;
		3 : result = term0 | term1;
		endcase
	end
	
endmodule