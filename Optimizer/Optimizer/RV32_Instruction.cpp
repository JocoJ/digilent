#include "RV32_Instruction.h"

RV32_Instruction::RV32_Instruction(unsigned char val[4])
{
	for (int i = 0; i < 4; i++)
	{
		instruction[i] = val[i];
	}

	unsigned char opcode = (val[3] & OPCODE_8);

	switch (opcode)
	{
	case LUI_8:
	case AUIPC_8: instruction_type = U_type; break;
	case JAL_8: instruction_type = UJ_type; break;
	case JALR_8:
	case LOAD_8:
	case IMMEDIATE_8: instruction_type = I_type; break;
	case BRANCH_8: instruction_type = SB_type; break;
	case STORE_8: instruction_type = S_type; break;
	case REGISTER_8: instruction_type = R_type; break;
	default:
		instruction_type = UNKNOWN;
		break;
	}
}

RV32_Instruction::RV32_Instruction(RV32_Instruction& copy)
{
	for (int i = 0; i < 4; i++)
	{
		instruction[i] = copy.instruction[i];
	}

	instruction_type = copy.instruction_type;
}

RV32_Instruction::~RV32_Instruction()
{

}

RV32_Instruction& RV32_Instruction::operator=(RV32_Instruction& copy)
{
	for (int i = 0; i < 4; i++)
	{
		instruction[i] = copy.instruction[i];
	}

	instruction_type = copy.instruction_type;
	return (*this);
}

char RV32_Instruction::opcode()
{
	return (instruction[3] & OPCODE_8);
}

RV32_types RV32_Instruction::type()
{
	return instruction_type;
}

char RV32_Instruction::destination_register()
{
	if (instruction_type == UJ_type || instruction_type == U_type || instruction_type == I_type || instruction_type == R_type)
	{
		char destination = (((instruction[2] << 1) | (instruction[3] >> 7)) & RD_8);
		return destination;
	}
	else
	{
		return -1;
	}
}

char RV32_Instruction::funct3()
{
	if (instruction_type == I_type || instruction_type == SB_type || instruction_type == S_type || instruction_type == R_type)
	{
		char val = ((instruction[2] >> 4) & FUNCT3_8);
		return val;
	}
	else
	{
		return -1;
	}
}

char RV32_Instruction::source_register_first()
{
	if (instruction_type == I_type || instruction_type == SB_type || instruction_type == S_type || instruction_type == R_type)
	{
		char val = (((instruction[2] >> 7) | (instruction[1] << 1)) & RS1_8);
		return val;
	}
	else
	{
		return -1;
	}
}

char RV32_Instruction::source_register_second()
{
	if (instruction_type == SB_type || instruction_type == S_type || instruction_type == R_type)
	{
		char val = (((instruction[1] >> 4) | (instruction[0] << 4)) & RS2_8);
		return val;
	}
	else
	{
		return -1;
	}
}

char RV32_Instruction::funct7()
{
	if (instruction_type == R_type)
	{
		char val = ((instruction[0] >> 1) & FUNCT7_8);
		return val;
	}
	else
	{
		return -1;
	}
}

bool RV32_Instruction::immediate_field(char imm[4])
{
	switch (instruction_type)
	{
	case R_type:
		return false;
		break;
	case S_type:
		imm[3] = (((instruction[3] & 0x80) >> 7) | ((instruction[2] & 0x0F) << 1) | ((instruction[0] & 0x0E) << 4));
		imm[2] = (((char)(instruction[0])) >> 4);
		imm[1] = imm[0] = (imm[2] & 0x80) ? 0xFF : 0x00;;
		return true;
		break;
	case SB_type:
		imm[3] = (((instruction[2] & 0x0F) | ((instruction[0] & 0x1E) << 3)));
		imm[2] = (((char)((instruction[0] & 0x80) | ((instruction[3] >> 1) & 0x40) | ((instruction[0] & 0x60) >> 1))) >> 4);
		imm[1] = imm[0] = (imm[2] & 0x80) ? 0xFF : 0x00;;
		return true;
		break;
	case I_type:
		imm[3] = ((instruction[1] >> 4) | (instruction[0] << 4));
		imm[2] = (((char)instruction[0]) >> 4);
		imm[0] = imm[1] = (imm[2] & 0x80) ? 0xFF : 0x00;
		return true;
		break;
	case UJ_type:
		imm[0] = ((instruction[0] & 0x80) ? 0xFF : 0x00);
		imm[1] = (((char)((instruction[0] & 0x80) | ((instruction[1] & 0x0E) << 3))) >> 4);
		imm[2] = (((instruction[1] & 0x01) << 7) | ((instruction[2] & 0xF0) >> 1) | ((instruction[1] & 0x10) >> 2) | ((instruction[0] & 0x60) >> 5));
		imm[3] = (((instruction[0] &0x1F) << 3) | ((instruction[1] & 0xE0) >> 5));
		return true;
		break;
	case U_type:
		imm[0] = instruction[0];
		imm[1] = instruction[1];
		imm[2] = (instruction[2] & 0xF0);
		imm[3] = 0;
		return true;
		break;
	default:
		return false;
		break;
	}
}