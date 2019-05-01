/*
 * comm.h
 *
 *  Created on: 28 feb. 2019
 *      Author: Cristy
 */

#ifndef SRC_COMM_H_
#define SRC_COMM_H_

#include <stdint.h>

#define COMMAND__HANSHAKE_START (0xA9u)
#define COMMAND__DISCONNECT (0xFEu)
#define COMMAND__WRITE_INSTRUCTION_MEMORY (0x71u)
#define COMMAND__WRITE_INSTRUCTION_MEMORY_CONTINUE (0x73u)
#define COMMAND__WRITE_INSTRUCTION_MEMORY_ABORT (0x70u)
#define COMMAND__WRITE_DATA_MEMORY (0x7Eu)
#define COMMAND__GET_PC (0x8Cu)
#define COMMAND__GET_REGISTERS (0x86u)
#define COMMAND__GET_MEMORY (0x83u)
#define COMMAND__GET_ELAPSED_TIME (0x81u)
#define COMMAND__GET_CONFIGURATION (0x88u)
#define COMMAND__START (0x99u)
#define COMMAND__PAUSE (0x9Au)
#define COMMAND__HALT (0x9Bu)
#define COMMAND__STEP (0x9Du)

#define STATUS__HANDSHAKE_COMPLETE (0xA8u)
#define STATUS__STEP_COMPLETE (0x91u)
#define STATUS__RUN_COMPLETE (0x93u)

#define ANSWER__HANDSHAKE_ACCEPTED (0xA0u)

void waitConnection();
void sendStatus(uint8_t status);
void executeNextCommand();

#endif /* SRC_COMM_H_ */
