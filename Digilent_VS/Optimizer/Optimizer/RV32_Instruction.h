#pragma once
#include "Masks.h"

enum RV32_types
{
	R_type,
	S_type,
	SB_type,
	I_type,
	UJ_type,
	U_type,
	UNKNOWN
};

//Class for encapsulating an RV32_Instruction

class RV32_Instruction
{
private:

	// The 32 bits that make up the instruction
	unsigned char instruction[4];	

	// The type of the instruction
	RV32_types instruction_type;
public:
	RV32_Instruction()
	{
		instruction[3] = instruction[3] = instruction[2] = instruction[1] = 0;
		instruction_type = UNKNOWN;
	}

	RV32_Instruction(unsigned char val[4]);

	RV32_Instruction(RV32_Instruction&);

	~RV32_Instruction();

	RV32_Instruction& operator= (RV32_Instruction&);

	// returns the opcode of the instruction
	char opcode();			
	
	// returns the type of instruction
	RV32_types type();		

	// returns the destination register
	// if the instruction type does not have a destination register, it returns a negative value
	char destination_register();	
									
	// returns the funct3 field, if the instruction type has it
	// otherwise, it returns a negative value
	char funct3();	

	// returns the rs1 field
	// if there is none, returns a negative value
	char source_register_first();

	// returns the rs2 field
	// if there is none, returns a negative value
	char source_register_second();

	// returns the funct7 field
	// if there is none, returns a negative value
	char funct7();

	// if the instruction has an immediate field, it will return true
	// on success, the imm vector will contain the value of the immediate field
	// if there is no such field in the instruction, the function returns false
	bool immediate_field(char imm[4]);
};
