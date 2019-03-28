/*
 * riscV.h
 *
 *  Created on: 12 mar. 2019
 *      Author: Cristy
 */

#ifndef SRC_RISCV_H_
#define SRC_RISCV_H_

#include <stdint.h>

#define INSTR_BASEADDRESS (0x4A000000u)
#define DATA_BASEADDRESS (0x4A001000u)
#define REGS_BASEADDRESS (0x4A002000u)

#define INSTR_MEMORY ((volatile uint32_t*)INSTR_BASEADDRESS)
#define DATA_MEMORY ((volatile uint8_t*)DATA_BASEADDRESS)
#define REGISTERS ((volatile uint32_t*)REGS_BASEADDRESS)

#define CSR_OFFSET (0xFCu)

#define PC_IF_OFFSET (0xE0u)
#define PC_ID_OFFSET (0xE4u)
#define PC_EX_OFFSET (0xE8u)
#define PC_MEM_OFFSET (0xECu)
#define PC_WB_OFFSET (0xF0u)

#define TIMESTAMP_HI_OFFSET (0xF8u)
#define TIMESTAMP_LO_OFFSET (0xF4u)

#define CSR (*((volatile uint32_t*)(REGS_BASEADDRESS + CSR_OFFSET)))

#define PC_IF (*((volatile uint32_t*)(REGS_BASEADDRESS + PC_IF_OFFSET)))
#define PC_ID (*((volatile uint32_t*)(REGS_BASEADDRESS + PC_ID_OFFSET)))
#define PC_EX (*((volatile uint32_t*)(REGS_BASEADDRESS + PC_EX_OFFSET)))
#define PC_MEM (*((volatile uint32_t*)(REGS_BASEADDRESS + PC_MEM_OFFSET)))
#define PC_WB (*((volatile uint32_t*)(REGS_BASEADDRESS + PC_WB_OFFSET)))

#define TIMESTAMP_HI (*((volatile uint32_t*)(REGS_BASEADDRESS + TIMESTAMP_HI_OFFSET)))
#define TIMESTAMP_LO (*((volatile uint32_t*)(REGS_BASEADDRESS + TIMESTAMP_LO_OFFSET)))

#define INSTR_COUNT (1024)
#define DATA_COUNT (4096)
#define REGS_COUNT (32)

#define CSR_RESET (0x01u)
#define CSR_PAUSE (0x02u)
#define CSR_STEP (0x04u)

typedef struct _PC_t
{
	uint32_t IF;
	uint32_t ID;
	uint32_t EX;
	uint32_t MEM;
	uint32_t WB;
}PC_t;

void initRiscVCore();
void resetRiscVCore();
void runRiscVCore();
void pauseRiscVCore();
void stepRiscVCore();
uint8_t isPaused();
PC_t getPC();
uint64_t getTimeStamp();
void writeInstructionMemory(uint16_t address, uint32_t instr);
void writeDataMemory(uint16_t address, uint8_t data);
void pollRiscVStatus();

#endif /* SRC_RISCV_H_ */
