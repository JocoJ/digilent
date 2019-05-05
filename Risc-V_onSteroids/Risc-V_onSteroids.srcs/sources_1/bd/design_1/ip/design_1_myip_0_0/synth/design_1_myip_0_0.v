// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:myip:1.0
// IP Revision: 46

(* X_CORE_INFO = "myip_v1_0,Vivado 2018.2" *)
(* CHECK_LICENSE_TYPE = "design_1_myip_0_0,myip_v1_0,{}" *)
(* CORE_GENERATION_INFO = "design_1_myip_0_0,myip_v1_0,{x_ipProduct=Vivado 2018.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=myip,x_ipVersion=1.0,x_ipCoreRevision=46,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_DATA_AXI_DATA_WIDTH=32,C_DATA_AXI_ADDR_WIDTH=12,C_REGS_AXI_DATA_WIDTH=32,C_REGS_AXI_ADDR_WIDTH=8,C_INSTR_AXI_DATA_WIDTH=32,C_INSTR_AXI_ADDR_WIDTH=12}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_myip_0_0 (
  riscv_clk,
  data_axi_awaddr,
  data_axi_awprot,
  data_axi_awvalid,
  data_axi_awready,
  data_axi_wdata,
  data_axi_wstrb,
  data_axi_wvalid,
  data_axi_wready,
  data_axi_bresp,
  data_axi_bvalid,
  data_axi_bready,
  data_axi_araddr,
  data_axi_arprot,
  data_axi_arvalid,
  data_axi_arready,
  data_axi_rdata,
  data_axi_rresp,
  data_axi_rvalid,
  data_axi_rready,
  data_axi_aclk,
  data_axi_aresetn,
  regs_axi_awaddr,
  regs_axi_awprot,
  regs_axi_awvalid,
  regs_axi_awready,
  regs_axi_wdata,
  regs_axi_wstrb,
  regs_axi_wvalid,
  regs_axi_wready,
  regs_axi_bresp,
  regs_axi_bvalid,
  regs_axi_bready,
  regs_axi_araddr,
  regs_axi_arprot,
  regs_axi_arvalid,
  regs_axi_arready,
  regs_axi_rdata,
  regs_axi_rresp,
  regs_axi_rvalid,
  regs_axi_rready,
  regs_axi_aclk,
  regs_axi_aresetn,
  instr_axi_awaddr,
  instr_axi_awprot,
  instr_axi_awvalid,
  instr_axi_awready,
  instr_axi_wdata,
  instr_axi_wstrb,
  instr_axi_wvalid,
  instr_axi_wready,
  instr_axi_bresp,
  instr_axi_bvalid,
  instr_axi_bready,
  instr_axi_araddr,
  instr_axi_arprot,
  instr_axi_arvalid,
  instr_axi_arready,
  instr_axi_rdata,
  instr_axi_rresp,
  instr_axi_rvalid,
  instr_axi_rready,
  instr_axi_aclk,
  instr_axi_aresetn
);

