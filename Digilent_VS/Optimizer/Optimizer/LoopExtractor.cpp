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

int optimize(RV32_Instruction* program, Loop loop, RV32_Instruction optimizationInstructions[6], int &opt_start, int &opt_end)
{
	OptimizableSequence opt[10];
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
	
	int i;

	for (i = loop.start_address; i < loop.branch_address && index < 10; i++)
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

	if (i - 1 != possibleStart && possibleStart >= 0)
	{
		opt[index].start_address = possibleStart;
		opt[index].end_address = i;
		index++;
	}

	if (index > 0)
	{
		sortSequences(opt, index);

		// Make dataflow graph here
		DataflowGraph graph;
		opt_start = opt[0].start_address;
		opt_end = opt[0].end_address;
		for (int i = opt[0].start_address; i < opt[0].end_address; i++)
		{
			unsigned char rs1, rs2, dest, oper;
			rs1 = program[i].source_register_first();
			rs2 = program[i].source_register_second();
			dest = program[i].destination_register();
			oper = ((program[i].funct3() & 0x07) | ((program[i].funct7() & 0x40) >> 3));

			graph.addNode(rs1, rs2, dest, oper);
		}

		// Complete dataflow graph
		for (int i = 0; i < graph.NoOfNodes(); i++)
		{
			if (graph.Node(i)->Generation() > 0)
			{
				DataflowNode* currentNode = graph.Node(i);
				// Check if it gets both source registers from parents
				if (!currentNode->Parent(1))
				{
					unsigned char source;
					if (currentNode->Parent(0)->Destination() == currentNode->Source1())
					{
						source = currentNode->Source2();
					}
					else
					{
						source = currentNode->Source1();
					}
					DataflowNode node(source, source, source, 15);
					graph.addNode(node, false);
					graph.Node(graph.NoOfNodes() - 1)->addChild(currentNode);
				}
			}
		}

		// Done dataflow

		// Try and create configuration instructions
		// As in really try, i have no idea if i'll manage
		// To call the computeWriteAddresses function and the computeSelection function

		unsigned char writeAddr[3] = { 0 };
		unsigned char *registerAddr = new unsigned char[6];
		for (int i = 0; i < 6; i++)
		{
			registerAddr[i] = 0;
		}
		ConfigurationSelection sel;
		//computeWriteAddresses(graph, writeAddr);

		computeSelections(graph, sel, registerAddr, writeAddr);

		unsigned char instr[6][4] = { 0 };
		// Make up instructions 
		 
		// Write addresses
		instr[0][0] = writeAddr[0] << 3;
		instr[1][0] = writeAddr[1] << 3;
		instr[2][0] = writeAddr[2] << 3;

		// Init selection
		instr[0][0] |= (sel.initSel[0][0] >> 1);
		instr[0][1] = (sel.initSel[0][0] << 7) | (sel.initSel[1][0] << 4) | (sel.initSel[2][0] << 1) | (sel.initSel[3][0] >> 2);
		instr[0][2] = (sel.initSel[3][0] << 6) | (sel.initSel[0][1] << 3) | (sel.initSel[1][1]);
		instr[0][3] = (sel.initSel[2][1] << 5) | (sel.initSel[3][1] << 2) | (unsigned char)2;

		// Route selection upper
		instr[1][0] = instr[1][0] | (sel.operandSel0[0][0] << 1) | (sel.operandSel0[0][1] >> 1);
		instr[1][1] = (sel.operandSel0[0][1] << 7) | (sel.operandSel0[0][2] << 5) | (sel.operandSel0[1][0] << 3) | (sel.operandSel0[1][1] << 1) | (sel.operandSel0[1][2] >> 1);
		instr[1][2] = (sel.operandSel0[1][2] << 7) | (sel.operandSel1[0][0] << 5) | (sel.operandSel1[0][1] << 3) | (sel.operandSel1[0][2] << 1) | (sel.operandSel1[1][0] >> 1);
		instr[1][3] = (sel.operandSel1[1][0] << 7) | (sel.operandSel1[1][1] << 5) | (sel.operandSel1[1][2] << 3) | ((sel.rezSel & 2) << 1) | 2;

		// Route selection lower
		instr[2][0] = instr[2][0] | (sel.operandSel0[2][0] << 1) | (sel.operandSel0[2][1] >> 1);
		instr[2][1] = (sel.operandSel0[2][1] << 7) | (sel.operandSel0[2][2] << 5) | (sel.operandSel0[3][0] << 3) | (sel.operandSel0[3][1] << 1) | (sel.operandSel0[3][2] >> 1);
		instr[2][2] = (sel.operandSel0[3][2] << 7) | (sel.operandSel1[2][0] << 5) | (sel.operandSel1[2][1] << 3) | (sel.operandSel1[2][2] << 1) | (sel.operandSel1[3][0] >> 1);
		instr[2][3] = (sel.operandSel1[3][0] << 7) | (sel.operandSel1[3][1] << 5) | (sel.operandSel1[3][2] << 3) | ((sel.rezSel & 1) << 2) | 2;

		// Bypass and operation selection upper
		instr[3][0] = sel.operationSel[0][0];
		instr[3][1] = (sel.operationSel[0][1] << 6) | (sel.operationSel[0][2] << 4) | (sel.operationSel[0][3] << 2) | (sel.operationSel[1][0]);
		instr[3][2] = (sel.operationSel[1][1] << 6) | (sel.operationSel[1][2] << 4) | (sel.operationSel[1][3] << 2) | (sel.bypass[0][0] << 1) | (sel.bypass[1][0]);
		instr[3][3] = (sel.bypass[0][1] << 7) | (sel.bypass[1][1] << 6) | (sel.bypass[0][2] << 5) | (sel.bypass[1][2] << 4) | (sel.bypass[0][3] << 3) | (sel.bypass[1][3] << 2) | 2;

		// Bypass and operation selection lower
		instr[4][0] = sel.operationSel[2][0];
		instr[4][1] = (sel.operationSel[2][1] << 6) | (sel.operationSel[2][2] << 4) | (sel.operationSel[2][3] << 2) | (sel.operationSel[3][0]);
		instr[4][2] = (sel.operationSel[3][1] << 6) | (sel.operationSel[3][2] << 4) | (sel.operationSel[3][3] << 2) | (sel.bypass[2][0] << 1) | (sel.bypass[3][0]);
		instr[4][3] = (sel.bypass[2][1] << 7) | (sel.bypass[3][1] << 6) | (sel.bypass[2][2] << 5) | (sel.bypass[3][2] << 4) | (sel.bypass[2][3] << 3) | (sel.bypass[3][3] << 2) | 2;

		// Start instruction
		instr[5][0] = (registerAddr[2] << 3) | ((registerAddr[3] >> 2) & 0x06) | (registerAddr[1] >> 4);
		instr[5][1] = (registerAddr[1] << 4) | (registerAddr[0] >> 1);
		instr[5][2] = (registerAddr[0] << 7) | ((registerAddr[3] & 0x07) << 4) | (registerAddr[4] >> 1);
		instr[5][3] = (registerAddr[4] << 7) | (registerAddr[5] << 2) | 1;

		for (int i = 0; i < 6; i++)
		{
			RV32_Instruction aux(instr[i]);
			optimizationInstructions[i] = aux;
		}


	}
	return 0;
}

