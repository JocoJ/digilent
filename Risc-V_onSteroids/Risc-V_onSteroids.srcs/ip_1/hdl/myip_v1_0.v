
`timescale 1 ns / 1 ps

	module myip_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface INSTR_AXI
		parameter integer C_INSTR_AXI_DATA_WIDTH	= 32,
		parameter integer C_INSTR_AXI_ADDR_WIDTH	= 12,

		// Parameters of Axi Slave Bus Interface DATA_AXI
		parameter integer C_DATA_AXI_DATA_WIDTH	= 32,
		parameter integer C_DATA_AXI_ADDR_WIDTH	= 12,

		// Parameters of Axi Slave Bus Interface REGS_AXI
		parameter integer C_REGS_AXI_DATA_WIDTH	= 32,
		parameter integer C_REGS_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here
        input wire riscv_clk,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface INSTR_AXI
		input wire  instr_axi_aclk,
		input wire  instr_axi_aresetn,
		input wire [C_INSTR_AXI_ADDR_WIDTH-1 : 0] instr_axi_awaddr,
		input wire [2 : 0] instr_axi_awprot,
		input wire  instr_axi_awvalid,
		output wire  instr_axi_awready,
		input wire [C_INSTR_AXI_DATA_WIDTH-1 : 0] instr_axi_wdata,
		input wire [(C_INSTR_AXI_DATA_WIDTH/8)-1 : 0] instr_axi_wstrb,
		input wire  instr_axi_wvalid,
		output wire  instr_axi_wready,
		output wire [1 : 0] instr_axi_bresp,
		output wire  instr_axi_bvalid,
		input wire  instr_axi_bready,
		input wire [C_INSTR_AXI_ADDR_WIDTH-1 : 0] instr_axi_araddr,
		input wire [2 : 0] instr_axi_arprot,
		input wire  instr_axi_arvalid,
		output wire  instr_axi_arready,
		output wire [C_INSTR_AXI_DATA_WIDTH-1 : 0] instr_axi_rdata,
		output wire [1 : 0] instr_axi_rresp,
		output wire  instr_axi_rvalid,
		input wire  instr_axi_rready,

		// Ports of Axi Slave Bus Interface DATA_AXI
		input wire  data_axi_aclk,
		input wire  data_axi_aresetn,
		input wire [C_DATA_AXI_ADDR_WIDTH-1 : 0] data_axi_awaddr,
		input wire [2 : 0] data_axi_awprot,
		input wire  data_axi_awvalid,
		output wire  data_axi_awready,
		input wire [C_DATA_AXI_DATA_WIDTH-1 : 0] data_axi_wdata,
		input wire [(C_DATA_AXI_DATA_WIDTH/8)-1 : 0] data_axi_wstrb,
		input wire  data_axi_wvalid,
		output wire  data_axi_wready,
		output wire [1 : 0] data_axi_bresp,
		output wire  data_axi_bvalid,
		input wire  data_axi_bready,
		input wire [C_DATA_AXI_ADDR_WIDTH-1 : 0] data_axi_araddr,
		input wire [2 : 0] data_axi_arprot,
		input wire  data_axi_arvalid,
		output wire  data_axi_arready,
		output wire [C_DATA_AXI_DATA_WIDTH-1 : 0] data_axi_rdata,
		output wire [1 : 0] data_axi_rresp,
		output wire  data_axi_rvalid,
		input wire  data_axi_rready,

		// Ports of Axi Slave Bus Interface REGS_AXI
		input wire  regs_axi_aclk,
		input wire  regs_axi_aresetn,
		input wire [C_REGS_AXI_ADDR_WIDTH-1 : 0] regs_axi_awaddr,
		input wire [2 : 0] regs_axi_awprot,
		input wire  regs_axi_awvalid,
		output wire  regs_axi_awready,
		input wire [C_REGS_AXI_DATA_WIDTH-1 : 0] regs_axi_wdata,
		input wire [(C_REGS_AXI_DATA_WIDTH/8)-1 : 0] regs_axi_wstrb,
		input wire  regs_axi_wvalid,
		output wire  regs_axi_wready,
		output wire [1 : 0] regs_axi_bresp,
		output wire  regs_axi_bvalid,
		input wire  regs_axi_bready,
		input wire [C_REGS_AXI_ADDR_WIDTH-1 : 0] regs_axi_araddr,
		input wire [2 : 0] regs_axi_arprot,
		input wire  regs_axi_arvalid,
		output wire  regs_axi_arready,
		output wire [C_REGS_AXI_DATA_WIDTH-1 : 0] regs_axi_rdata,
		output wire [1 : 0] regs_axi_rresp,
		output wire  regs_axi_rvalid,
		input wire  regs_axi_rready
	);
	
	wire [9:0] instruction_address;
    wire [31:0] instruction;
// Instantiation of Axi Bus Interface INSTR_AXI
	myip_v1_0_INSTR_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_INSTR_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_INSTR_AXI_ADDR_WIDTH)
	) myip_v1_0_INSTR_AXI_inst (
	    //RISC-V INSTRUCTION SIGNALS///////////////////////////
	    .instruction_address(instruction_address),
        .instruction(instruction),
        ////////////////////////////////////////////////////////
		.S_AXI_ACLK(instr_axi_aclk),
		.S_AXI_ARESETN(instr_axi_aresetn),
		.S_AXI_AWADDR(instr_axi_awaddr),
		.S_AXI_AWPROT(instr_axi_awprot),
		.S_AXI_AWVALID(instr_axi_awvalid),
		.S_AXI_AWREADY(instr_axi_awready),
		.S_AXI_WDATA(instr_axi_wdata),
		.S_AXI_WSTRB(instr_axi_wstrb),
		.S_AXI_WVALID(instr_axi_wvalid),
		.S_AXI_WREADY(instr_axi_wready),
		.S_AXI_BRESP(instr_axi_bresp),
		.S_AXI_BVALID(instr_axi_bvalid),
		.S_AXI_BREADY(instr_axi_bready),
		.S_AXI_ARADDR(instr_axi_araddr),
		.S_AXI_ARPROT(instr_axi_arprot),
		.S_AXI_ARVALID(instr_axi_arvalid),
		.S_AXI_ARREADY(instr_axi_arready),
		.S_AXI_RDATA(instr_axi_rdata),
		.S_AXI_RRESP(instr_axi_rresp),
		.S_AXI_RVALID(instr_axi_rvalid),
		.S_AXI_RREADY(instr_axi_rready)
	);

    wire MemRead;
    wire MemWrite;
    wire [4:0] funct3;
    wire [9:0] data_address;
    wire [31:0] data_write;
    wire [31:0] data_read; 
// Instantiation of Axi Bus Interface DATA_AXI
	myip_v1_0_DATA_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_DATA_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_DATA_AXI_ADDR_WIDTH)
	) myip_v1_0_DATA_AXI_inst (
	     //RISC-V data memory regs and signals
	     .MemRead(MemRead),
         .MemWrite(MemWrite),
         .funct3(funct3),
         .data_address(data_address),
         .data_write(data_write),
         .data_read(data_read),
	     /////////////////////////////////////
		.S_AXI_ACLK(data_axi_aclk),
		.S_AXI_ARESETN(data_axi_aresetn),
		.S_AXI_AWADDR(data_axi_awaddr),
		.S_AXI_AWPROT(data_axi_awprot),
		.S_AXI_AWVALID(data_axi_awvalid),
		.S_AXI_AWREADY(data_axi_awready),
		.S_AXI_WDATA(data_axi_wdata),
		.S_AXI_WSTRB(data_axi_wstrb),
		.S_AXI_WVALID(data_axi_wvalid),
		.S_AXI_WREADY(data_axi_wready),
		.S_AXI_BRESP(data_axi_bresp),
		.S_AXI_BVALID(data_axi_bvalid),
		.S_AXI_BREADY(data_axi_bready),
		.S_AXI_ARADDR(data_axi_araddr),
		.S_AXI_ARPROT(data_axi_arprot),
		.S_AXI_ARVALID(data_axi_arvalid),
		.S_AXI_ARREADY(data_axi_arready),
		.S_AXI_RDATA(data_axi_rdata),
		.S_AXI_RRESP(data_axi_rresp),
		.S_AXI_RVALID(data_axi_rvalid),
		.S_AXI_RREADY(data_axi_rready)
	);

     wire write_enable_basic;		// I: write enable for the single port mode
     wire write_enable_conf;        // I: write enable for the configuration registers (32->36)
     wire write_enable_CLB;        // I: write enable for multiport mode
     wire [5:0] read_addr1;                // I: read addresses
     wire [5:0] read_addr2;
     wire [5:0] read_addr3;
     wire [5:0] read_addr4;
     wire [5:0] read_addr5;
     wire [5:0] read_addr6;
     wire [5:0] write_addr;                // I: write address for single port mode (NOTE: multiport writing addresses are handled by the configuration registers)
     wire [5:0] write_addr_conf;        // I: write address for the configuration registers
     wire [31:0] write_data1;            // I: write data for both single port and multiport modes
     wire [31:0] write_data2;            // I: write data for multiport mode only
     wire [31:0] write_data3;            // I: write data for multiport mode only
     wire [31:0] write_data_conf;        // I: write data for the configuration registers
     wire [31:0] read_data1;                // O: output data from the regFile
     wire [31:0] read_data2;
     wire [31:0] read_data3;
     wire [31:0] read_data4;
     wire [31:0] read_data5;
     wire [31:0] read_data6;
     wire [31:0] CLB_conf1;                // O: outputs for the CHM
     wire [31:0] CLB_conf2;
     wire [31:0] CLB_conf3;
     wire [31:0] CLB_conf4;
     wire [31:0] CLB_conf5;
     
     wire [31:0] buff0;
     wire [31:0] buff1;
     wire [31:0] buff2;
     wire [31:0] buff3;
    
     wire [2:0] CSR; //AUTOSTOP; PAUSE; RESET
     wire [63:0] timestamp;
     wire [31:0] pc_if;
     wire [31:0] pc_id;
     wire [31:0] pc_ex;
     wire [31:0] pc_mem;
     wire [31:0] pc_wb;
     wire CSR_write;
     wire autostop;
     wire pause;
// Instantiation of Axi Bus Interface REGS_AXI
	myip_v1_0_REGS_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_REGS_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_REGS_AXI_ADDR_WIDTH)
	) myip_v1_0_REGS_AXI_inst (
	    //RISC-V REGISTERS////////////////////
	    .write_enable_basic(write_enable_basic),		// I: write enable for the single port mode
        .write_enable_conf(write_enable_conf),       // I: write enable for the configuration registers (32->36)
        .write_enable_CLB(write_enable_CLB),        // I: write enable for multiport mode
        .read_addr1(read_addr1),                // I: read addresses
        .read_addr2(read_addr2),
        .read_addr3(read_addr3),
        .read_addr4(read_addr4),
        .read_addr5(read_addr5),
        .read_addr6(read_addr6),
        .write_addr(write_addr),                // I: write address for single port mode (NOTE: multiport writing addresses are handled by the configuration registers)
        .write_addr_conf(write_addr_conf),        // I: write address for the configuration registers
        .write_data1(write_data1),            // I: write data for both single port and multiport modes
        .write_data2(write_data2),            // I: write data for multiport mode only
        .write_data3(write_data3),            // I: write data for multiport mode only
        .write_data_conf(write_data_conf),        // I: write data for the configuration registers
        .read_data1(read_data1),                // O: output data from the regFile
        .read_data2(read_data2),
        .read_data3(read_data3),
        .read_data4(read_data4),
        .read_data5(read_data5),
        .read_data6(read_data6),
        .CLB_conf1(CLB_conf1),                // O: outputs for the CHM
        .CLB_conf2(CLB_conf2),
        .CLB_conf3(CLB_conf3),
        .CLB_conf4(CLB_conf4),
        .CLB_conf5(CLB_conf5),
        
        .buff0(buff0),
        .buff1(buff1),
        .buff2(buff2),
        .buff3(buff3),
      
        .pc_if(pc_if),
        .pc_id(pc_id),
        .pc_ex(pc_ex),
        .pc_mem(pc_mem),
        .pc_wb(pc_wb),
        .timestamp(timestamp),
        .csr_write(CSR_write),
        .autostop(autostop),
        .pause(pause),
        .CSR(CSR),
        ////////////////////////////////////////////
		.S_AXI_ACLK(regs_axi_aclk),
		.S_AXI_ARESETN(regs_axi_aresetn),
		.S_AXI_AWADDR(regs_axi_awaddr),
		.S_AXI_AWPROT(regs_axi_awprot),
		.S_AXI_AWVALID(regs_axi_awvalid),
		.S_AXI_AWREADY(regs_axi_awready),
		.S_AXI_WDATA(regs_axi_wdata),
		.S_AXI_WSTRB(regs_axi_wstrb),
		.S_AXI_WVALID(regs_axi_wvalid),
		.S_AXI_WREADY(regs_axi_wready),
		.S_AXI_BRESP(regs_axi_bresp),
		.S_AXI_BVALID(regs_axi_bvalid),
		.S_AXI_BREADY(regs_axi_bready),
		.S_AXI_ARADDR(regs_axi_araddr),
		.S_AXI_ARPROT(regs_axi_arprot),
		.S_AXI_ARVALID(regs_axi_arvalid),
		.S_AXI_ARREADY(regs_axi_arready),
		.S_AXI_RDATA(regs_axi_rdata),
		.S_AXI_RRESP(regs_axi_rresp),
		.S_AXI_RVALID(regs_axi_rvalid),
		.S_AXI_RREADY(regs_axi_rready)
	);

	// Add user logic here
    RISC_V risc_v(riscv_clk,
                  instruction_address,
                  instruction,
                  
	              write_enable_basic,		// I: write enable for the single port mode
                  write_enable_conf,       // I: write enable for the configuration registers (32->36)
                  write_enable_CLB,        // I: write enable for multiport mode
                  read_addr1,                // I: read addresses
                  read_addr2,
                  read_addr3,
                  read_addr4,
                  read_addr5,
                  read_addr6,
                  write_addr,                // I: write address for single port mode (NOTE: multiport writing addresses are handled by the configuration registers)
                  write_addr_conf,        // I: write address for the configuration registers
                  write_data1,            // I: write data for both single port and multiport modes
                  write_data2,            // I: write data for multiport mode only
                  write_data3,            // I: write data for multiport mode only
                  write_data_conf,        // I: write data for the configuration registers
                  read_data1,                // O: output data from the regFile
                  read_data2,
                  read_data3,
                  read_data4,
                  read_data5,
                  read_data6,
                  CLB_conf1,                // O: outputs for the CHM
                  CLB_conf2,
                  CLB_conf3,
                  CLB_conf4,
                  CLB_conf5,
                  
                  buff0,
                  buff1,
                  buff2,
                  buff3,
                  
                  MemRead,
                  MemWrite,
                  funct3,
                  data_address,
                  data_write,
                  data_read,
                  
                  pc_if,
                  pc_id,
                  pc_ex,
                  pc_mem,
                  pc_wb,
                  
                  CSR_write,
                  autostop,
                  pause,
                  CSR,
                  timestamp);
	// User logic ends

	endmodule