input wire riscv_clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI AWADDR" *)
input wire [11 : 0] data_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI AWPROT" *)
input wire [2 : 0] data_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI AWVALID" *)
input wire data_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI AWREADY" *)
output wire data_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI WDATA" *)
input wire [31 : 0] data_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI WSTRB" *)
input wire [3 : 0] data_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI WVALID" *)
input wire data_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI WREADY" *)
output wire data_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI BRESP" *)
output wire [1 : 0] data_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI BVALID" *)
output wire data_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI BREADY" *)
input wire data_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI ARADDR" *)
input wire [11 : 0] data_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI ARPROT" *)
input wire [2 : 0] data_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI ARVALID" *)
input wire data_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI ARREADY" *)
output wire data_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI RDATA" *)
output wire [31 : 0] data_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI RRESP" *)
output wire [1 : 0] data_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI RVALID" *)
output wire data_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA_AXI, WIZ_DATA_WIDTH 32, WIZ_NUM_REG 512, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 70000000, ID_WIDTH 0, ADDR_WIDTH 12, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, N\
UM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 DATA_AXI RREADY" *)
input wire data_axi_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA_AXI_CLK, ASSOCIATED_BUSIF DATA_AXI, ASSOCIATED_RESET data_axi_aresetn, FREQ_HZ 70000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 DATA_AXI_CLK CLK" *)
input wire data_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA_AXI_RST, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 DATA_AXI_RST RST" *)
input wire data_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI AWADDR" *)
input wire [7 : 0] regs_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI AWPROT" *)
input wire [2 : 0] regs_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI AWVALID" *)
input wire regs_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI AWREADY" *)
output wire regs_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI WDATA" *)
input wire [31 : 0] regs_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI WSTRB" *)
input wire [3 : 0] regs_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI WVALID" *)
input wire regs_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI WREADY" *)
output wire regs_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI BRESP" *)
output wire [1 : 0] regs_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI BVALID" *)
output wire regs_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI BREADY" *)
input wire regs_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI ARADDR" *)
input wire [7 : 0] regs_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI ARPROT" *)
input wire [2 : 0] regs_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI ARVALID" *)
input wire regs_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI ARREADY" *)
output wire regs_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI RDATA" *)
output wire [31 : 0] regs_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI RRESP" *)
output wire [1 : 0] regs_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI RVALID" *)
output wire regs_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME REGS_AXI, WIZ_DATA_WIDTH 32, WIZ_NUM_REG 64, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 70000000, ID_WIDTH 0, ADDR_WIDTH 8, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, NUM\
_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 REGS_AXI RREADY" *)
input wire regs_axi_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME REGS_AXI_CLK, ASSOCIATED_BUSIF REGS_AXI, ASSOCIATED_RESET regs_axi_aresetn, FREQ_HZ 70000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 REGS_AXI_CLK CLK" *)
input wire regs_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME REGS_AXI_RST, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 REGS_AXI_RST RST" *)
input wire regs_axi_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI AWADDR" *)
input wire [11 : 0] instr_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI AWPROT" *)
input wire [2 : 0] instr_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI AWVALID" *)
input wire instr_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI AWREADY" *)
output wire instr_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI WDATA" *)
input wire [31 : 0] instr_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI WSTRB" *)
input wire [3 : 0] instr_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI WVALID" *)
input wire instr_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI WREADY" *)
output wire instr_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI BRESP" *)
output wire [1 : 0] instr_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI BVALID" *)
output wire instr_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI BREADY" *)
input wire instr_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI ARADDR" *)
input wire [11 : 0] instr_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI ARPROT" *)
input wire [2 : 0] instr_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI ARVALID" *)
input wire instr_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI ARREADY" *)
output wire instr_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI RDATA" *)
output wire [31 : 0] instr_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI RRESP" *)
output wire [1 : 0] instr_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI RVALID" *)
output wire instr_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INSTR_AXI, WIZ_DATA_WIDTH 32, WIZ_NUM_REG 512, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 70000000, ID_WIDTH 0, ADDR_WIDTH 12, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, \
NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 INSTR_AXI RREADY" *)
input wire instr_axi_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INSTR_AXI_CLK, ASSOCIATED_BUSIF INSTR_AXI, ASSOCIATED_RESET instr_axi_aresetn, FREQ_HZ 70000000, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 INSTR_AXI_CLK CLK" *)
input wire instr_axi_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INSTR_AXI_RST, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 INSTR_AXI_RST RST" *)
input wire instr_axi_aresetn;

  myip_v1_0 #(
    .C_DATA_AXI_DATA_WIDTH(32),  // Width of S_AXI data bus
    .C_DATA_AXI_ADDR_WIDTH(12),  // Width of S_AXI address bus
    .C_REGS_AXI_DATA_WIDTH(32),  // Width of S_AXI data bus
    .C_REGS_AXI_ADDR_WIDTH(8),  // Width of S_AXI address bus
    .C_INSTR_AXI_DATA_WIDTH(32),  // Width of S_AXI data bus
    .C_INSTR_AXI_ADDR_WIDTH(12)  // Width of S_AXI address bus
  ) inst (
    .riscv_clk(riscv_clk),
    .data_axi_awaddr(data_axi_awaddr),
    .data_axi_awprot(data_axi_awprot),
    .data_axi_awvalid(data_axi_awvalid),
    .data_axi_awready(data_axi_awready),
    .data_axi_wdata(data_axi_wdata),
    .data_axi_wstrb(data_axi_wstrb),
    .data_axi_wvalid(data_axi_wvalid),
    .data_axi_wready(data_axi_wready),
    .data_axi_bresp(data_axi_bresp),
    .data_axi_bvalid(data_axi_bvalid),
    .data_axi_bready(data_axi_bready),
    .data_axi_araddr(data_axi_araddr),
    .data_axi_arprot(data_axi_arprot),
    .data_axi_arvalid(data_axi_arvalid),
    .data_axi_arready(data_axi_arready),
    .data_axi_rdata(data_axi_rdata),
    .data_axi_rresp(data_axi_rresp),
    .data_axi_rvalid(data_axi_rvalid),
    .data_axi_rready(data_axi_rready),
    .data_axi_aclk(data_axi_aclk),
    .data_axi_aresetn(data_axi_aresetn),
    .regs_axi_awaddr(regs_axi_awaddr),
    .regs_axi_awprot(regs_axi_awprot),
    .regs_axi_awvalid(regs_axi_awvalid),
    .regs_axi_awready(regs_axi_awready),
    .regs_axi_wdata(regs_axi_wdata),
    .regs_axi_wstrb(regs_axi_wstrb),
    .regs_axi_wvalid(regs_axi_wvalid),
    .regs_axi_wready(regs_axi_wready),
    .regs_axi_bresp(regs_axi_bresp),
    .regs_axi_bvalid(regs_axi_bvalid),
    .regs_axi_bready(regs_axi_bready),
    .regs_axi_araddr(regs_axi_araddr),
    .regs_axi_arprot(regs_axi_arprot),
    .regs_axi_arvalid(regs_axi_arvalid),
    .regs_axi_arready(regs_axi_arready),
    .regs_axi_rdata(regs_axi_rdata),
    .regs_axi_rresp(regs_axi_rresp),
    .regs_axi_rvalid(regs_axi_rvalid),
    .regs_axi_rready(regs_axi_rready),
    .regs_axi_aclk(regs_axi_aclk),
    .regs_axi_aresetn(regs_axi_aresetn),
    .instr_axi_awaddr(instr_axi_awaddr),
    .instr_axi_awprot(instr_axi_awprot),
    .instr_axi_awvalid(instr_axi_awvalid),
    .instr_axi_awready(instr_axi_awready),
    .instr_axi_wdata(instr_axi_wdata),
    .instr_axi_wstrb(instr_axi_wstrb),
    .instr_axi_wvalid(instr_axi_wvalid),
    .instr_axi_wready(instr_axi_wready),
    .instr_axi_bresp(instr_axi_bresp),
    .instr_axi_bvalid(instr_axi_bvalid),
    .instr_axi_bready(instr_axi_bready),
    .instr_axi_araddr(instr_axi_araddr),
    .instr_axi_arprot(instr_axi_arprot),
    .instr_axi_arvalid(instr_axi_arvalid),
    .instr_axi_arready(instr_axi_arready),
    .instr_axi_rdata(instr_axi_rdata),
    .instr_axi_rresp(instr_axi_rresp),
    .instr_axi_rvalid(instr_axi_rvalid),
    .instr_axi_rready(instr_axi_rready),
    .instr_axi_aclk(instr_axi_aclk),
    .instr_axi_aresetn(instr_axi_aresetn)
  );
endmodule
