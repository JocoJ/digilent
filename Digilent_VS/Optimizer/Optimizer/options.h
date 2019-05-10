#pragma once
#include <stdio.h>
#include <string>

// Prints the text associated with the help
void printHelp();

// Parses the command line arguments
// @argc - the argument count
// @argv - the arguments
// @input - will contain the pointer to the input FILE
//		  - it will be overwritten by the function
// @output - will contain the pointer to the output FILE
//		   - it will be overwritten by the function
// Returns 0 on succes
int parseOptions(int argc, char** argv, FILE*& input, FILE*& output);
