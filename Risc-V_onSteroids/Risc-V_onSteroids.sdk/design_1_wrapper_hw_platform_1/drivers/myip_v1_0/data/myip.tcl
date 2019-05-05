

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "myip" "NUM_INSTANCES" "DEVICE_ID"  "C_INSTR_AXI_BASEADDR" "C_INSTR_AXI_HIGHADDR" "C_DATA_AXI_BASEADDR" "C_DATA_AXI_HIGHADDR" "C_REGS_AXI_BASEADDR" "C_REGS_AXI_HIGHADDR"
}
