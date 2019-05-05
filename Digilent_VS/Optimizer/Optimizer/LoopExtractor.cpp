#include <stdio.h>
#include "LoopExtractor.h"

int extractLoops(RV32_Instruction program[], int n, Loop ret[], int maxLoops)
{
	int k = 0;
	char imm[4];
	for (int i = 0; i < n; i++)
	{
		if (program[i].opcode() == BRANCH_8)
		{
			if (program[i].immediate_field(imm) == true)
			{
				if (imm[0] < 0)
				{
					// Jump back in memory, so a loop is found
					int offset = 0;
					offset = ((int)imm[3] | ((((int)imm[2]) << 8) & 0xFF00))>>1;
					ret[k].branch_address = i;
					ret[k].start_address = i + offset;
					k++;
					if (k == maxLoops)
						break;
				}
			}
		}
	}
	return k;
}

int loopLength(Loop l)
{
	return l.branch_address - l.start_address;
}

void sortLoops(Loop* loops, int len)
{
	int i = 0;
	Loop aux = loops[0];

	for (i = 1; i < len; i++)
	{
		aux = loops[i];
		int j;
		for (j = i - 1; j >= 0 && loopLength(aux) > loopLength(loops[j]); j--)
		{
			loops[j + 1] = loops[j];
		}
		loops[j + 1] = aux;
	}
}

int seqLength(OptimizableSequence seq)
{
	return seq.end_address - seq.start_address;
}

void sortSequences(OptimizableSequence* seq, int len)
{
	int i = 0;
	OptimizableSequence aux = seq[0];

	for (i = 1; i < len; i++)
	{
		aux = seq[i];
		int j;
		for (j = i - 1; j >= 0 && seqLength(aux) > seqLength(seq[j]); j--)
		{
			seq[j + 1] = seq[j];
		}
		seq[j + 1] = aux;
	}
}

int optimize(RV32_Instruction* program, Loop loop)
{
	OptimizableSequence opt[100];
	int index = 0;

	int start = loop.start_address, end=loop.start_address;

	// find optimizable sequqnces (only R type instructions)
	int possibleStart;
	//Check if the first instruction is optimizable
	if (!(program[loop.start_address].opcode() == REGISTER_8 && program[start].funct3() != 2 && program[start].funct3() != 3))
	{
		possibleStart = -1;
	}
	else
	{
		possibleStart = start;
	}
	
	for (int i = loop.start_address; i < loop.branch_address && index < 100; i++)
	{
		if (!(program[i].opcode() == REGISTER_8 && program[i].funct3() != 2 && program[i].funct3() != 3))
		{
			//An unoptimizable instruction has been found

			//Save sequence if there is one
			if (possibleStart >= 0)
			{
				opt[index].start_address = possibleStart;
				opt[index].end_address = i;
				index++;
			}
			possibleStart = -1;
		}
		else
		{
			//REGISTER type instruction
			if (possibleStart < 0)
			{
				possibleStart = i;
			}
		}
	}

	if (index > 0)
	{
		sortSequences(opt, index);

		// Make dataflow graph here
		DataflowGraph graph;
		for (int i = opt[0].start_address; i < opt[0].end_address; i++)
		{
			unsigned char rs1, rs2, dest, oper;
			rs1 = program[i].source_register_first();
			rs2 = program[i].source_register_second();
			dest = program[i].destination_register();
			oper = ((program[i].funct3 & 0x07) | ((program[i].funct7 & 0x40) >> 3));

			graph.addNode(rs1, rs2, dest, oper);
		}

		// Done dataflow

		// Try and create configuration instructions
		// As in really try, i have no idea if i'll manage
		// To call the computeWriteAddresses function and the computeSelection function

	}
	return 0;
}

int computeWriteAddresses(DataflowGraph& graph, unsigned char writeAddress[3])
{
	int k = 0;
	for (int i = 0; i < graph.NoOfNodes && k < 3; i++)
	{
		if (graph.Node(i) && graph.Node(i)->NoOfChildren == 0)
		{
			//Nod terminal
			//Destinatia reprezinta writeAddress
			writeAddress[k] = graph.Node(i)->Destination();
			k++;
		}
	}
	if (k < 3)
	{
		for (int i = k; i < 3; i++)
		{
			writeAddress[i] = 0;
		}
	}
	return 0;
}

int computeSelections(DataflowGraph& graph, ConfigurationSelection& sel)
{
	// CLB map
	DataflowNode* generation[4][4];

	int index[4] = { 0 };

	// Map the graph over the CLB
	for (int i = 0; i < graph.NoOfNodes(); i++)
	{
		if (graph.Node(i))
		{
			int gen = graph.Node(i)->Generation();
			if (gen < 4 && index[gen] < 4)
			{
				if (index[gen] < 4)
				{
					generation[index[gen]][gen] = graph.Node(i);
					index[gen]++;
				}
				else
				{
					return -1;
				}
			}
		}
	}

	unsigned char registerAddr[6] = { 0 };
	int addrIndex = 0;

	// Fill in any unused cells
	for (int i = 0; i < 4; i++)
	{
		for (int j = index[i]; j < 4; i++)
		{
			generation[j][i] = nullptr;
		}
	}

	// Create the source registers
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (generation[i][j])
			{
				unsigned char rs1, rs2;
				rs1 = generation[i][j]->Source1();
				rs2 = generation[i][j]->Source2();
				int k = 0;
				for (k = 0; k < addrIndex; k++)
				{
					if (registerAddr[k] == rs1)
						break;
				}
				if (k == addrIndex)
				{
					registerAddr[addrIndex] = rs1;
				}

				for (k = 0; k < addrIndex; k++)
				{
					if (registerAddr[k] == rs2)
						break;
				}
				if (k == addrIndex)
				{
					registerAddr[addrIndex] = rs2;
				}
			}
		}
	}

	// init sel
	for (int i = 0; i < 4; i++)
	{
		if (generation[i][0])
		{
			unsigned char rs1 = generation[i][0]->Source1();
			unsigned char rs2 = generation[i][0]->Source2();
			int index;
			
			//RS1
			for (index = 0; index < addrIndex; index++)
			{
				if (rs1 == registerAddr[index])
				{
					break;
				}
			}
			if (index != addrIndex)
			{
				sel.initSel[i][0] = index;
			}

			//RS2
			for (index = 0; index < addrIndex; index++)
			{
				if (rs2 == registerAddr[index])
				{
					break;
				}
			}
			if (index != addrIndex)
			{
				sel.initSel[i][1] = index;
			}
		}
		else
		{
			sel.initSel[i][0] = sel.initSel[i][1] = 0;
			sel.bypass[i][0] = 1;
		}
	}


	// the other selection signals for operands
	for (int i = 1; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (generation[j][i])
			{
				for (int k = 0; k < 4; k++)
				{
					if (generation[k][0] == generation[j][i]->Parent(0))
					{
						sel.operandSel0[j][i - 1] = k;
					}
				}
			}
			else
			{
				sel.operandSel0[j][i - 1] = 0;
				sel.operandSel1[j][i - 1] = 0;
				sel.bypass[j][i] = 1;
			}
		}
	}
}