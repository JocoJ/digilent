// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Wed Mar 27 09:50:13 2019
// Host        : DESKTOP-BP5JPAP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_myip_0_0_stub.v
// Design      : design_1_myip_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z007sclg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "myip_v1_0,Vivado 2018.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(riscv_clk, data_axi_awaddr, data_axi_awprot, 
  data_axi_awvalid, data_axi_awready, data_axi_wdata, data_axi_wstrb, data_axi_wvalid, 
  data_axi_wready, data_axi_bresp, data_axi_bvalid, data_axi_bready, data_axi_araddr, 
  data_axi_arprot, data_axi_arvalid, data_axi_arready, data_axi_rdata, data_axi_rresp, 
  data_axi_rvalid, data_axi_rready, data_axi_aclk, data_axi_aresetn, regs_axi_awaddr, 
  regs_axi_awprot, regs_axi_awvalid, regs_axi_awready, regs_axi_wdata, regs_axi_wstrb, 
  regs_axi_wvalid, regs_axi_wready, regs_axi_bresp, regs_axi_bvalid, regs_axi_bready, 
  regs_axi_araddr, regs_axi_arprot, regs_axi_arvalid, regs_axi_arready, regs_axi_rdata, 
  regs_axi_rresp, regs_axi_rvalid, regs_axi_rready, regs_axi_aclk, regs_axi_aresetn, 
  instr_axi_awaddr, instr_axi_awprot, instr_axi_awvalid, instr_axi_awready, 
  instr_axi_wdata, instr_axi_wstrb, instr_axi_wvalid, instr_axi_wready, instr_axi_bresp, 
  instr_axi_bvalid, instr_axi_bready, instr_axi_araddr, instr_axi_arprot, 
  instr_axi_arvalid, instr_axi_arready, instr_axi_rdata, instr_axi_rresp, instr_axi_rvalid, 
  instr_axi_rready, instr_axi_aclk, instr_axi_aresetn)
/* synthesis syn_black_box black_box_pad_pin="riscv_clk,data_axi_awaddr[11:0],data_axi_awprot[2:0],data_axi_awvalid,data_axi_awready,data_axi_wdata[31:0],data_axi_wstrb[3:0],data_axi_wvalid,data_axi_wready,data_axi_bresp[1:0],data_axi_bvalid,data_axi_bready,data_axi_araddr[11:0],data_axi_arprot[2:0],data_axi_arvalid,data_axi_arready,data_axi_rdata[31:0],data_axi_rresp[1:0],data_axi_rvalid,data_axi_rready,data_axi_aclk,data_axi_aresetn,regs_axi_awaddr[7:0],regs_axi_awprot[2:0],regs_axi_awvalid,regs_axi_awready,regs_axi_wdata[31:0],regs_axi_wstrb[3:0],regs_axi_wvalid,regs_axi_wready,regs_axi_bresp[1:0],regs_axi_bvalid,regs_axi_bready,regs_axi_araddr[7:0],regs_axi_arprot[2:0],regs_axi_arvalid,regs_axi_arready,regs_axi_rdata[31:0],regs_axi_rresp[1:0],regs_axi_rvalid,regs_axi_rready,regs_axi_aclk,regs_axi_aresetn,instr_axi_awaddr[11:0],instr_axi_awprot[2:0],instr_axi_awvalid,instr_axi_awready,instr_axi_wdata[31:0],instr_axi_wstrb[3:0],instr_axi_wvalid,instr_axi_wready,instr_axi_bresp[1:0],instr_axi_bvalid,instr_axi_bready,instr_axi_araddr[11:0],instr_axi_arprot[2:0],instr_axi_arvalid,instr_axi_arready,instr_axi_rdata[31:0],instr_axi_rresp[1:0],instr_axi_rvalid,instr_axi_rready,instr_axi_aclk,instr_axi_aresetn" */;
  input riscv_clk;
  input [11:0]data_axi_awaddr;
  input [2:0]data_axi_awprot;
  input data_axi_awvalid;
  output data_axi_awready;
  input [31:0]data_axi_wdata;
  input [3:0]data_axi_wstrb;
  input data_axi_wvalid;
  output data_axi_wready;
  output [1:0]data_axi_bresp;
  output data_axi_bvalid;
  input data_axi_bready;
  input [11:0]data_axi_araddr;
  input [2:0]data_axi_arprot;
  input data_axi_arvalid;
  output data_axi_arready;
  output [31:0]data_axi_rdata;
  output [1:0]data_axi_rresp;
  output data_axi_rvalid;
  input data_axi_rready;
  input data_axi_aclk;
  input data_axi_aresetn;
  input [7:0]regs_axi_awaddr;
  input [2:0]regs_axi_awprot;
  input regs_axi_awvalid;
  output regs_axi_awready;
  input [31:0]regs_axi_wdata;
  input [3:0]regs_axi_wstrb;
  input regs_axi_wvalid;
  output regs_axi_wready;
  output [1:0]regs_axi_bresp;
  output regs_axi_bvalid;
  input regs_axi_bready;
  input [7:0]regs_axi_araddr;
  input [2:0]regs_axi_arprot;
  input regs_axi_arvalid;
  output regs_axi_arready;
  output [31:0]regs_axi_rdata;
  output [1:0]regs_axi_rresp;
  output regs_axi_rvalid;
  input regs_axi_rready;
  input regs_axi_aclk;
  input regs_axi_aresetn;
  input [11:0]instr_axi_awaddr;
  input [2:0]instr_axi_awprot;
  input instr_axi_awvalid;
  output instr_axi_awready;
  input [31:0]instr_axi_wdata;
  input [3:0]instr_axi_wstrb;
  input instr_axi_wvalid;
  output instr_axi_wready;
  output [1:0]instr_axi_bresp;
  output instr_axi_bvalid;
  input instr_axi_bready;
  input [11:0]instr_axi_araddr;
  input [2:0]instr_axi_arprot;
  input instr_axi_arvalid;
  output instr_axi_arready;
  output [31:0]instr_axi_rdata;
  output [1:0]instr_axi_rresp;
  output instr_axi_rvalid;
  input instr_axi_rready;
  input instr_axi_aclk;
  input instr_axi_aresetn;
endmodule
