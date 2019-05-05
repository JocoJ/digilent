#include <stdio.h>
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
	FILE* f = fopen("Text.txt", "r");

	unsigned char instr[10];
	RV32_Instruction program[4096];
	int i = 0;
	while (fscanf(f, "%s\n", instr)>0)
	{
		unsigned char str[4];
		hexConvert(instr, str);
		RV32_Instruction aux(str);
		program[i] = aux;
		i++;
	}

	int len;
	Loop l[100];
	len = extractLoops(program, i, l, 100);

	sortLoops(l, len);


	for (int k = 0; k < len; k++)
	{
		printf("st: %d; end: %d\n", l[k].start_address, l[k].branch_address);
		printf("Sequences: \n");
		optimize(program, l[k]);
		printf("\n");
	}

	return 0;
}