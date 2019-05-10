#include "options.h"

#pragma warning(disable:4996)

const char help[] = "-h";
const char def[] = "-d";

const char input[] = "-i";
const char output[] = "-o";

void printHelp()
{
	printf("\t\t-h - shows this text\n");
	printf("\t\t-i <input_file> - choose the file which contains the program to be optimized\n");
	printf("\t\t-o <output_file> - choose the file which will contain the optimized program\n");
	printf("\t\t-d - default to hardcoded input and output files (\"input.txt\" and \"optimized.txt\", respectively)\n");
	printf("\t\t-i <input_file> -o <output_file> - choose the input and output files\n");
}

int parseOptions(int argc, char** argv, FILE*& f, FILE*& g)
{
	if (argc == 1)
	{
		printf("No options given\nPossible options are:\n");
		printHelp();
		return -1;
	}
	else if (argc == 2)
	{
		if (strcmp(argv[1], help) == 0)
		{
			printHelp();
			return -1;
		}
		else if (strcmp(argv[1], def) == 0)
		{
			printf("Opened default files\n");
			f = fopen("input.txt", "r");
			if (!f)
			{
				printf("Couldn't open default input file \"input.txt\"\n");
				return -3;
			}
			g = fopen("optimized.txt", "w");
		}
	}
	else if (argc == 3)
	{
		if (strcmp(argv[1], input) == 0)
		{
			if (argv[2][0] == '-')
			{
				printf("Invalid name for the input file (it starts with '-')\n");
				return -2;
			}

			f = fopen(argv[2], "r");
			if (!f)
			{
				printf("Couldn't open input file\n");
				return -3;
			}
			g = fopen("optimized.txt", "w");
			printf("Opened default output file\n");
		}
		else if (strcmp(argv[1], output) == 0)
		{
			if (argv[2][0] == '-')
			{
				printf("Invalid name for the input file (it starts with '-')\n");
				return -2;
			}

			f = fopen("input.txt", "r");
			if (!f)
			{
				printf("Couldn't open input file\n");
				return -3;
			}
			printf("Opened default output file\n");
			g = fopen(argv[2], "w");
		}
		else
		{
			printf("Unrecognized option\n");
			printHelp();
			return -4;
		}
	}
	else if (argc == 5)
	{
		if (strcmp(argv[1], input) == 0 && strcmp(argv[3], output) == 0)
		{
			if (argv[2][0] == '-' || argv[4][0] == '-')
			{
				printf("Invalid name for the input or output file (it starts with '-')\n");
				return -2;
			}

			f = fopen(argv[2], "r");
			if (!f)
			{
				printf("Couldn't open input file\n");
				return -3;
			}
			g = fopen(argv[4], "w");
		}
		else if (strcmp(argv[1], output) == 0 && strcmp(argv[3], input) == 0)
		{
			if (argv[2][0] == '-' || argv[4][0] == '-')
			{
				printf("Invalid name for the input or output file (it starts with '-')\n");
				return -2;
			}

			f = fopen(argv[4], "r");
			if (!f)
			{
				printf("Couldn't open input file\n");
				return -3;
			}
			g = fopen(argv[2], "w");
		}
		else
		{
			printf("Unrecognized options\n");
			printHelp();
		}
	}
	return 0;

}