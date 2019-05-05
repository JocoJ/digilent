#pragma once
#define OPCODE_32	0x0000007F
#define RD_32		0x00000F80
#define FUNCT3_32	0x00007000
#define RS1_32		0x000F8000
#define RS2_32		0x01F00000
#define FUNCT7_32	0xFE000000

#define BRANCH_32	0x00000063

#define OPCODE_8	0x7F
#define RD_8		0x1F
#define FUNCT3_8	0x7
#define RS1_8		0x1F
#define RS2_8		0x1F
#define FUNCT7_8	0x7F

#define BRANCH_8	0x63
#define LUI_8		0x37
#define AUIPC_8		0x17
#define JAL_8		0x6F
#define JALR_8		0x67
#define LOAD_8		0x03
#define STORE_8		0x23
#define IMMEDIATE_8 0x13
#define REGISTER_8	0x33
