
// Parameterized module capable of shifting operations (logical and arithmetic), as well as XOR
// Parameter: WIDTH - represents the width of the input and output buses
// Default: WIDTH = 32
/* Operations: 	- Shift Left Logic (sel = 0)
				- Shift Right Logic (sel = 1)
				- Shift Right Arithmetic (sel = 2)
				- Bitwise XOR (sel = 3)
   NOTE: ALL SHIFT OPERATIONS USE THE LOWEST $clog2(WIDTH) BITS OF THE shamt (by default, it means the last 5 things)
*/

module shift_xor_unit(
	term,	//I: value to be shifted or XOR term
	shamt,	//I: amount to shift with or XOR term
	sel,	//I: selection for operation type
	result	//O: result of shifting operation
	);

	parameter WIDTH = 32;
	localparam SHIFT_WIDTH = $clog2(WIDTH);
	input [(WIDTH - 1) : 0] term;
	input [(WIDTH - 1) : 0] shamt;
	input [1:0] sel;
	output reg[(WIDTH - 1) : 0] result;
	
	always @* begin
		
		case (sel)
			
			0 : result = term << shamt[(SHIFT_WIDTH - 1) : 0];
			1 : result = term >> shamt[(SHIFT_WIDTH - 1) : 0];
			2 : result = term >>> shamt[(SHIFT_WIDTH - 1) : 0];
			3 : result = term ^ shamt;
			
		endcase
		
	end
	
endmodule