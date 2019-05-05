-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Mon Apr 29 18:44:37 2019
-- Host        : DESKTOP-BP5JPAP running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/Altele/Digilent/Workspace/Risc-V_onSteroids/Risc-V_onSteroids.srcs/sources_1/bd/design_1/ip/design_1_myip_0_0/design_1_myip_0_0_stub.vhdl
-- Design      : design_1_myip_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z007sclg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_myip_0_0 is
  Port ( 
    riscv_clk : in STD_LOGIC;
    data_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    data_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    data_axi_awvalid : in STD_LOGIC;
    data_axi_awready : out STD_LOGIC;
    data_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    data_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    data_axi_wvalid : in STD_LOGIC;
    data_axi_wready : out STD_LOGIC;
    data_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    data_axi_bvalid : out STD_LOGIC;
    data_axi_bready : in STD_LOGIC;
    data_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    data_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    data_axi_arvalid : in STD_LOGIC;
    data_axi_arready : out STD_LOGIC;
    data_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    data_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    data_axi_rvalid : out STD_LOGIC;
    data_axi_rready : in STD_LOGIC;
    data_axi_aclk : in STD_LOGIC;
    data_axi_aresetn : in STD_LOGIC;
    regs_axi_awaddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    regs_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    regs_axi_awvalid : in STD_LOGIC;
    regs_axi_awready : out STD_LOGIC;
    regs_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    regs_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    regs_axi_wvalid : in STD_LOGIC;
    regs_axi_wready : out STD_LOGIC;
    regs_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    regs_axi_bvalid : out STD_LOGIC;
    regs_axi_bready : in STD_LOGIC;
    regs_axi_araddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    regs_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    regs_axi_arvalid : in STD_LOGIC;
    regs_axi_arready : out STD_LOGIC;
    regs_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    regs_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    regs_axi_rvalid : out STD_LOGIC;
    regs_axi_rready : in STD_LOGIC;
    regs_axi_aclk : in STD_LOGIC;
    regs_axi_aresetn : in STD_LOGIC;
    instr_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    instr_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    instr_axi_awvalid : in STD_LOGIC;
    instr_axi_awready : out STD_LOGIC;
    instr_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    instr_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    instr_axi_wvalid : in STD_LOGIC;
    instr_axi_wready : out STD_LOGIC;
    instr_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    instr_axi_bvalid : out STD_LOGIC;
    instr_axi_bready : in STD_LOGIC;
    instr_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    instr_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    instr_axi_arvalid : in STD_LOGIC;
    instr_axi_arready : out STD_LOGIC;
    instr_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    instr_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    instr_axi_rvalid : out STD_LOGIC;
    instr_axi_rready : in STD_LOGIC;
    instr_axi_aclk : in STD_LOGIC;
    instr_axi_aresetn : in STD_LOGIC
  );

end design_1_myip_0_0;

architecture stub of design_1_myip_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "riscv_clk,data_axi_awaddr[11:0],data_axi_awprot[2:0],data_axi_awvalid,data_axi_awready,data_axi_wdata[31:0],data_axi_wstrb[3:0],data_axi_wvalid,data_axi_wready,data_axi_bresp[1:0],data_axi_bvalid,data_axi_bready,data_axi_araddr[11:0],data_axi_arprot[2:0],data_axi_arvalid,data_axi_arready,data_axi_rdata[31:0],data_axi_rresp[1:0],data_axi_rvalid,data_axi_rready,data_axi_aclk,data_axi_aresetn,regs_axi_awaddr[7:0],regs_axi_awprot[2:0],regs_axi_awvalid,regs_axi_awready,regs_axi_wdata[31:0],regs_axi_wstrb[3:0],regs_axi_wvalid,regs_axi_wready,regs_axi_bresp[1:0],regs_axi_bvalid,regs_axi_bready,regs_axi_araddr[7:0],regs_axi_arprot[2:0],regs_axi_arvalid,regs_axi_arready,regs_axi_rdata[31:0],regs_axi_rresp[1:0],regs_axi_rvalid,regs_axi_rready,regs_axi_aclk,regs_axi_aresetn,instr_axi_awaddr[11:0],instr_axi_awprot[2:0],instr_axi_awvalid,instr_axi_awready,instr_axi_wdata[31:0],instr_axi_wstrb[3:0],instr_axi_wvalid,instr_axi_wready,instr_axi_bresp[1:0],instr_axi_bvalid,instr_axi_bready,instr_axi_araddr[11:0],instr_axi_arprot[2:0],instr_axi_arvalid,instr_axi_arready,instr_axi_rdata[31:0],instr_axi_rresp[1:0],instr_axi_rvalid,instr_axi_rready,instr_axi_aclk,instr_axi_aresetn";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "myip_v1_0,Vivado 2018.2";
begin
end;
