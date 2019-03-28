/*
 * riscV.c
 *
 *  Created on: 12 mar. 2019
 *      Author: Cristy
 */

#include "riscV.h"
#include "comm.h"

uint8_t checkRunning = 0;

void initRiscVCore()
{
	CSR = CSR_RESET;

	for (int i = 0; i < INSTR_COUNT; ++i)
	{
		INSTR_MEMORY[i] = 0x00000000;
	}

	for (int i = 0; i < DATA_COUNT; ++i)
	{
		DATA_MEMORY[i] = 0x00;
	}

	for (int i = 0; i < REGS_COUNT; ++i)
	{
		REGISTERS[i] = 0x00000000;
	}
}

void resetRiscVCore()
{
	CSR = CSR_RESET;

	for (int i = 0; i < DATA_COUNT; ++i)
	{
		DATA_MEMORY[i] = 0x00;
	}

	for (int i = 1; i < REGS_COUNT; ++i)
	{
		REGISTERS[i] = 0x00000000;
	}

	checkRunning = 0;
}

void runRiscVCore()
{
	checkRunning = 1;
	CSR = 0;
}

void pauseRiscVCore()
{
	CSR |= CSR_PAUSE;

	checkRunning = 0;
}

void stepRiscVCore()
{
	CSR = CSR_STEP;

	checkRunning = 0;

	while ((CSR & CSR_PAUSE) == 0);
}

uint8_t isPaused()
{
	return (CSR & CSR_PAUSE) ? 1 : 0;
}

PC_t getPC()
{
	PC_t pc;

	pc.IF = PC_IF;
	pc.ID = PC_ID;
	pc.EX = PC_EX;
	pc.MEM = PC_MEM;
	pc.WB = PC_WB;

	return pc;
}

uint64_t getTimeStamp()
{
	uint64_t timestamp = TIMESTAMP_HI << 31;
	timestamp <<= 1;
	timestamp |= TIMESTAMP_LO;

	return timestamp;
}

void writeInstructionMemory(uint16_t address, uint32_t instr)
{
	INSTR_MEMORY[address] = instr;
}

void writeDataMemory(uint16_t address, uint8_t data)
{
	DATA_MEMORY[address] = data;
}

void pollRiscVStatus()
{
	if (checkRunning)
	{
		if (CSR & CSR_PAUSE)
		{
			checkRunning = 0;
			sendStatus(STATUS__RUN_COMPLETE);
		}
	}
}
