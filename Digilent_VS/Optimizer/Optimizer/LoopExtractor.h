#pragma once
#include "RV32_Instruction.h"

#define CHILDREN_LEN 10
#define GRAPH_SIZE 100

struct ConfigurationSelection
{
	unsigned char initSel[4][2];		// coresponds to the initSel bits
	unsigned char operationSel[4][4];	// corresponds to each operation selection on every cell
	unsigned char bypass[4][4];			// the bypass of each cell
	unsigned char operandSel0[4][3];	// the operand0 selection for columns 2->4
	unsigned char operandSel1[4][3];	// the operand1 selection for columns 2->4
	unsigned char rezSel;				// the result selection
};

//A structure representing a loop in the program
struct Loop
{
	int start_address, branch_address;
};

//A structure representing an optimizable sequence within a loop
//Identical as fields with the Loop structure, but with a different meaning for cleaner code
struct OptimizableSequence
{
	int start_address, end_address;
};

// the enum values are made from to the second MSB (bit 5) of the funct7 field and the funct3 field
enum Operation
{
	ADD = 0,
	SLL = 1,
	XOR = 4,
	SRL = 5,
	OR = 6,
	AND = 7,
	SUB = 8,
	SRA = 13,
	NONE = 15
};

class DataflowGraph;

class DataflowNode
{
private:
	// sources and destination
	unsigned char source1, source2, destination;

	// number of children of this node
	unsigned char noOfChildren;

	// the generation of this node 
	// generation 0 means no dependencies on previous instructions, 1 means it requires data from a previous instruction etc
	unsigned char generation;

	// the operation
	Operation oper;

	// the children of this node
	DataflowNode* children[CHILDREN_LEN] = { nullptr };

	// the parents of this node
	// 2 at most, 0 if generation is 0
	DataflowNode* parents[2];
	
public:
	// default constructor
	DataflowNode()
	{
		source1 = 0;
		source2 = 0;
		destination = 0;
		oper = NONE;
		generation = 0;

		noOfChildren = 0;
		for (int i = 0; i < CHILDREN_LEN; i++)
		{
			children[i] = nullptr;
		}
		parents[0] = parents[1] = nullptr;
	};

	// copy constructor
	DataflowNode(DataflowNode& node)
	{
		source1 = node.source1;
		source2 = node.source2;
		destination = node.destination;
		oper = node.oper;
		generation = node.generation;

		noOfChildren = node.noOfChildren;
		for (int i = 0; i < CHILDREN_LEN; i++)
		{
			children[i] = node.children[i];
		}
		for (int i = 0; i < 2; i++)
		{
			parents[i] = node.parents[i];
		}
	}

	// parameter constructor
	DataflowNode(unsigned char s1, unsigned char s2, unsigned char dest, unsigned char oper)
	{
		source1 = s1;
		source2 = s2;
		destination = dest;
		generation = 0;
		switch (oper)
		{
		case 0:	this->oper = ADD;	break;
		case 1: this->oper = SLL;	break;
		case 4: this->oper = XOR;   break;
		case 5: this->oper = SRL;   break;
		case 6:	this->oper = OR;    break;
		case 7:	this->oper = AND;	break;
		case 8:	this->oper = SUB;	break;
		case 13: this->oper = SRA;  break;

		default: this->oper = NONE; break;
		}

		noOfChildren = 0;
		for (int i = 0; i < CHILDREN_LEN; i++)
		{
			children[i] = nullptr;
		}
		parents[0] = parents[1] = nullptr;
	}

	// attribution operator overloading
	DataflowNode& operator=(DataflowNode& node)
	{
		source1 = node.source1;
		source2 = node.source2;
		destination = node.destination;
		generation = node.generation;
		oper = node.oper;

		noOfChildren = node.noOfChildren;
		for (int i = 0; i < CHILDREN_LEN; i++)
		{
			children[i] = node.children[i];
		}
		for (int i = 0; i < 2; i++)
		{
			parents[i] = node.parents[i];
		}
		return *this;
	}

	// equality operator overload
	int operator==(DataflowNode& node)
	{
		if (source1 != node.source1)
			return 0;
		if (source2 != node.source2)
			return 0;

		if (generation != node.generation)
			return 0;

		if (destination != node.destination)
			return 0;

		if (oper != node.oper)
			return 0;

		if (noOfChildren != node.noOfChildren)
			return 0;

		for (int i = 0; i < noOfChildren; i++)
		{
			if (children[i] != node.children[i])
				return 0;
		}

		for (int i = 0; i < 2; i++)
		{
			if (parents[i] != node.parents[i])
			{
				return 0;
			}
		}

		return 1;
	}

