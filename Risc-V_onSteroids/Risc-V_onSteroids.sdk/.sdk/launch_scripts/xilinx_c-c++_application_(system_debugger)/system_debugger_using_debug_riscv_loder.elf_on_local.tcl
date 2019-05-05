connect -url tcp:127.0.0.1:3121
source D:/Altele/Digilent/Workspace/Risc-V_onSteroids/Risc-V_onSteroids.sdk/design_1_wrapper_hw_platform_0/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Cora Z7 - 7007S 210370A92DAEA"} -index 0
loadhw -hw D:/Altele/Digilent/Workspace/Risc-V_onSteroids/Risc-V_onSteroids.sdk/design_1_wrapper_hw_platform_0/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Cora Z7 - 7007S 210370A92DAEA"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Cora Z7 - 7007S 210370A92DAEA"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Cora Z7 - 7007S 210370A92DAEA"} -index 0
dow D:/Altele/Digilent/Workspace/Risc-V_onSteroids/Risc-V_onSteroids.sdk/riscV_loder/Debug/riscV_loder.elf
configparams force-mem-access 0
bpadd -addr &main
