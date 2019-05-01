/*
 * comm.c
 *
 *  Created on: 28 feb. 2019
 *      Author: Cristy
 */

#include "comm.h"

#include "riscV.h"
#include "xparameters.h"
#include "xuartps_hw.h"

void waitConnection()
{
	uint8_t connected = 0;

	while (!connected)
	{
		uint8_t cmd = XUartPs_RecvByte(STDIN_BASEADDRESS);

		if (cmd != COMMAND__HANSHAKE_START)
		{
			continue;
		}

		XUartPs_SendByte(STDOUT_BASEADDRESS, ANSWER__HANDSHAKE_ACCEPTED);

		/* receiving handshake buffer */
		uint8_t checkSum = 0x00;
		for (int i = 0; i < 4; ++i)
		{
			checkSum += XUartPs_RecvByte(STDIN_BASEADDRESS) >> i;
		}

		XUartPs_SendByte(STDOUT_BASEADDRESS, checkSum);

		uint8_t status = XUartPs_RecvByte(STDIN_BASEADDRESS);

		if (status != STATUS__HANDSHAKE_COMPLETE)
		{
			continue;
		}

		XUartPs_SendByte(STDOUT_BASEADDRESS, STATUS__HANDSHAKE_COMPLETE);

		connected = 1;
	}
}

void sendStatus(uint8_t status)
{
	XUartPs_SendByte(STDOUT_BASEADDRESS, status);
}

void executeNextCommand()
{
	if (!XUartPs_IsReceiveData(STDIN_BASEADDRESS))
	{
		return;
	}

	uint8_t cmd = XUartPs_RecvByte(STDIN_BASEADDRESS);

	switch (cmd)
	{
		case COMMAND__DISCONNECT:
		{
			initRiscVCore();
			waitConnection(); // waits to be connected again
			break;
		}

		case COMMAND__WRITE_INSTRUCTION_MEMORY:
		{
			resetRiscVCore();

			uint16_t start_address = XUartPs_RecvByte(STDIN_BASEADDRESS) << 8;
			start_address |= XUartPs_RecvByte(STDIN_BASEADDRESS);

			uint16_t instr_count = XUartPs_RecvByte(STDIN_BASEADDRESS) << 8;
			instr_count |= XUartPs_RecvByte(STDIN_BASEADDRESS);

			if ((start_address + instr_count) > (INSTR_COUNT >> 2))
			{
				// trying to write outside of program memory
				for (;;);
			}

			for (int i = 0; i < instr_count; ++i)
			{
				cmd = XUartPs_RecvByte(STDIN_BASEADDRESS);

				if (cmd == COMMAND__WRITE_INSTRUCTION_MEMORY_CONTINUE)
				{
					uint8_t byte3 = XUartPs_RecvByte(STDIN_BASEADDRESS);
					uint8_t byte2 = XUartPs_RecvByte(STDIN_BASEADDRESS);
					uint8_t byte1 = XUartPs_RecvByte(STDIN_BASEADDRESS);
					uint8_t byte0 = XUartPs_RecvByte(STDIN_BASEADDRESS);

					uint8_t checkSum = byte3;
					checkSum += byte2 >> 1;
					checkSum += byte1 >> 2;
					checkSum += byte0 >> 3;

					uint32_t instruction = byte3 << 24;
					instruction |= byte2 << 16;
					instruction |= byte1 << 8;
					instruction |= byte0;

					writeInstructionMemory(start_address + i, instruction);

					XUartPs_SendByte(STDOUT_BASEADDRESS, checkSum);
				}
				else if (cmd == COMMAND__WRITE_INSTRUCTION_MEMORY_ABORT)
				{
					break;
				}
				else
				{
					// communication error
					for (;;);
				}
			}

			break;
		}

		case COMMAND__WRITE_DATA_MEMORY:
		{
			if (isPaused() == 0)
			{
				break; // cannon program the core while it is running
			}

			uint16_t start_address = XUartPs_RecvByte(STDIN_BASEADDRESS) << 8;
			start_address |= XUartPs_RecvByte(STDIN_BASEADDRESS);

			uint16_t byte_count = XUartPs_RecvByte(STDIN_BASEADDRESS) << 8;
			byte_count |= XUartPs_RecvByte(STDIN_BASEADDRESS);

			if ((start_address + byte_count) > DATA_COUNT)
			{
				// trying to write outside of data memory
				for (;;);
			}

			for (int i = 0; i < byte_count; ++i)
			{
				writeDataMemory(start_address + i, XUartPs_RecvByte(STDIN_BASEADDRESS));
			}

			break;
		}

		case COMMAND__GET_PC:
		{
			PC_t pc = getPC();

			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.IF >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.IF >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.IF >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.IF);

			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.ID >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.ID >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.ID >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.ID);

			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.EX >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.EX >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.EX >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.EX);

			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.MEM >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.MEM >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.MEM >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.MEM);

			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.WB >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.WB >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.WB >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, pc.WB);

			break;
		}

		case COMMAND__GET_REGISTERS:
		{
			for (int i = 1; i < 32; ++i)
			{
				XUartPs_SendByte(STDOUT_BASEADDRESS, REGISTERS[i] >> 24);
				XUartPs_SendByte(STDOUT_BASEADDRESS, REGISTERS[i] >> 16);
				XUartPs_SendByte(STDOUT_BASEADDRESS, REGISTERS[i] >> 8);
				XUartPs_SendByte(STDOUT_BASEADDRESS, REGISTERS[i]);
			}

			break;
		}

		case COMMAND__GET_MEMORY:
		{
			for (int i = 0; i < DATA_COUNT; ++i)
			{
				XUartPs_SendByte(STDOUT_BASEADDRESS, DATA_MEMORY[i]);
			}

			break;
		}

		case COMMAND__GET_ELAPSED_TIME:
		{
			uint64_t time = getTimeStamp();

			XUartPs_SendByte(STDOUT_BASEADDRESS, (time >> 31) >> 25);
			XUartPs_SendByte(STDOUT_BASEADDRESS, (time >> 31) >> 17);
			XUartPs_SendByte(STDOUT_BASEADDRESS, (time >> 31) >> 9);
			XUartPs_SendByte(STDOUT_BASEADDRESS, (time >> 31) >> 1);
			XUartPs_SendByte(STDOUT_BASEADDRESS, time >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, time >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, time >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, time);

			break;
		}

		case COMMAND__GET_CONFIGURATION:
		{
			conf_t conf = getConfiguration();

			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C1 >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C1 >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C1 >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C1);

			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C2 >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C2 >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C2 >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C2);

			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C3 >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C3 >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C3 >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C3);

			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C4 >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C4 >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C4 >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C4);

			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C5 >> 24);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C5 >> 16);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C5 >> 8);
			XUartPs_SendByte(STDOUT_BASEADDRESS, conf.C5);

			break;
		}

		case COMMAND__START:
		{
			runRiscVCore();

			break;
		}

		case COMMAND__PAUSE:
		{
			pauseRiscVCore();

			break;
		}

		case COMMAND__HALT:
		{
			resetRiscVCore();

			break;
		}

		case COMMAND__STEP:
		{
			stepRiscVCore();

			XUartPs_SendByte(STDOUT_BASEADDRESS, STATUS__STEP_COMPLETE);

			break;
		}
	}
}