int computeWriteAddresses(DataflowGraph& graph, unsigned char writeAddress[3])
{
	int k = 0;
	for (int i = 0; i < graph.NoOfNodes() && k < 3; i++)
	{
		if (graph.Node(i) && graph.Node(i)->NoOfChildren() == 0)
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

int computeSelections(DataflowGraph& graph, ConfigurationSelection& sel, unsigned char registerAddr[6], unsigned char writeAddr[3])
{
	// CLB map
	DataflowNode* generation[4][4] = { nullptr };

	int index[4] = { 0 };

	// Map the graph over the CLB
	for (int i = 0; i < graph.NoOfNodes(); i++)
	{
		if (graph.Node(i))
		{
			int gen = graph.Node(i)->Generation();
			if (gen < 4)
			{
				Operation opr = graph.Node(i)->Oper();
				// Mapping Shift/XOR operations over the fourth row
				// Working under the assumption that there is one shift operation per generation at most
				if (opr == SLL || opr == SRL || opr == SRA || opr == XOR)
				{
					generation[3][gen] = graph.Node(i);
					sel.bypass[3][gen] = 0;
				}

				// Mapping the other operations over the first three rows
				else if (index[gen] < 3)
				{
					generation[index[gen]][gen] = graph.Node(i);
					if (graph.Node(i)->Oper() != NONE)
						sel.bypass[index[gen]][gen] = 0;
					else
						sel.bypass[index[gen]][gen] = 1;
					index[gen]++;
				}
				else
				{
					// Too much mapping to be done that won't fit in the CHM
					// To find an alternative solution to exiting the function
					// Possibly ignoring the instructions that won't fit, just leaving them in the program
					return -1;
				}
			}
		}
	}

	int addrIndex = 0;

	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (generation[j][i])
			{
				int maxGen = generation[j][i]->Generation();
				for (int k = 0; k < generation[j][i]->NoOfChildren(); k++)
				{
					if (generation[j][i]->Child(k)->Generation() > maxGen)
					{
						maxGen = generation[j][i]->Child(k)->Generation();
					}
				}
				bool copy = true;
				if (!generation[j][i]->NoOfChildren() || (maxGen - generation[j][i]->Generation() > 1))
				{
					// Propagate the result until the end
					if (index[i + 1] < 3)
					{
						// Create a new node and add it to the graph, so there is no deallocation problem
						DataflowNode node(generation[j][i]->Destination(), generation[j][i]->Destination(), generation[j][i]->Destination(), 15);
						graph.addNode(node, false);
						generation[j][i]->addChild(graph.Node(graph.NoOfNodes() - 1), copy);
						generation[index[i + 1]][i + 1] = graph.Node(graph.NoOfNodes() - 1);
						sel.bypass[index[i + 1]][i + 1] = 1;
						index[i + 1] ++;
					}
					else if (!generation[3][i + 1])
					{
						// If there is no room to propagate it on the first 3 rows, do so on the fourth
						DataflowNode node(generation[j][i]->Destination(), generation[j][i]->Destination(), generation[j][i]->Destination(), 15);
						graph.addNode(node, false);
						generation[j][i]->addChild(graph.Node(graph.NoOfNodes() - 1), copy);
						sel.bypass[3][i + 1] = 1;
						generation[3][i + 1] = graph.Node(graph.NoOfNodes() - 1);
					}
					else
					{
						return -1;
					}
				}
			}
		}
	}

	// Fill in any unused cells
	DataflowNode empty(graph.Node(0)->Source1(), graph.Node(0)->Source1(), 0, 15);
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (!generation[j][i])
			{
				generation[j][i] = &empty;
				//sel.bypass[j][i - 1] = 1;
				sel.bypass[j][i] = 1;
			}
		}
	}

	// Create the source registers
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			if (generation[j][i])
			{
				unsigned char rs1, rs2;
				rs1 = generation[j][i]->Source1();
				rs2 = generation[j][i]->Source2();
				int k = 0;
				for (k = 0; k < addrIndex; k++)
				{
					if (registerAddr[k] == rs1)
						break;
				}
				if (k == addrIndex)
				{
					int t;
					bool ok = true;
					for (t = 0; t < i && ok; t++)
					{
						for (int p = 0; p < 4 && ok; p++)
						{
							if (generation[p][t] && generation[p][t]->Destination() == rs1)
							{
								ok = false;
							}
						}
					}
					if (ok)
					{
						registerAddr[addrIndex] = rs1;
						addrIndex++;
					}
				}

				for (k = 0; k < addrIndex; k++)
				{
					if (registerAddr[k] == rs2)
						break;
				}
				if (k == addrIndex)
				{
					int t;
					bool ok = true;
					for (t = 0; t < i && ok; t++)
					{
						for (int p = 0; p < 4 && ok; p++)
						{
							if (generation[p][t] && generation[p][t]->Destination() == rs2)
							{
								ok = false;
							}
						}
					}
					if (ok)
					{
						registerAddr[addrIndex] = rs2;
						addrIndex++;
					}
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
		}
	}


	// the other selection signals for operands
	for (int i = 1; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			//Check if there is a node mapped on the current location and if it is not a bypassed value from before
			if (generation[j][i] && generation[j][i]->Generation() == i)
			{
				for (int k = 0; k < 4; k++)
				{
					//Check if previous generation isn't null
					if (generation[k][i - 1])
					{
						//Check if previous generation is a parent
						if (generation[k][i - 1] == generation[j][i]->Parent(0))
						{
							sel.operandSel0[j][i - 1] = k;
						}
						if (generation[j][i]->Parent(1) && generation[k][i-1] == generation[j][i]->Parent(1))
						{
							sel.operandSel1[j][i - 1] = k;
						}
					}
				}
			}
			else
			{
				if (!generation[j][i])
				{
					sel.operandSel0[j][i - 1] = 0;
					sel.operandSel1[j][i - 1] = 0;
				}
				else
				{
					sel.operandSel0[j][i - 1] = j;
					sel.operandSel1[j][i - 1] = j;
				}
			}
		}
	}

	//Operation selection
	for (int i = 0; i < 4; i++)
	{
		// Operation selection for the first three rows (+, -, AND, OR)
		for (int j = 0; j < 3; j++)
		{
			if (generation[j][i])
			{
				switch (generation[j][i]->Oper())
				{
				case ADD: sel.operationSel[j][i] = 0; break;
				case SUB: sel.operationSel[j][i] = 1; break;
				case AND: sel.operationSel[j][i] = 2; break;
				case OR: sel.operationSel[j][i] = 3; break;
				default: 
					sel.operationSel[j][i] = 0;
					break;
				}
			}
		}

		// Operation selection for the fourth row (SLL, SRL, SRA, XOR)
		if (generation[3][i])
		{
			switch (generation[3][i]->Oper())
			{
			case SLL: sel.operationSel[3][i] = 0; break;
			case SRL: sel.operationSel[3][i] = 1; break;
			case SRA: sel.operationSel[3][i] = 2; break;
			case XOR: sel.operationSel[3][i] = 3; break;
			default:
				sel.operationSel[3][i] = 0;
				break;
			}
		}
	}

	int resultSel;
	sel.rezSel = 5;
	for (int i = 0; i < 3; i++)
	{
		writeAddr[i] = 0;
	}
	int wr_index = 0;
	for (resultSel = 0; resultSel < 4; resultSel++)
	{
		if (!generation[resultSel][3]->Destination())
		{
			if (sel.rezSel == 5)
			{
				sel.rezSel = resultSel;
			}
		}
		else
		{
			writeAddr[wr_index] = generation[resultSel][3]->Destination();
			wr_index++;
		}

	}

	return 0;
}