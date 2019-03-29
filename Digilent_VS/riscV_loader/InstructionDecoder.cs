using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace riscV_loader
{
    class InstructionDecoder
    {
        private enum InstructionType
        {
            Unknown,
            ControlStatus,
            RegisterRegisterArithmetic,
            RegisterImmediateArithmetic,
            LoadWord,
            StoreWord,
            ConditionalBranch
        }

        private const UInt32 MASK__OPCODE = 0x0000007F;
        private const UInt32 MASK__FUNC3 = 0x00007000;
        private const UInt32 MASK__FUNC7 = 0xFE000000;
        private const UInt32 MASK__RS1 = 0x000F8000;
        private const UInt32 MASK__RS2 = 0x01F00000;
        private const UInt32 MASK__RD = 0x00000F80;
        private const UInt32 MASK__SHAMT = 0x01F00000;
        private const UInt32 MASK__IMM_I = 0xFFF00000;
        private const UInt32 MASK__IMM_S1 = 0xFE000000;
        private const UInt32 MASK__IMM_S2 = 0x00000F80;
        private const UInt32 MASK__IMM_U = 0xFFFFF000;

        private const int SHIFT__FUNC3 = 12;
        private const int SHIFT__FUNC7 = 25;
        private const int SHIFT__RS1 = 15;
        private const int SHIFT__RS2 = 20;
        private const int SHIFT__RD = 7;
        private const int SHIFT__SHAMT = 20;
        private const int SHIFT__IMM_I = 20;
        private const int SHIFT__IMM_S1 = 18;
        private const int SHIFT__IMM_S2 = 7;
        private const UInt32 SHIFT__IMM_U = 12;

        private const UInt32 OPCODE__CSR = 0x00000073;
        private const UInt32 OPCODE__RRA = 0x00000033;
        private const UInt32 OPCODE__RIA = 0x00000013;
        private const UInt32 OPCODE__LW = 0x00000003;
        private const UInt32 OPCODE__SW = 0x00000023;
        private const UInt32 OPCODE__CB = 0x00000063;

        public static string DecodeInstruction(UInt32 opcode)
        {
            if (opcode == 0)
            {
                return "NOP";
            }

            InstructionType[] opcodes = new InstructionType[MASK__OPCODE + 1];
            for (int i = 0; i < opcodes.Length; ++i)
            {
                opcodes[i] = InstructionType.Unknown;
            }

            opcodes[OPCODE__CSR] = InstructionType.ControlStatus;
            opcodes[OPCODE__RRA] = InstructionType.RegisterRegisterArithmetic;
            opcodes[OPCODE__RIA] = InstructionType.RegisterImmediateArithmetic;
            opcodes[OPCODE__LW] = InstructionType.LoadWord;
            opcodes[OPCODE__SW] = InstructionType.StoreWord;
            opcodes[OPCODE__CB] = InstructionType.ConditionalBranch;

            
            InstructionType it = opcodes[opcode & MASK__OPCODE];

            switch (it)
            {
                case InstructionType.ControlStatus:
                {
                    string instruction = "";

                    if (((opcode & MASK__FUNC3) >> SHIFT__FUNC3) == 0b010)
                    {
                        instruction += "CSRR x" + ((opcode & MASK__RD) >> SHIFT__RD).ToString() + ", " + ((opcode & MASK__IMM_I) >> SHIFT__IMM_I).ToString();
                    }
                    else if (((opcode & MASK__FUNC3) >> SHIFT__FUNC3) == 0b001)
                    {
                        instruction += "CSRW " + ((opcode & MASK__IMM_I) >> SHIFT__IMM_I).ToString() + ", x" + ((opcode & MASK__RD) >> SHIFT__RD).ToString();
                    }
                    else
                    {
                        break;
                    }

                    return instruction;
                }

                case InstructionType.RegisterRegisterArithmetic:
                {
                    string instruction = "";

                    uint operation = ((opcode & MASK__FUNC3) >> SHIFT__FUNC3) | (((opcode & MASK__FUNC7) >> (SHIFT__FUNC7 - SHIFT__FUNC3)));
                    switch (operation)
                    {
                        case 0b0000000000:
                        {
                            instruction = "ADD ";

                            break;
                        }

                        case 0b0100000000:
                        {
                            instruction = "SUB ";

                            break;
                        }

                        case 0b0000000111:
                        {
                            instruction = "ADD ";

                            break;
                        }

                        case 0b0000000110:
                        {
                            instruction = "OR ";

                            break;
                        }

                        case 0b0000000100:
                        {
                            instruction = "XOR ";

                            break;
                        }

                        case 0b0000000010:
                        {
                            instruction = "SLT ";

                            break;
                        }

                        case 0b0000000011:
                        {
                            instruction = "SLTU ";

                            break;
                        }

                        case 0b0100000101:
                        {
                            instruction = "SRA ";

                            break;
                        }

                        case 0b0000000101:
                        {
                            instruction = "SRL ";

                            break;
                        }

                        case 0b0000000001:
                        {
                            instruction = "SLL ";

                            break;
                        }
                    }

                    if (String.IsNullOrEmpty(instruction))
                    {
                        break;
                    }

                    instruction += "x" + ((opcode & MASK__RD) >> SHIFT__RD).ToString() + ", ";
                    instruction += "x" + ((opcode & MASK__RS1) >> SHIFT__RS1).ToString() + ", ";
                    instruction += "x" + ((opcode & MASK__RS2) >> SHIFT__RS2).ToString();

                    return instruction;
                }

                case InstructionType.RegisterImmediateArithmetic:
                {
                    string[] operations = { "ADDI ", "SLLI ", "SLTI ", "SLTIU ", "XORI ", "", "ORI ", "ANDI " };
                    string instruction = operations[(opcode & MASK__FUNC3) >> SHIFT__FUNC3];

                    uint immediate = (opcode & MASK__IMM_I) >> SHIFT__IMM_I;

                    if (((opcode & MASK__FUNC3) >> SHIFT__FUNC3) == 5)
                    {
                        immediate &= 0x1F;

                        if ((opcode & 0x40000000) == 0)
                        {
                            instruction = "SRLI ";
                        }
                        else
                        {
                            instruction = "SRAI ";
                        }
                    }

                    instruction += "x" + ((opcode & MASK__RD) >> SHIFT__RD).ToString() + ", ";
                    instruction += "x" + ((opcode & MASK__RS1) >> SHIFT__RS1).ToString() + ", ";
                    instruction += immediate.ToString();

                    return instruction;
                }

                case InstructionType.LoadWord:
                {
                    if (((opcode & MASK__FUNC3) >> SHIFT__FUNC3) != 2)
                    {
                        break;
                    }

                    return "LW x" + ((opcode & MASK__RD) >> SHIFT__RD).ToString() + ", " + ((opcode & MASK__IMM_I) >> SHIFT__IMM_I).ToString() + "(x" + ((opcode & MASK__RS1) >> SHIFT__RS1).ToString() + ")";
                }

                case InstructionType.StoreWord:
                {
                    if (((opcode & MASK__FUNC3) >> SHIFT__FUNC3) != 2)
                    {
                        break;
                    }

                    return "SW " + ((opcode & MASK__IMM_I) >> SHIFT__IMM_I).ToString() + "(x" + ((opcode & MASK__RS1) >> SHIFT__RS1).ToString() + "), x" + ((opcode & MASK__RD) >> SHIFT__RD).ToString();
                }

                case InstructionType.ConditionalBranch:
                {
                    string[] condition = { "BEQ ", "BNE ", "", "", "BLT ", "BGE ", "BLTU ", "BGEU " };
                    string instruction = condition[(opcode & MASK__FUNC3) >> SHIFT__FUNC3];

                    if (String.IsNullOrEmpty(instruction))
                    {
                        break;
                    }

                    uint immediate = ((opcode & MASK__IMM_S1) >> SHIFT__IMM_S1) | ((opcode & MASK__IMM_S2) >> SHIFT__IMM_S2);

                    instruction += "x" + ((opcode & MASK__RS1) >> SHIFT__RS1).ToString() + ", ";
                    instruction += "x" + ((opcode & MASK__RS2) >> SHIFT__RS2).ToString() + ", ";
                    instruction += immediate.ToString();

                    return instruction;
                }

                default:
                {
                    return "unknown opcode";
                }
            }

            return "unknown opcode";
        }
    }
}
