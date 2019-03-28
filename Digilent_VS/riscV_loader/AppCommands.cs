using System;
using System.Windows.Input;

namespace riscV_loader.Commands
{
    public class AppCommands
    {
        public static RoutedUICommand commandConvert = new RoutedUICommand("_Convert", "commandConvert", typeof(AppCommands));
        public static RoutedUICommand commandExit = new RoutedUICommand("E_xit", "commandExit", typeof(AppCommands));
        public static RoutedUICommand commandConnect = new RoutedUICommand("_Connect", "commandConnect", typeof(AppCommands));
        public static RoutedUICommand commandProgram = new RoutedUICommand("_Program", "commandProgram", typeof(AppCommands));
        public static RoutedUICommand commandLoadIntoMemory = new RoutedUICommand("_LoadIntoMemory", "commandLoadIntoMemory", typeof(AppCommands));
        public static RoutedUICommand commandSaveMemoryChunk = new RoutedUICommand("_SaveMemoryChunk", "commandSaveMemoryChunk", typeof(AppCommands));
        public static RoutedUICommand commandStart = new RoutedUICommand("_Start", "commandStart", typeof(AppCommands));
        public static RoutedUICommand commandPause = new RoutedUICommand("_Pause", "commandPause", typeof(AppCommands));
        public static RoutedUICommand commandHalt = new RoutedUICommand("_Halt", "commandHalt", typeof(AppCommands));
        public static RoutedUICommand commandStep = new RoutedUICommand("Step", "commandStep", typeof(AppCommands));
    }
}
