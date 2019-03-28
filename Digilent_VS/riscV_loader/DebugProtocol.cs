using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace riscV_loader
{
    class DebugProtocol
    {
        public const Byte CommandHandshakeStart = 0xA9;
        public const Byte CommandDisconnect = 0xFE;
        public const Byte CommandWriteInstructionMemory = 0x71;
        public const Byte CommandWriteInstructionMemoryContinue = 0x73;
        public const Byte CommandWriteInstructionMemoryAbort = 0x70;
        public const Byte CommandWriteDataMemory = 0x7E;
        public const Byte CommandSendPC = 0x8C;
        public const Byte CommandSendRegisters = 0x86;
        public const Byte CommandSendMemory = 0x83;
        public const Byte CommandSendTimeStamp = 0x81;
        public const Byte CommandStart = 0x99;
        public const Byte CommandPause = 0x9A;
        public const Byte CommandHalt = 0x9B;
        public const Byte CommandStep = 0x9D;

        public const Byte StatusHandshakeComplete = 0xA8;
        public const Byte StatusStepComplete = 0x91;
        public const Byte StatusRunComplete = 0x93;

        public const Byte AnswerHandshakeAccepted = 0xA0;
    }
}
