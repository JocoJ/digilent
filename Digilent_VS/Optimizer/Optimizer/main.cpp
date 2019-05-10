#include <stdio.h>
#include <string>
#include "options.h"
#include "RV32_Instruction.h"
#include "LoopExtractor.h"
#include "Masks.h"

#pragma warning(disable:4996)

void hexConvert(unsigned char val[10], unsigned char ret[4])
{
	for (int i = 0; i < 8; i+=2)
	{
		if (val[i] >= '0' && val[i] <= '9')
		{
			ret[i / 2] = ((val[i] - '0') << 4);
		}
		else if (val[i] >= 'a' && val[i] <= 'f')
		{
			ret[i / 2] = ((val[i] - 'a' + 10) << 4);
		}
		else if (val[i] >= 'A' && val[i] <= 'F')
		{
			ret[i / 2] = ((val[i] - 'A' + 10) << 4);
		}

		if (val[i + 1] >= '0' && val[i + 1] <= '9')
		{
			ret[i / 2] = (ret[i/2] | ((val[i + 1] - '0') & 0x0F));
		}
		else if (val[i + 1] >= 'a' && val[i + 1] <= 'f')
		{
			ret[i / 2] = (ret[i / 2] | ((val[i+1] - 'a' + 10) & 0x0F));
		}
		else if (val[i + 1] >= 'A' && val[i + 1] <= 'F')
		{
			ret[i / 2] = (ret[i / 2] | ((val[i+1] - 'A' + 10) & 0x0F));
		}
	}
}

int main(int argc, char** argv)
{	
	FILE* f = NULL;
	FILE* g = NULL;

	if (parseOptions(argc, argv, f, g) != 0)
		return -1;

	unsigned char instr[10];
	RV32_Instruction* program = new RV32_Instruction[4096];
	int i = 0;
	while (fscanf(f, "%s\n", instr)>0)
	{
		unsigned char str[4];
		hexConvert(instr, str);
		RV32_Instruction aux(str);
		program[i] = aux;
		i++;
	}

	int programLen = i;

	int len;
	Loop l[10];
	len = extractLoops(program, i, l, 10);

	//sortLoops(l, len);

	RV32_Instruction conf[60];
	int start[10], end[10];

	for (int k = 0; k < len; k++)
	{
		printf("st: %d; end: %d\n", l[k].start_address, l[k].branch_address);
		optimize(program, l[k], conf+k*6, start[k], end[k]);
		printf("Sequence: st: %d; end: %d\n\n", start[k], end[k]);
		for (int i = 0; i < 6; i++)
		{
			printf("%02x%02x%02x%02x\n", conf[i + k * 6].Instruction(0), conf[i + k * 6].Instruction(1), conf[i + k * 6].Instruction(2), conf[i + k * 6].Instruction(3));
		}
		printf("\n");
	}

	int originalProgramIndex = 0;
	int optimizedSequenceIndex = 0;
	for (originalProgramIndex = 0; originalProgramIndex < programLen; originalProgramIndex++)
	{
		// Just before starting the loop
		// Write the conf instructions 
		if ((originalProgramIndex && (originalProgramIndex == l[optimizedSequenceIndex].start_address - 1)) || (!originalProgramIndex && originalProgramIndex == l[optimizedSequenceIndex].start_address))
		{
			for (int index = 0; index < 5; index++)
			{
				fprintf(g, "%02x%02x%02x%02x\n", conf[index + optimizedSequenceIndex * 6].Instruction(0), conf[index + optimizedSequenceIndex * 6].Instruction(1), conf[index + optimizedSequenceIndex * 6].Instruction(2), conf[index + optimizedSequenceIndex * 6].Instruction(3));
			}
		}
		else if (originalProgramIndex == start[optimizedSequenceIndex])
		{
			// in optimized sequence, write start and nop
			fprintf(g, "%02x%02x%02x%02x\n", conf[5 + optimizedSequenceIndex * 6].Instruction(0), conf[5 + optimizedSequenceIndex * 6].Instruction(1), conf[5 + optimizedSequenceIndex * 6].Instruction(2), conf[5 + optimizedSequenceIndex * 6].Instruction(3));
			fprintf(g, "00000000\n");

			unsigned char branch[4];
			int addr = l[optimizedSequenceIndex].branch_address;
			branch[3] = program[addr].opcode();
			char aux[4];
			program[addr].immediate_field(aux);
			int imm = ((int)aux[0] << 24) | ((int)aux[1] << 16) | ((int)aux[2] << 8) | ((int)aux[3]);
			imm = imm + ((end[optimizedSequenceIndex] - start[optimizedSequenceIndex])<<1) - 4;
			printf("Original branch: %02x%02x%02x%02x\n", program[addr].Instruction(0), program[addr].Instruction(1), program[addr].Instruction(2), program[addr].Instruction(3));
			program[addr].setImmField(imm);
			printf("Modified branch: %02x%02x%02x%02x\n", program[addr].Instruction(0), program[addr].Instruction(1), program[addr].Instruction(2), program[addr].Instruction(3));

			// Skip the sequence
			originalProgramIndex = end[optimizedSequenceIndex];

			// Go to the next sequence
			optimizedSequenceIndex++;
		}
		// write normal program
		fprintf(g, "%02x%02x%02x%02x\n", program[originalProgramIndex].Instruction(0), program[originalProgramIndex].Instruction(1), program[originalProgramIndex].Instruction(2), program[originalProgramIndex].Instruction(3));
	}


	fclose(f);
	fclose(g);
	return 0;
}