	// Adds a child to the node
	// On success, the return value is 0
	// On failure, the return value is negative
	int addChild(DataflowNode* node, bool copy = false)
	{
		if (node && noOfChildren < CHILDREN_LEN)
		{
			children[noOfChildren] = node;
			if (children[noOfChildren]->generation <= generation + 1)
			{
				children[noOfChildren]->generation = generation + 1;
			}
			noOfChildren++;
			if (!copy)
			{
				if (!node->parents[0])
				{
					node->parents[0] = this;
				}
				else
				{
					node->parents[1] = this;
				}
			}
			else
			{
				for (int i = 0; i < noOfChildren-1; i++)
				{
					node->children[i] = this->children[i];
					if (node->children[i]->parents[0] == this)
					{
						node->children[i]->parents[0] = node;
					}
					if (node->children[i]->parents[1] && node->children[i]->parents[1] == this)
					{
						node->children[i]->parents[1] = node;
					}
				}
				node->noOfChildren = noOfChildren-1;
				if (!node->parents[0])
				{
					node->parents[0] = this;
				}
				if (!node->parents[1])
				{
					node->parents[1] = this;
				}
			}
			return 0;
		}
		return -1;
	}
	
	//Getter functions//

	DataflowNode* Parent(int index)
	{
		if (index < 2)
		{
			return parents[index];
		}
		else
		{
			return nullptr;
		}
	}

	unsigned char Generation()
	{
		return generation;
	}

	Operation Oper()
	{
		return oper;
	}

	DataflowNode* Child(int index)
	{
		if (index < noOfChildren)
		{
			return children[index];
		}
		else
		{
			return nullptr;
		}
	}
	
	unsigned char Source1()
	{
		return source1;
	}

	unsigned char Source2()
	{
		return source2;
	}

	unsigned char Destination()
	{
		return destination;
	}

	unsigned char NoOfChildren()
	{
		return noOfChildren;
	}
};

class DataflowGraph
{
private:
	// contains the nodes of the graph
	DataflowNode nodes[GRAPH_SIZE];

	// the number of nodes currently in the graph
	int noOfNodes;

public:
	DataflowGraph()
	{
		noOfNodes = 0;
	};

	// adds a node to the graph and adds any children (if it is the case) automatically
	int addNode(DataflowNode& node, bool addChild = true)
	{
		if (noOfNodes < GRAPH_SIZE)
		{
			nodes[noOfNodes] = node;
			if (addChild)
			{
				bool RS1 = false;
				bool RS2 = false;
				for (int i = noOfNodes - 1; i >= 0 && (RS1 == false || RS2 == false); i--)
				{
					if (!RS1)
					{
						if (node.Source1() == nodes[i].Destination())
						{
							nodes[i].addChild(&nodes[noOfNodes]);
							RS1 = true;
						}
					}
					if (!RS2)
					{
						if (node.Source2() == nodes[i].Destination())
						{
							nodes[i].addChild(&nodes[noOfNodes]);
							RS2 = true;
						}
					}
				}
			}
			noOfNodes++;
			return 0;
		}
		return -1;
	};

	// adds a node to the graph and adds any children (if it is the case) automatically
	int addNode(unsigned char s1, unsigned char s2, unsigned char dest, unsigned char oper, bool addChild = true)
	{
		DataflowNode node(s1, s2, dest, oper);
		return addNode(node, addChild);
	};

	// Getter functions

	int NoOfNodes()
	{
		return noOfNodes;
	};

	DataflowNode* Node(int index)
	{
		if (index < noOfNodes)
		{
			return &nodes[index];
		}
		else
			return nullptr;
	};

	bool containsNode(DataflowNode& node)
	{
		for (int i = 0; i < noOfNodes; i++)
		{
			if (node == nodes[i])
			{
				return true;
			}
		}
		return false;
	}

};


// Extracts all loops from the program
// @program		: contains the instructions from which to extract the loops
// @n			: number of instructions
// @loops		: will contain all the loops found in the program
// @maxLoops	: maximum number of loops to be extracted
int extractLoops(RV32_Instruction program[], int n, Loop loops[], int maxLoops);

// sorts a vector of loops based on the number of instructions in each loop
void sortLoops(Loop* loops, int len);

// Extracts 3 write addresses from the graph
int computeWriteAddresses(DataflowGraph& graph, unsigned char writeAddress[3]);

// computes the selection signals for the CHM
// @graph			: the dataflow graph
// @sel				: will contain the selections to be used for creating the configuration instructions
// @registerAddr	: will contain the addresses of the source registers for creating the start instruction
// Returns 0 on success
int computeSelections(DataflowGraph& graph, ConfigurationSelection& sel, unsigned char registerAddr[6], unsigned char writeAddr[3]);

// the optimization function
// @program : the program to optimize
// @loop	: the loop to optimize
// @optimizationInstructions : will contain the instructions that will optimize the loop
//							   the first 5 are the configuration instructions
//							   the last one is the start instruction
// @start	: will contain the start of the sequence to be optimized (that won't be in the final program)
// @end		: will contain the end of the sequence to be optimized
// Returns 0 on succes
int optimize(RV32_Instruction* program, Loop loop, RV32_Instruction optimizationInstructions[6], int &start, int &end);

