using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Text;
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
    /// Interaction logic for WindowConnect.xaml
    /// </summary>
    public partial class WindowConnect : Window
    {
        private string m_port;
        private int m_baudrate;

        public string SelectedPort
        {
            get
            {
                return m_port;
            }
        }

        public int SelectedBaudrate
        {
            get
            {
                return m_baudrate;
            }
        }

        public WindowConnect()
        {
            InitializeComponent();
        }

        private void WindowConnect_Loaded(object sender, RoutedEventArgs e)
        {
            comboBoxBaud.Items.Add(9600);
            comboBoxBaud.Items.Add(14400);
            comboBoxBaud.Items.Add(19200);
            comboBoxBaud.Items.Add(115200);
            comboBoxBaud.Items.Add(128000);

            comboBoxBaud.SelectedIndex = 0;

            foreach (string port in SerialPort.GetPortNames())
            {
                comboBoxPorts.Items.Add(port);
            }

            if (comboBoxPorts.Items.Count > 0)
            {
                comboBoxPorts.SelectedIndex = 0;
            }
            else
            {
                comboBoxPorts.IsEnabled = false;
            }
        }

        private void ButtonConnect_Click(object sender, RoutedEventArgs e)
        {
            if (comboBoxPorts.SelectedIndex != -1)
            {
                m_port = comboBoxPorts.Items[comboBoxPorts.SelectedIndex].ToString();
            }
            else
            {
                MessageBox.Show("You must select a COM port");
                return;
            }

            if (comboBoxBaud.SelectedIndex != -1)
            {
                m_baudrate = Int32.Parse(comboBoxBaud.Items[comboBoxBaud.SelectedIndex].ToString());
            }
            else
            {
                MessageBox.Show("You must select a baudrate");
                return;
            }

            DialogResult = true;
        }
    }
}
