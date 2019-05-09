using Microsoft.VisualBasic;
using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.IO.Ports;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace riscV_loader
{
    /// <summary>
    /// Interaction logic for WindowMain.xaml
    /// </summary>
    public partial class WindowMain : Window
    {
        private enum ThreadCommands
        {
            WriteProgramMemory,
            WriteDataMemory,
            GetPC,
            GetRegisters,
            GetMemory,
            GetTimeStamp,
            GetConfuguration,
            ProgramStart,
            ProgramPause,
            ProgramHalt,
            ProgramStep
        }

        private enum CoreStatus
        {
            Disconnected,
            Halted,
            Paused,
            Running
        }

        private class SerialData
        {
            public string Port { get; set; }
            public int Baudrate { get; set; }
        }

        private class ProgramViewItem
        {
            public string cursor { get; set; }
            public string programCounter { get; set; }
            public string opCode { get; set; }
            public string instruction { get; set; }
        }

        private class MemoryViewItem
        {
            public string addressHI { get; set; }
            public string data0 { get; set; }
            public string data1 { get; set; }
            public string data2 { get; set; }
            public string data3 { get; set; }
            public string data4 { get; set; }
            public string data5 { get; set; }
            public string data6 { get; set; }
            public string data7 { get; set; }
            public string data8 { get; set; }
            public string data9 { get; set; }
            public string dataA { get; set; }
            public string dataB { get; set; }
            public string dataC { get; set; }
            public string dataD { get; set; }
            public string dataE { get; set; }
            public string dataF { get; set; }
        }

        CoreStatus coreStatus = CoreStatus.Disconnected;

        Int32[] PC = new Int32[5];
        UInt32[] registers = new UInt32[32];
        UInt32[] configurationRegs = new UInt32[5];
        ObservableCollection<ProgramViewItem> programViewCollection = new ObservableCollection<ProgramViewItem>();
        ObservableCollection<MemoryViewItem> memoryViewCollection = new ObservableCollection<MemoryViewItem>();

        UInt16 startAddress;
        Byte[] programBytes;
        Byte[] dataBytes;

        private static Thread sm_serialThread = null;
        private static bool sm_serialThreadShutDown = false;

        private Queue<ThreadCommands> threadCommandQueue = new Queue<ThreadCommands>();

        public WindowMain()
        {
            InitializeComponent();

            ((DataGridTextColumn)dataGridProgramView.Columns[0]).Binding = new Binding("cursor");
            ((DataGridTextColumn)dataGridProgramView.Columns[1]).Binding = new Binding("programCounter");
            ((DataGridTextColumn)dataGridProgramView.Columns[2]).Binding = new Binding("opCode");
            ((DataGridTextColumn)dataGridProgramView.Columns[3]).Binding = new Binding("instruction");
            dataGridProgramView.AutoGenerateColumns = false;
            dataGridProgramView.DataContext = programViewCollection;

            ((DataGridTextColumn)DataGridMemoryView.Columns[0]).Binding = new Binding("addressHI");
            ((DataGridTextColumn)DataGridMemoryView.Columns[1]).Binding = new Binding("data0");
            ((DataGridTextColumn)DataGridMemoryView.Columns[2]).Binding = new Binding("data1");
            ((DataGridTextColumn)DataGridMemoryView.Columns[3]).Binding = new Binding("data2");
            ((DataGridTextColumn)DataGridMemoryView.Columns[4]).Binding = new Binding("data3");
            ((DataGridTextColumn)DataGridMemoryView.Columns[5]).Binding = new Binding("data4");
            ((DataGridTextColumn)DataGridMemoryView.Columns[6]).Binding = new Binding("data5");
            ((DataGridTextColumn)DataGridMemoryView.Columns[7]).Binding = new Binding("data6");
            ((DataGridTextColumn)DataGridMemoryView.Columns[8]).Binding = new Binding("data7");
            ((DataGridTextColumn)DataGridMemoryView.Columns[9]).Binding = new Binding("data8");
            ((DataGridTextColumn)DataGridMemoryView.Columns[10]).Binding = new Binding("data9");
            ((DataGridTextColumn)DataGridMemoryView.Columns[11]).Binding = new Binding("dataA");
            ((DataGridTextColumn)DataGridMemoryView.Columns[12]).Binding = new Binding("dataB");
            ((DataGridTextColumn)DataGridMemoryView.Columns[13]).Binding = new Binding("dataC");
            ((DataGridTextColumn)DataGridMemoryView.Columns[14]).Binding = new Binding("dataD");
            ((DataGridTextColumn)DataGridMemoryView.Columns[15]).Binding = new Binding("dataE");
            ((DataGridTextColumn)DataGridMemoryView.Columns[16]).Binding = new Binding("dataF");
            DataGridMemoryView.AutoGenerateColumns = false;
            DataGridMemoryView.DataContext = memoryViewCollection;

            SetCHMVisibility(false);
        }

        private void ProgramViewCollection_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            int index = e.NewStartingIndex;
            MessageBox.Show(programViewCollection[index].programCounter.ToString() + " " + programViewCollection[index].opCode.ToString());
        }

        private void WindowMain_Loaded(object sender, RoutedEventArgs e)
        {
            UpdateUI();

            SetUpdateStatus("UI loaded", true);
            SetProgress(false);
        }

        private void WindowMain_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (sm_serialThread != null)
            {
                lock (sm_serialThread)
                {
                    sm_serialThreadShutDown = true;
                }

                sm_serialThread.Join();
            }
        }

        private delegate void UpdateRegistersDelegate();
        private void UpdateRegisterView()
        {
            textBoxRegisterR1.Text = "0x" + registers[1].ToString("X8");
            textBoxRegisterR2.Text = "0x" + registers[2].ToString("X8");
            textBoxRegisterR3.Text = "0x" + registers[3].ToString("X8");
            textBoxRegisterR4.Text = "0x" + registers[4].ToString("X8");
            textBoxRegisterR5.Text = "0x" + registers[5].ToString("X8");
            textBoxRegisterR6.Text = "0x" + registers[6].ToString("X8");
            textBoxRegisterR7.Text = "0x" + registers[7].ToString("X8");
            textBoxRegisterR8.Text = "0x" + registers[8].ToString("X8");
            textBoxRegisterR9.Text = "0x" + registers[9].ToString("X8");
            textBoxRegisterR10.Text = "0x" + registers[10].ToString("X8");
            textBoxRegisterR11.Text = "0x" + registers[11].ToString("X8");
            textBoxRegisterR12.Text = "0x" + registers[12].ToString("X8");
            textBoxRegisterR13.Text = "0x" + registers[13].ToString("X8");
            textBoxRegisterR14.Text = "0x" + registers[14].ToString("X8");
            textBoxRegisterR15.Text = "0x" + registers[15].ToString("X8");
            textBoxRegisterR16.Text = "0x" + registers[16].ToString("X8");
            textBoxRegisterR17.Text = "0x" + registers[17].ToString("X8");
            textBoxRegisterR18.Text = "0x" + registers[18].ToString("X8");
            textBoxRegisterR19.Text = "0x" + registers[19].ToString("X8");
            textBoxRegisterR20.Text = "0x" + registers[20].ToString("X8");
            textBoxRegisterR21.Text = "0x" + registers[21].ToString("X8");
            textBoxRegisterR22.Text = "0x" + registers[22].ToString("X8");
            textBoxRegisterR23.Text = "0x" + registers[23].ToString("X8");
            textBoxRegisterR24.Text = "0x" + registers[24].ToString("X8");
            textBoxRegisterR25.Text = "0x" + registers[25].ToString("X8");
            textBoxRegisterR26.Text = "0x" + registers[26].ToString("X8");
            textBoxRegisterR27.Text = "0x" + registers[27].ToString("X8");
            textBoxRegisterR28.Text = "0x" + registers[28].ToString("X8");
            textBoxRegisterR29.Text = "0x" + registers[29].ToString("X8");
            textBoxRegisterR30.Text = "0x" + registers[30].ToString("X8");
            textBoxRegisterR31.Text = "0x" + registers[31].ToString("X8");
        }

        private delegate void UpdatePCDelegate();
        private void UpdatePC()
        {
            for (int i = 0; i < programViewCollection.Count; ++i)
            {
                programViewCollection[i].cursor = "";
            }

            string[] pipelinePC = { "IF", "ID", "EX", "MEM", "WB" };

            for (int i = 4; i >= 0; --i)
            {
                if (PC[i] < 0)
                {
                    continue;
                }

                int index = PC[i] >> 2;

                if (index >= programViewCollection.Count)
                {
                    MessageBox.Show("PC went outside of program memory", "", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                programViewCollection[(int)index].cursor = pipelinePC[i];
            }

            dataGridProgramView.Items.Refresh();
        }

        private delegate void UpdateProgramViewDelegate(int instruction_count);
        private void UpdateProgramView(int instruction_count)
        {
            for (int i = 0; i < instruction_count; ++i)
            {
                UInt32 instr = 0;
                for (int j = 0; j < 4; ++j)
                {
                    instr |= (UInt32)(programBytes[i * 4 + j] << ((3 - j) * 8));
                }

                string s = "0x" + instr.ToString("X8");

                programViewCollection[i].opCode = s;
                programViewCollection[i].cursor = "";
                programViewCollection[i].instruction = InstructionDecoder.DecodeInstruction(instr);
            }

            dataGridProgramView.Items.Refresh();
        }

        private delegate void UpdateMemoryViewDelegate();
        private void UpdateMemoryView()
        {
            for (int i = 0; i < dataBytes.Length; ++i)
            {
                int address = startAddress + i;
                int index = address >> 4;

                switch (address & 0xF)
                {
                    case 0x0:
                    {
                        memoryViewCollection[index].data0 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x1:
                    {
                        memoryViewCollection[index].data1 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x2:
                    {
                        memoryViewCollection[index].data2 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x3:
                    {
                        memoryViewCollection[index].data3 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x4:
                    {
                        memoryViewCollection[index].data4 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x5:
                    {
                        memoryViewCollection[index].data5 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x6:
                    {
                        memoryViewCollection[index].data6 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x7:
                    {
                        memoryViewCollection[index].data7 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x8:
                    {
                        memoryViewCollection[index].data8 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0x9:
                    {
                        memoryViewCollection[index].data9 = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0xA:
                    {
                        memoryViewCollection[index].dataA = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0xB:
                    {
                        memoryViewCollection[index].dataB = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0xC:
                    {
                        memoryViewCollection[index].dataC = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0xD:
                    {
                        memoryViewCollection[index].dataD = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0xE:
                    {
                        memoryViewCollection[index].dataE = dataBytes[i].ToString("X2");

                        break;
                    }

                    case 0xF:
                    {
                        memoryViewCollection[index].dataF = dataBytes[i].ToString("X2");

                        break;
                    }
                }
            }

            DataGridMemoryView.Items.Refresh();
        }

        private delegate void ShowElapsedTimeDelegate(UInt64 elapsed);
        private void ShowElapsedTime(UInt64 elapsed)
        {
            MessageBox.Show("Run complete!\nExecution took " + elapsed.ToString() + " cycles", "", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void SetCHMVisibility(bool visible)
        {
            canvasCHM.Visibility = visible ? Visibility.Visible : Visibility.Hidden;
        }

        private delegate void UpdateCHMViewDelegate();
        private void UpdateCHMView()
        {
            uint i00 = (configurationRegs[0] >> 21) & 0x7;
            uint i10 = (configurationRegs[0] >> 18) & 0x7;
            uint i20 = (configurationRegs[0] >> 15) & 0x7;
            uint i30 = (configurationRegs[0] >> 12) & 0x7;

            uint i01 = (configurationRegs[0] >> 9) & 0x7;
            uint i11 = (configurationRegs[0] >> 6) & 0x7;
            uint i21 = (configurationRegs[0] >> 3) & 0x7;
            uint i31 = (configurationRegs[0] >> 0) & 0x7;

            textBoxInput00.Text = "in" + i00.ToString();
            textBoxInput10.Text = "in" + i10.ToString();
            textBoxInput20.Text = "in" + i20.ToString();
            textBoxInput30.Text = "in" + i30.ToString();

            textBoxInput01.Text = "in" + i01.ToString();
            textBoxInput11.Text = "in" + i11.ToString();
            textBoxInput21.Text = "in" + i21.ToString();
            textBoxInput31.Text = "in" + i31.ToString();

            double[] yIndexes = { 110, 300, 490, 680 };

            uint sel01i0 = (configurationRegs[1] >> 23) & 0x3;
            uint sel02i0 = (configurationRegs[1] >> 21) & 0x3;
            uint sel03i0 = (configurationRegs[1] >> 19) & 0x3;

            uint sel11i0 = (configurationRegs[1] >> 17) & 0x3;
            uint sel12i0 = (configurationRegs[1] >> 15) & 0x3;
            uint sel13i0 = (configurationRegs[1] >> 13) & 0x3;

            uint sel01i1 = (configurationRegs[1] >> 11) & 0x3;
            uint sel02i1 = (configurationRegs[1] >> 9) & 0x3;
            uint sel03i1 = (configurationRegs[1] >> 7) & 0x3;

            uint sel11i1 = (configurationRegs[1] >> 5) & 0x3;
            uint sel12i1 = (configurationRegs[1] >> 3) & 0x3;
            uint sel13i1 = (configurationRegs[1] >> 1) & 0x3;

            uint sel21i0 = (configurationRegs[2] >> 23) & 0x3;
            uint sel22i0 = (configurationRegs[2] >> 21) & 0x3;
            uint sel23i0 = (configurationRegs[2] >> 19) & 0x3;

            uint sel31i0 = (configurationRegs[2] >> 17) & 0x3;
            uint sel32i0 = (configurationRegs[2] >> 15) & 0x3;
            uint sel33i0 = (configurationRegs[2] >> 13) & 0x3;

            uint sel21i1 = (configurationRegs[2] >> 11) & 0x3;
            uint sel22i1 = (configurationRegs[2] >> 9) & 0x3;
            uint sel23i1 = (configurationRegs[2] >> 7) & 0x3;

            uint sel31i1 = (configurationRegs[2] >> 5) & 0x3;
            uint sel32i1 = (configurationRegs[2] >> 3) & 0x3;
            uint sel33i1 = (configurationRegs[2] >> 1) & 0x3;

            linePath01i0.Y1 = yIndexes[sel01i0];
            linePath02i0.Y1 = yIndexes[sel02i0];
            linePath03i0.Y1 = yIndexes[sel03i0];

            linePath11i0.Y1 = yIndexes[sel11i0];
            linePath12i0.Y1 = yIndexes[sel12i0];
            linePath13i0.Y1 = yIndexes[sel13i0];

            linePath01i1.Y1 = yIndexes[sel01i1];
            linePath02i1.Y1 = yIndexes[sel02i1];
            linePath03i1.Y1 = yIndexes[sel03i1];

            linePath11i1.Y1 = yIndexes[sel11i1];
            linePath12i1.Y1 = yIndexes[sel12i1];
            linePath13i1.Y1 = yIndexes[sel13i1];

            linePath21i0.Y1 = yIndexes[sel21i0];
            linePath22i0.Y1 = yIndexes[sel22i0];
            linePath23i0.Y1 = yIndexes[sel23i0];

            linePath31i0.Y1 = yIndexes[sel31i0];
            linePath32i0.Y1 = yIndexes[sel32i0];
            linePath33i0.Y1 = yIndexes[sel33i0];

            linePath21i1.Y1 = yIndexes[sel21i1];
            linePath22i1.Y1 = yIndexes[sel22i1];
            linePath23i1.Y1 = yIndexes[sel23i1];

            linePath31i1.Y1 = yIndexes[sel31i1];
            linePath32i1.Y1 = yIndexes[sel32i1];
            linePath33i1.Y1 = yIndexes[sel33i1];

            string[] ops0_1 = { "ADD", "SUB", "AND", "OR" };
            string[] ops2 = { "ADD", "SUB", "NAND", "NOR" };
            string[] ops3 = { "SLL", "SRL", "SRA", "XOR" };

            uint op00 = (configurationRegs[3] >> 22) & 0x3;
            uint op01 = (configurationRegs[3] >> 20) & 0x3;
            uint op02 = (configurationRegs[3] >> 18) & 0x3;
            uint op03 = (configurationRegs[3] >> 16) & 0x3;

            uint op10 = (configurationRegs[3] >> 14) & 0x3;
            uint op11 = (configurationRegs[3] >> 12) & 0x3;
            uint op12 = (configurationRegs[3] >> 10) & 0x3;
            uint op13 = (configurationRegs[3] >> 8) & 0x3;

            uint op20 = (configurationRegs[4] >> 22) & 0x3;
            uint op21 = (configurationRegs[4] >> 20) & 0x3;
            uint op22 = (configurationRegs[4] >> 18) & 0x3;
            uint op23 = (configurationRegs[4] >> 16) & 0x3;

            uint op30 = (configurationRegs[4] >> 14) & 0x3;
            uint op31 = (configurationRegs[4] >> 12) & 0x3;
            uint op32 = (configurationRegs[4] >> 10) & 0x3;
            uint op33 = (configurationRegs[4] >> 8) & 0x3;

            uint by00 = (configurationRegs[3] >> 7) & 0x1;
            uint by10 = (configurationRegs[3] >> 6) & 0x1;

            uint by01 = (configurationRegs[3] >> 5) & 0x1;
            uint by11 = (configurationRegs[3] >> 4) & 0x1;

            uint by02 = (configurationRegs[3] >> 3) & 0x1;
            uint by12 = (configurationRegs[3] >> 2) & 0x1;

            uint by03 = (configurationRegs[3] >> 1) & 0x1;
            uint by13 = (configurationRegs[3] >> 0) & 0x1;

            uint by20 = (configurationRegs[4] >> 7) & 0x1;
            uint by30 = (configurationRegs[4] >> 6) & 0x1;

            uint by21 = (configurationRegs[4] >> 5) & 0x1;
            uint by31 = (configurationRegs[4] >> 4) & 0x1;

            uint by22 = (configurationRegs[4] >> 3) & 0x1;
            uint by32 = (configurationRegs[4] >> 2) & 0x1;

            uint by23 = (configurationRegs[4] >> 1) & 0x1;
            uint by33 = (configurationRegs[4] >> 0) & 0x1;

            textBlockOp00.Text = (by00 == 0) ? ops0_1[op00] : "";
            textBlockOp01.Text = (by01 == 0) ? ops0_1[op01] : "";
            textBlockOp02.Text = (by02 == 0) ? ops0_1[op02] : "";
            textBlockOp03.Text = (by03 == 0) ? ops0_1[op03] : "";

            textBlockOp10.Text = (by10 == 0) ? ops0_1[op10] : "";
            textBlockOp11.Text = (by11 == 0) ? ops0_1[op11] : "";
            textBlockOp12.Text = (by12 == 0) ? ops0_1[op12] : "";
            textBlockOp13.Text = (by13 == 0) ? ops0_1[op13] : "";

            textBlockOp20.Text = (by20 == 0) ? ops2[op20] : "";
            textBlockOp21.Text = (by21 == 0) ? ops2[op21] : "";
            textBlockOp22.Text = (by22 == 0) ? ops2[op22] : "";
            textBlockOp23.Text = (by23 == 0) ? ops2[op23] : "";

            textBlockOp30.Text = (by30 == 0) ? ops3[op30] : "";
            textBlockOp31.Text = (by31 == 0) ? ops3[op31] : "";
            textBlockOp32.Text = (by32 == 0) ? ops3[op32] : "";
            textBlockOp33.Text = (by33 == 0) ? ops3[op33] : "";

            uint[] outs = new uint[3];
            outs[0] = (configurationRegs[0] >> 25) & 0x1F;
            outs[1] = (configurationRegs[1] >> 25) & 0x1F;
            outs[2] = (configurationRegs[2] >> 25) & 0x1F;

            uint oSel = 0;
            if ((configurationRegs[1] & 0x1) == 0x1)
            {
                oSel |= 0x1;
            }
            if ((configurationRegs[2] & 0x1) == 0x1)
            {
                oSel |= 0x2;
            }

            if (oSel == 0)
            {
                textBoxOutput0.Text = "";
                textBoxOutput1.Text = "X" + outs[0].ToString();
                textBoxOutput2.Text = "X" + outs[1].ToString();
                textBoxOutput3.Text = "X" + outs[2].ToString();
            }
            else if (oSel == 1)
            {
                textBoxOutput0.Text = "X" + outs[0].ToString();
                textBoxOutput1.Text = "";
                textBoxOutput2.Text = "X" + outs[1].ToString();
                textBoxOutput3.Text = "X" + outs[2].ToString();
            }
            else if (oSel == 2)
            {
                textBoxOutput0.Text = "X" + outs[0].ToString();
                textBoxOutput1.Text = "X" + outs[1].ToString();
                textBoxOutput2.Text = "";
                textBoxOutput3.Text = "X" + outs[2].ToString();
            }
            else
            {
                textBoxOutput0.Text = "X" + outs[0].ToString();
                textBoxOutput1.Text = "X" + outs[1].ToString();
                textBoxOutput2.Text = "X" + outs[2].ToString();
                textBoxOutput3.Text = "";
            }
        }

        private delegate void InitDataViewsDelegate();
        private void InitDataViews()
        {
            for (int i = 0; i < 1024; ++i)
            {
                programViewCollection.Add(new ProgramViewItem() { cursor = "", programCounter = (i * 4).ToString(), opCode = "0x00000000", instruction = "NOP" });
            }

            for (int i = 0; i < 256; ++i)
            {
                memoryViewCollection.Add(new MemoryViewItem() { addressHI = "0x" + (i * 16).ToString("X3"), data0 = "00", data1 = "00", data2 = "00", data3 = "00", data4 = "00", data5 = "00", data6 = "00", data7 = "00", data8 = "00", data9 = "00", dataA = "00", dataB = "00", dataC = "00", dataD = "00", dataE = "00", dataF = "00", });
            }

            for (int i = 0; i < 32; ++i)
            {
                registers[i] = 0;
            }

            UpdateRegisterView();
        }

        private void ClearDataViews()
        {
            programViewCollection.Clear();
            memoryViewCollection.Clear();

            textBoxRegisterR1.Text = "";
            textBoxRegisterR2.Text = "";
            textBoxRegisterR3.Text = "";
            textBoxRegisterR4.Text = "";
            textBoxRegisterR5.Text = "";
            textBoxRegisterR6.Text = "";
            textBoxRegisterR7.Text = "";
            textBoxRegisterR8.Text = "";
            textBoxRegisterR9.Text = "";
            textBoxRegisterR10.Text = "";
            textBoxRegisterR11.Text = "";
            textBoxRegisterR12.Text = "";
            textBoxRegisterR13.Text = "";
            textBoxRegisterR14.Text = "";
            textBoxRegisterR15.Text = "";
            textBoxRegisterR16.Text = "";
            textBoxRegisterR17.Text = "";
            textBoxRegisterR18.Text = "";
            textBoxRegisterR19.Text = "";
            textBoxRegisterR20.Text = "";
            textBoxRegisterR21.Text = "";
            textBoxRegisterR22.Text = "";
            textBoxRegisterR23.Text = "";
            textBoxRegisterR24.Text = "";
            textBoxRegisterR25.Text = "";
            textBoxRegisterR26.Text = "";
            textBoxRegisterR27.Text = "";
            textBoxRegisterR28.Text = "";
            textBoxRegisterR29.Text = "";
            textBoxRegisterR30.Text = "";
            textBoxRegisterR31.Text = "";
        }

        private delegate void UpdateUIDelegate();
        private void UpdateUI()
        {
            if (sm_serialThread == null)
            {
                buttonConnect.ToolTip = "Connect (Ctrl+C)";
                buttonConnect.Content = new Image() { Source = new BitmapImage(new Uri(@"pack://application:,,,/Resources/Icons/Connect.png")) };

                buttonProgram.IsEnabled = false;
                buttonLoadIntoMemory.IsEnabled = false;
                buttonSaveMemoryChunk.IsEnabled = false;

                buttonStart.IsEnabled = false;
                buttonPause.IsEnabled = false;
                buttonHalt.IsEnabled = false;
                buttonStep.IsEnabled = false;

                menuItemProgram.IsEnabled = false;
                menuItemLoadIntoMemory.IsEnabled = false;
                menuItemSaveMemoryChunk.IsEnabled = false;

                menuItemStart.IsEnabled = false;
                menuItemPause.IsEnabled = false;
                menuItemHalt.IsEnabled = false;
                menuItemStep.IsEnabled = false;
            }
            else
            {
                buttonConnect.ToolTip = "Disconnect (Ctrl+C)";
                buttonConnect.Content = new Image() { Source = new BitmapImage(new Uri(@"pack://application:,,,/Resources/Icons/Disconnect.png")) };

                buttonProgram.IsEnabled = true;
                buttonLoadIntoMemory.IsEnabled = true;
                buttonSaveMemoryChunk.IsEnabled = true;

                buttonStart.IsEnabled = true;
                buttonPause.IsEnabled = true;
                buttonHalt.IsEnabled = true;
                buttonStep.IsEnabled = true;

                menuItemProgram.IsEnabled = true;
                menuItemLoadIntoMemory.IsEnabled = true;
                menuItemSaveMemoryChunk.IsEnabled = true;

                menuItemStart.IsEnabled = true;
                menuItemPause.IsEnabled = true;
                menuItemHalt.IsEnabled = true;
                menuItemStep.IsEnabled = true;
            }
        }

        private void CommandConvert_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandConvert_Run();
        }

        private void MenuItemConvert_Click(object sender, RoutedEventArgs e)
        {
            CommandConvert_Run();
        }

        private void CommandConvert_Run()
        {
            MessageBox.Show("Convert not implemented!");
        }

        private void CommandExit_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandExit_Run();
        }

        private void MenuItemExit_Click(object sender, RoutedEventArgs e)
        {
            CommandExit_Run();
        }

        private void CommandExit_Run()
        {
            this.Close();
        }

        private void CommandConnect_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandConnect_Run();
        }

        private void MenuItemConnect_Click(object sender, RoutedEventArgs e)
        {
            CommandConnect_Run();
        }

        private void ButtonConnect_Click(object sender, RoutedEventArgs e)
        {
            CommandConnect_Run();
        }

        private void CommandConnect_Run()
        {
            if (sm_serialThread == null)
            {
                WindowConnect portSelector = new WindowConnect();
                if (portSelector.ShowDialog() == true)
                {
                    SerialData serialData = new SerialData();
                    serialData.Port = portSelector.SelectedPort;
                    serialData.Baudrate = portSelector.SelectedBaudrate;

                    sm_serialThread = new Thread(new ParameterizedThreadStart((object serialInfo) =>
                    {
                        SerialThread_Run((SerialData)serialInfo);
                    }));

                    sm_serialThread.Start(serialData);

                    coreStatus = CoreStatus.Halted;

                    SetCHMVisibility(true);

                    configurationRegs[0] = configurationRegs[1] = configurationRegs[2] = configurationRegs[3] = configurationRegs[4] = 0;
                    UpdateCHMView();
                }
            }
            else
            {// disconnects
                if (MessageBox.Show("Are you sure you want to disconnect?", "You are about to disconnect", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
                {
                    lock (sm_serialThread)
                    {
                        sm_serialThreadShutDown = true;
                    }

                    sm_serialThread.Join();

                    sm_serialThreadShutDown = false;
                    sm_serialThread = null;

                    SetUpdateStatus("Disconnected", true);
                    SetConnectionStatus(null, 0);

                    coreStatus = CoreStatus.Disconnected;

                    UpdateUI();

                    ClearDataViews();

                    SetCHMVisibility(false);
                }
            }
        }

        private void CommandProgram_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandProgram_Run();
        }

        private void MenuItemProgram_Click(object sender, RoutedEventArgs e)
        {
            CommandProgram_Run();
        }

        private void ButtonProgram_Click(object sender, RoutedEventArgs e)
        {
            CommandProgram_Run();
        }

        private void CommandProgram_Run()
        {
            if (sm_serialThread == null)
            {
                return;
            }

            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Binary files|*.bin;*.hex";

            if (ofd.ShowDialog() == true)
            {
                programBytes = File.ReadAllBytes(ofd.FileName);
                if (programBytes.Length > 4096)
                {
                    MessageBox.Show("File too large", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                if ((programBytes.Length % 4) != 0)
                {
                    MessageBox.Show(ofd.FileName + " is not a valid program file", "Invalid file", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                startAddress = 0;

                lock (threadCommandQueue)
                {
                    threadCommandQueue.Enqueue(ThreadCommands.WriteProgramMemory);
                }
            }
        }

        private void CommandLoadIntoMemory_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandLoadIntoMemory_Run();
        }

        private void MenuItemLoadIntoMemory_Click(object sender, RoutedEventArgs e)
        {
            CommandLoadIntoMemory_Run();
        }

        private void ButtonLoadIntoMemory_Click(object sender, RoutedEventArgs e)
        {
            CommandLoadIntoMemory_Run();
        }

        private void CommandLoadIntoMemory_Run()
        {
            if (sm_serialThread == null)
            {
                return;
            }

            if (coreStatus == CoreStatus.Running)
            {
                MessageBox.Show("You can't write into memory while the core is running", "The core is running", MessageBoxButton.OK, MessageBoxImage.Stop);
                return;
            }

            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Binary files|*.bin";

            if (ofd.ShowDialog() == true)
            {
                dataBytes = File.ReadAllBytes(ofd.FileName);
                if (dataBytes.Length > 4096)
                {
                    MessageBox.Show("File too large", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                string s;
                bool entered_corectly = false;

                while (entered_corectly == false)
                {
                    s = Interaction.InputBox("Start address", "", "0x000");

                    if (String.IsNullOrEmpty(s))
                    {
                        return;
                    }

                    UInt16? num = ParseHexIntFromString(s);
                    if (num == null)
                    {
                        MessageBox.Show("The number must be ginven in 0x*** format", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    else
                    {
                        startAddress = num.Value;
                        entered_corectly = true;
                    }
                }

                if (startAddress + dataBytes.Length > 4096)
                {
                    MessageBox.Show("The data will not fit at the specified location", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                lock (threadCommandQueue)
                {
                    threadCommandQueue.Enqueue(ThreadCommands.WriteDataMemory);
                }
            }
        }

        private void CommandSaveMemoryChunk_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandSaveMemoryChunk_Run();
        }

        private void MenuItemSaveMemoryChunk_Click(object sender, RoutedEventArgs e)
        {
            CommandSaveMemoryChunk_Run();
        }

        private void ButtonSaveMemoryChunk_Click(object sender, RoutedEventArgs e)
        {
            CommandSaveMemoryChunk_Run();
        }

        private void CommandSaveMemoryChunk_Run()
        {
            if (sm_serialThread == null)
            {
                return;
            }

            if (coreStatus != CoreStatus.Paused && coreStatus != CoreStatus.Halted)
            {
                MessageBox.Show("You can't read the memory while the core is running", "The core is running", MessageBoxButton.OK, MessageBoxImage.Stop);
                return;
            }

            bool entered_correctly = false;
            string startAddrStr = "";
            string streamLengthStr = "";

            UInt16? addr = null;
            UInt16 length = 0;

            while (entered_correctly == false)
            {
                startAddrStr = Interaction.InputBox("Start address", "", "0x000");

                if (String.IsNullOrEmpty(startAddrStr))
                {
                    return;
                }

                addr = ParseHexIntFromString(startAddrStr);
                if (addr == null)
                {
                    MessageBox.Show("The number must be ginven in 0x*** format", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    continue;
                }

                if (addr > 4095)
                {
                    MessageBox.Show("Address out of range", "", MessageBoxButton.OK, MessageBoxImage.Warning);
                    continue;
                }

                entered_correctly = true;
            }

            entered_correctly = false;

            while (entered_correctly == false)
            {
                streamLengthStr = Interaction.InputBox("Chunck size", "", "0");

                if (String.IsNullOrEmpty(streamLengthStr))
                {
                    return;
                }

                if (UInt16.TryParse(streamLengthStr, out length) == false)
                {
                    MessageBox.Show("Please input a positive non-null number", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    continue;
                }

                if (length <= 0)
                {
                    MessageBox.Show("Please input a positive non-null number", "", MessageBoxButton.OK, MessageBoxImage.Information);
                    continue;
                }

                entered_correctly = true;
            }

            if (addr + length > 4096)
            {
                MessageBox.Show("Address out of range", "", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            SaveFileDialog sfd = new SaveFileDialog();
            
            if (sfd.ShowDialog() == false)
            {
                return;
            }

            BinaryWriter bw = new BinaryWriter(File.Open(sfd.FileName, FileMode.Create));

            for (int i = (int)addr; i < addr + length; ++i)
            {
                int index = i >> 4;
                Byte toWrite = 0;

                switch (i & 0xF)
                {
                    case 0x0:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data0, 16);

                        break;
                    }

                    case 0x1:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data1, 16);

                        break;
                    }

                    case 0x2:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data2, 16);

                        break;
                    }

                    case 0x3:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data3, 16);

                        break;
                    }

                    case 0x4:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data4, 16);

                        break;
                    }

                    case 0x5:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data5, 16);

                        break;
                    }

                    case 0x6:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data6, 16);

                        break;
                    }

                    case 0x7:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data7, 16);

                        break;
                    }

                    case 0x8:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data8, 16);

                        break;
                    }

                    case 0x9:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].data9, 16);

                        break;
                    }

                    case 0xA:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].dataA, 16);

                        break;
                    }

                    case 0xB:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].dataB, 16);

                        break;
                    }

                    case 0xC:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].dataC, 16);

                        break;
                    }

                    case 0xD:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].dataD, 16);

                        break;
                    }

                    case 0xE:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].dataE, 16);

                        break;
                    }

                    case 0xF:
                    {
                        toWrite = Convert.ToByte(memoryViewCollection[index].dataF, 16);

                        break;
                    }
                }

                bw.Write(toWrite);
            }

            bw.Flush();
            bw.Close();
        }

        private void CommandStart_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandStart_Run();
        }

        private void MenuItemStart_Click(object sender, RoutedEventArgs e)
        {
            CommandStart_Run();
        }

        private void ButtonStart_Click(object sender, RoutedEventArgs e)
        {
            CommandStart_Run();
        }

        private void CommandStart_Run()
        {
            if (coreStatus == CoreStatus.Halted || coreStatus == CoreStatus.Paused)
            {
                lock (threadCommandQueue)
                {
                    threadCommandQueue.Enqueue(ThreadCommands.ProgramStart);
                }
            }
        }

        private void CommandPause_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandPause_Run();
        }

        private void MenuItemPause_Click(object sender, RoutedEventArgs e)
        {
            CommandPause_Run();
        }

        private void ButtonPause_Click(object sender, RoutedEventArgs e)
        {
            CommandPause_Run();
        }

        private void CommandPause_Run()
        {
            if (coreStatus == CoreStatus.Running)
            {
                lock (threadCommandQueue)
                {
                    threadCommandQueue.Enqueue(ThreadCommands.ProgramPause);
                }
            }
        }

        private void CommandHalt_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandHalt_Run();
        }

        private void MenuItemHalt_Click(object sender, RoutedEventArgs e)
        {
            CommandHalt_Run();
        }

        private void ButtonHalt_Click(object sender, RoutedEventArgs e)
        {
            CommandHalt_Run();
        }

        private void CommandHalt_Run()
        {
            if (coreStatus == CoreStatus.Running || coreStatus == CoreStatus.Paused)
            {
                lock (threadCommandQueue)
                {
                    threadCommandQueue.Enqueue(ThreadCommands.ProgramHalt);
                }
            }
        }

        private void CommandStep_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            CommandStep_Run();
        }

        private void MenuItemStep_Click(object sender, RoutedEventArgs e)
        {
            CommandStep_Run();
        }

        private void ButtonStep_Click(object sender, RoutedEventArgs e)
        {
            CommandStep_Run();
        }

        private void CommandStep_Run()
        {
            if (coreStatus == CoreStatus.Halted || coreStatus == CoreStatus.Paused)
            {
                coreStatus = CoreStatus.Running;

                lock (threadCommandQueue)
                {
                    threadCommandQueue.Enqueue(ThreadCommands.ProgramStep);
                }
            }
        }

        private delegate void UpdateStatusDelegate(string status, bool ready);
        private void SetUpdateStatus(string status, bool ready)
        {
            textBlockLastStatusUpdate.Text = status + (ready ? " (ready)" : " (busy)");
        }

        private delegate void CoreStatusDelegate(string status);
        private void SetCoreStatus(string status)
        {
            textBlockCoreStatus.Text = status;
        }

        private delegate void ConnectionStatusDelegate(string port, int baudrate);
        private void SetConnectionStatus(string port, int baudrate)
        {
            if (String.IsNullOrEmpty(port))
            {
                textBlockConnectionStatus.Text = "";
            }
            else
            {
                textBlockConnectionStatus.Text = port + ", " + baudrate.ToString() + "bps";
            }
        }

        private delegate void ProgressDelegate(bool visible, int value = 0, int maximum = 100);
        private void SetProgress(bool visible, int value = 0, int maximum = 100)
        {
            progressBarGlobal.Visibility = visible ? Visibility.Visible : Visibility.Hidden;
            progressBarGlobal.Maximum = maximum;
            progressBarGlobal.Value = value;
        }

        private void SerialThread_Run(SerialData serialInfo)
        {
            Byte[] bufferIn = new Byte[6];
            Byte[] bufferOut = new Byte[6];

            // opening the port
            Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Connecting to " + serialInfo.Port, false);

            SerialPort commPort = new SerialPort(serialInfo.Port, serialInfo.Baudrate);
            try
            {
                commPort.Open();
                commPort.StopBits = StopBits.Two;
            }
            catch (Exception ex)
            {
                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Failed to connect to " + serialInfo.Port, true);
                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);

                sm_serialThread = null;

                return;
            }
            // /opening the port

            // handshake
            try
            {
                bufferOut[0] = DebugProtocol.CommandHandshakeStart;
                commPort.Write(bufferOut, 0, 1);

                commPort.ReadTimeout = 1000;
                commPort.Read(bufferIn, 0, 1);

                if (bufferIn[0] != DebugProtocol.AnswerHandshakeAccepted)
                {
                    commPort.Close();

                    Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Failed to connect to " + serialInfo.Port, true);
                    MessageBox.Show("Device not recognized or bad cable.", "Device error", MessageBoxButton.OK, MessageBoxImage.Error);

                    return;
                }

                Random rnd = new Random();
                Byte checkSum = 0;
                for (int i = 0; i < 4; ++i)
                {
                    bufferOut[i] = (Byte)rnd.Next();
                    checkSum += (Byte)(bufferOut[i] >> i);
                }
                commPort.Write(bufferOut, 0, 4);

                commPort.Read(bufferIn, 0, 1);

                if (bufferIn[0] != checkSum)
                {
                    commPort.Close();

                    Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Failed to connect to " + serialInfo.Port, true);
                    MessageBox.Show("Device not recognized or bad cable.", "Device error", MessageBoxButton.OK, MessageBoxImage.Error);

                    return;
                }

                bufferOut[0] = DebugProtocol.StatusHandshakeComplete;
                commPort.Write(bufferOut, 0, 1);

                commPort.Read(bufferIn, 0, 1);
                if (bufferIn[0] != DebugProtocol.StatusHandshakeComplete)
                {
                    commPort.Close();

                    Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Failed to connect to " + serialInfo.Port, true);
                    MessageBox.Show("Device not recognized or bad cable.", "Device error", MessageBoxButton.OK, MessageBoxImage.Error);

                    return;
                }
            }
            catch (Exception ex)
            {
                commPort.Close();

                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Failed to connect to " + serialInfo.Port, true);
                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);

                sm_serialThread = null;

                return;
            }
            // /handshake

            Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Connected to RISC-v on " + serialInfo.Port, true);
            Dispatcher.BeginInvoke(new ConnectionStatusDelegate(SetConnectionStatus), serialInfo.Port, serialInfo.Baudrate);

            Dispatcher.BeginInvoke(new UpdateUIDelegate(UpdateUI));

            Dispatcher.BeginInvoke(new InitDataViewsDelegate(InitDataViews));

            for (; ; )
            {
                lock (sm_serialThread)
                { // detect if shutdown is requested
                    if (sm_serialThreadShutDown)
                    {
                        try
                        {
                            bufferOut[0] = DebugProtocol.CommandDisconnect;
                            commPort.Write(bufferOut, 0, 1);

                            commPort.Close();
                        }
                        catch
                        {
                            //
                        }

                        return;
                    }
                }

                try
                {
                    bool portFound = false;
                    foreach (string p in SerialPort.GetPortNames())
                    {
                        if (String.Compare(p, serialInfo.Port) == 0)
                        {
                            portFound = true;
                            break;
                        }
                    }
                    if (portFound == false)
                    {
                        MessageBox.Show("Connection closed unexpectedly", "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);

                        Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Connection lost", true);
                        Dispatcher.BeginInvoke(new ConnectionStatusDelegate(SetConnectionStatus), null, 0);

                        commPort.Close();

                        sm_serialThread = null;
                        Dispatcher.BeginInvoke(new UpdateUIDelegate(UpdateUI));

                        return;
                    }
                }
                catch
                {
                    MessageBox.Show("Connection closed unexpectedly", "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);

                    Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Connection lost", true);
                    Dispatcher.BeginInvoke(new ConnectionStatusDelegate(SetConnectionStatus), null, 0);

                    try
                    {
                        commPort.Close();
                    }
                    catch
                    {
                        //
                    }

                    sm_serialThread = null;
                    Dispatcher.BeginInvoke(new UpdateUIDelegate(UpdateUI));

                    return;
                }

                ThreadCommands? tc = null;

                lock (threadCommandQueue)
                {
                    if (threadCommandQueue.Count > 0)
                    {
                        tc = threadCommandQueue.Dequeue();
                    }
                }

                if (tc != null)
                {
                    switch (tc)
                    {
                        case ThreadCommands.WriteProgramMemory:
                        {
                            Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Writing program memory ...", false);

                            bufferOut[0] = DebugProtocol.CommandWriteInstructionMemory;
                            bufferOut[1] = (Byte)(startAddress >> 8);
                            bufferOut[2] = (Byte)startAddress;
                            bufferOut[3] = (Byte)(programBytes.Length >> 10);
                            bufferOut[4] = (Byte)(programBytes.Length >> 2);

                            int instructionsWritten = 0;

                            try
                            {
                                commPort.Write(bufferOut, 0, 5);

                                bool willWrite = true;

                                for (int i = 0; i < programBytes.Length; i += 4)
                                {
                                    if (willWrite)
                                    {
                                        Byte checkSum = 0x00;

                                        bufferOut[0] = DebugProtocol.CommandWriteInstructionMemoryContinue;
                                        for (int j = 0; j < 4; ++j)
                                        {
                                            bufferOut[j + 1] = programBytes[j + i];
                                            checkSum += (Byte)(bufferOut[j + 1] >> j);
                                        }

                                        commPort.Write(bufferOut, 0, 5);
                                        ++instructionsWritten;

                                        Dispatcher.BeginInvoke(new ProgressDelegate(SetProgress), true, instructionsWritten, programBytes.Length / 4);

                                        commPort.Read(bufferIn, 0, 1);
                                        if (bufferIn[0] != checkSum)
                                        {
                                            willWrite = false;
                                        }
                                    }
                                    else
                                    {
                                        bufferOut[0] = DebugProtocol.CommandWriteInstructionMemoryAbort;
                                        commPort.Write(bufferOut, 0, 1);

                                        MessageBox.Show("Integrity check failed", "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                        Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to program device", true);
                                        Dispatcher.BeginInvoke(new ProgressDelegate(SetProgress), false);

                                        break;
                                    }
                                }

                                coreStatus = CoreStatus.Halted;
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to program device", true);

                                break;
                            }

                            Dispatcher.BeginInvoke(new UpdateProgramViewDelegate(UpdateProgramView), instructionsWritten);
                            Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Program written to the device", true);
                            Dispatcher.BeginInvoke(new ProgressDelegate(SetProgress), false, 0, 100);

                            lock (threadCommandQueue)
                            {
                                threadCommandQueue.Enqueue(ThreadCommands.GetPC);
                            }

                            break;
                        }

                        case ThreadCommands.WriteDataMemory:
                        {
                            Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Writing data memory ...", false);

                            bufferOut[0] = DebugProtocol.CommandWriteDataMemory;
                            bufferOut[1] = (Byte)(startAddress >> 8);
                            bufferOut[2] = (Byte)startAddress;
                            bufferOut[3] = (Byte)(dataBytes.Length >> 8);
                            bufferOut[4] = (Byte)dataBytes.Length;

                            try
                            {
                                commPort.Write(bufferOut, 0, 5);

                                Dispatcher.BeginInvoke(new ProgressDelegate(SetProgress), true, 0, dataBytes.Length);

                                for (int i = 0; i < dataBytes.Length; ++i)
                                {
                                    bufferOut[0] = dataBytes[i];
                                    commPort.Write(bufferOut, 0, 1);
                                    Dispatcher.BeginInvoke(new ProgressDelegate(SetProgress), true, i + 1, 100);
                                }
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to write to the device", true);

                                break;
                            }

                            Dispatcher.BeginInvoke(new UpdateMemoryViewDelegate(UpdateMemoryView));
                            Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Write to the device memory complete", true);
                            Dispatcher.BeginInvoke(new ProgressDelegate(SetProgress), false, 0, 100);

                            break;
                        }

                        case ThreadCommands.GetPC:
                        {
                            bufferOut[0] = DebugProtocol.CommandSendPC;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                for (int i = 0; i < 5; ++i)
                                {
                                    int toReceive = 4;
                                    while (toReceive > 0)
                                    {
                                        toReceive -= commPort.Read(bufferIn, 4 - toReceive, toReceive);
                                    }
                                    PC[i] = 0;
                                    for (int j = 0; j < 4; ++j)
                                    {
                                        PC[i] <<= 8;
                                        PC[i] |= bufferIn[j];
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to get device status", true);

                                break;
                            }

                            Dispatcher.BeginInvoke(new UpdatePCDelegate(UpdatePC));

                            break;
                        }

                        case ThreadCommands.GetRegisters:
                        {
                            bufferOut[0] = DebugProtocol.CommandSendRegisters;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                for (int i = 1; i < 32; ++i)
                                {
                                    int toReceive = 4;
                                    while (toReceive > 0)
                                    {
                                        toReceive -= commPort.Read(bufferIn, 4 - toReceive, toReceive);
                                    }

                                    registers[i] = 0;
                                    for (int j = 0; j < 4; ++j)
                                    {
                                        registers[i] <<= 8;
                                        registers[i] |= bufferIn[j];
                                    }
                                }

                                Dispatcher.BeginInvoke(new UpdateRegistersDelegate(UpdateRegisterView));
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to get device status", true);
                            }

                            break;
                        }

                        case ThreadCommands.GetMemory:
                        {
                            bufferOut[0] = DebugProtocol.CommandSendMemory;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                startAddress = 0;
                                dataBytes = new Byte[4096];

                                for (int i = 0; i < 4096; ++i)
                                {
                                    commPort.Read(bufferIn, 0, 1);
                                    dataBytes[i] = bufferIn[0];
                                }

                                Dispatcher.BeginInvoke(new UpdateMemoryViewDelegate(UpdateMemoryView));
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to get device status", true);
                            }

                            break;
                        }

                        case ThreadCommands.GetTimeStamp:
                        {
                            bufferOut[0] = DebugProtocol.CommandSendTimeStamp;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                UInt64 elapsedTime = 0;

                                for (int i = 0; i < 8; ++i)
                                {
                                    commPort.Read(bufferIn, 0, 1);

                                    elapsedTime <<= 8;
                                    elapsedTime |= bufferIn[0];
                                }

                                Dispatcher.BeginInvoke(new ShowElapsedTimeDelegate(ShowElapsedTime), elapsedTime);
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to get device status", true);
                            }

                            break;
                        }

                        case ThreadCommands.GetConfuguration:
                        {
                            bufferOut[0] = DebugProtocol.CommandSendConfiguration;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                for (int i = 0; i < 5; ++i)
                                {
                                    configurationRegs[i] = 0;
                                    for (int j = 0; j < 4; ++j)
                                    {
                                        commPort.Read(bufferIn, 0, 1);

                                        configurationRegs[i] <<= 8;
                                        configurationRegs[i] |= bufferIn[0];
                                    }
                                }

                                Dispatcher.BeginInvoke(new UpdateCHMViewDelegate(UpdateCHMView));
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to get device status", true);
                            }

                            break;
                        }

                        case ThreadCommands.ProgramStart:
                        {
                            bufferOut[0] = DebugProtocol.CommandStart;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);
                                coreStatus = CoreStatus.Running;

                                PC[0] = PC[1] = PC[2] = PC[3] = PC[4] = -1;

                                Dispatcher.BeginInvoke(new UpdatePCDelegate(UpdatePC));
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to communicate to the device", true);
                            }

                            break;
                        }

                        case ThreadCommands.ProgramPause:
                        {
                            bufferOut[0] = DebugProtocol.CommandPause;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);
                                coreStatus = CoreStatus.Paused;

                                lock (threadCommandQueue)
                                {
                                    threadCommandQueue.Enqueue(ThreadCommands.GetPC);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetRegisters);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetMemory);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetConfuguration);
                                }
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to communicate to the device", true);
                            }

                            break;
                        }

                        case ThreadCommands.ProgramHalt:
                        {
                            bufferOut[0] = DebugProtocol.CommandHalt;
                            coreStatus = CoreStatus.Halted;
                            
                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                lock (threadCommandQueue)
                                {
                                    threadCommandQueue.Enqueue(ThreadCommands.GetPC);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetRegisters);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetMemory);
                                }
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to communicate to the device", true);
                            }

                            break;
                        }
                        
                        case ThreadCommands.ProgramStep:
                        {
                            bufferOut[0] = DebugProtocol.CommandStep;

                            try
                            {
                                commPort.Write(bufferOut, 0, 1);

                                PC[0] = PC[1] = PC[2] = PC[3] = PC[4] = -1;
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show(ex.Message, "Serial error", MessageBoxButton.OK, MessageBoxImage.Error);
                                Dispatcher.BeginInvoke(new UpdateStatusDelegate(SetUpdateStatus), "Error: Unable to communicate to the device", true);

                                break;
                            }

                            Dispatcher.BeginInvoke(new UpdatePCDelegate(UpdatePC));

                            break;
                        }

                        default:
                        {
                            break;
                        }
                    }
                }

                try
                {
                    if (commPort.BytesToRead > 0)
                    {
                        commPort.Read(bufferIn, 0, 1);
                        Byte status = bufferIn[0];

                        switch (status)
                        {
                            case DebugProtocol.StatusStepComplete:
                            {
                                lock (threadCommandQueue)
                                {
                                    threadCommandQueue.Enqueue(ThreadCommands.GetPC);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetRegisters);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetMemory);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetConfuguration);
                                }

                                coreStatus = CoreStatus.Paused;

                                break;
                            }

                            case DebugProtocol.StatusRunComplete:
                            {
                                lock (threadCommandQueue)
                                {
                                    threadCommandQueue.Enqueue(ThreadCommands.GetPC);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetRegisters);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetMemory);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetConfuguration);
                                    threadCommandQueue.Enqueue(ThreadCommands.GetTimeStamp);
                                }

                                coreStatus = CoreStatus.Paused;

                                break;
                            }

                            default:
                            {
                                break;
                            }
                        }
                    }
                }
                catch
                {

                }
            }
        }

        private void DataGridProgramView_CellEditEnding(object sender, DataGridCellEditEndingEventArgs e)
        {
            int index = e.Row.GetIndex();
            string txt = (e.EditingElement as TextBox).Text;
            MessageBox.Show(((ProgramViewItem)dataGridProgramView.Items[index]).opCode);
            MessageBox.Show(txt);

            if (txt.StartsWith("0x") == false)
            {
                MessageBox.Show("invalid value");
                e.Cancel = true;
                (e.EditingElement as TextBox).Text = ((ProgramViewItem)dataGridProgramView.Items[index]).opCode;
            }
        }

        private UInt16? ParseHexIntFromString(string str)
        {
            if (str.StartsWith("0x") == false)
            {
                return null;
            }

            try
            {
                UInt16 x = Convert.ToUInt16(str, 16);
                return x;
            }
            catch
            {
                return null;
            }
        }
    }
}
