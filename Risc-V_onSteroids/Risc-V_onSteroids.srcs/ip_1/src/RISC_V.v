/////////////////////////////////////////PC_MODULE///////////////////////////////////////////////////////////////
module PC(clk,res,write,in,out);
  
  input clk,res,write;
  input [31:0] in;
  output reg [31:0] out;
  
  always@(posedge clk) begin
    if(res)
      out<=32'b0;
    else if(write)
      out<=in;
  end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////ALU_MODULE///////////////////////////////////////////////////////
module ALU(ALUop,ina,inb,zero,out);
  
  input [3:0] ALUop;
  input [31:0] ina,inb;
  output zero;
  output reg [31:0] out;
  
  always@(*) begin
    case(ALUop)
      4'b0000: out <= ina & inb; //and
      4'b0001: out <= ina | inb; //or
      4'b0010: out <= ina + inb; //add
      4'b0011: out <= ina ^ inb; //xor
      4'b0100: out <= ina << inb[4:0]; //sll
      4'b0101: out <= ina >> inb[4:0]; //srl
      4'b0110: out <= ina - inb; //sub
      4'b0111: out <= (ina < inb) ? 32'b1 : 32'b0; //sltu
      4'b1000: out <= ($signed(ina) < $signed(inb)) ? 32'b1 : 32'b0; //slt
      4'b1001: out <= ina >>> inb[4:0]; //sra
      default: out <= 32'b0;
    endcase
  end
  
  assign zero=(out==32'b0)? 1'b1 : 1'b0;

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
 

//////////////////////////////////////////ALU_CONTROL_MODULE/////////////////////////////////////////////////
module ALUcontrol(ALUop,funct7,funct3,ALUinput);
  
  input [1:0] ALUop;
  input [6:0] funct7;
  input [2:0] funct3;
  output reg [3:0] ALUinput;
  
  always@(ALUop,funct7,funct3) begin
    casex({ALUop,funct7,funct3})
      12'b00xxxxxxxxxx: ALUinput <= 4'b0010; //ld,sd
      12'b100000000000: ALUinput <= 4'b0010; //add
      12'b100100000000: ALUinput <= 4'b0110; //sub
      12'b100000000111: ALUinput <= 4'b0000; //and
      12'b100000000110: ALUinput <= 4'b0001; //or
      12'b100000000100: ALUinput <= 4'b0011; //xor 
      12'b1x000000x101: ALUinput <= 4'b0101; //srl,srli
      12'b1x000000x001: ALUinput <= 4'b0100; //sll,slli
      12'b1x010000x101: ALUinput <= 4'b1001; //sra,srai
      12'b100000000011: ALUinput <= 4'b0111; //sltu
      12'b100000000010: ALUinput <= 4'b1000; //slt
      12'b11xxxxxxx000: ALUinput <= 4'b0010; //addi
      12'b11xxxxxxx111: ALUinput <= 4'b0000; //andi
      12'b11xxxxxxx110: ALUinput <= 4'b0001; //ori
      12'b11xxxxxxx100: ALUinput <= 4'b0011; //xori
      12'b11xxxxxxx011: ALUinput <= 4'b0111; //sltiu
      12'b11xxxxxxx010: ALUinput <= 4'b1000; //slti
      12'b01xxxxxxx00x: ALUinput <= 4'b0110; //beq,bne
      12'b01xxxxxxx10x: ALUinput <= 4'b1000; //blt,bge
      12'b01xxxxxxx11x: ALUinput <= 4'b0111; //bltu,bgeu
      default: ALUinput <= 4'b1111;
    endcase
  end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////IMM_GEN_MODULE/////////////////////////////////////////////////////
module imm_gen(in,out);
  input [31:0] in;
  output reg [31:0] out;
  always@(*) begin
    casex({in[14:12],in[6:0]})
      10'bxxx0000011: out <= {{20{in[31]}},in[31:20]}; //load instructions
      10'b0000010011: out <= {{20{in[31]}},in[31:20]}; //addi
      10'b1110010011: out <= {{20{in[31]}},in[31:20]}; //andi
      10'b1100010011: out <= {{20{in[31]}},in[31:20]}; //ori
      10'b1000010011: out <= {{20{in[31]}},in[31:20]}; //xori
      10'b0100010011: out <= {{20{in[31]}},in[31:20]}; //slti
      10'b0110010011: out <= {{20{in[31]}},in[31:20]}; //sltiu
      10'b1010010011: out <= {27'b0,in[24:20]}; //srli,srai
      10'b0010010011: out <= {27'b0,in[24:20]}; //slli
      10'bxxx0100011: out <= {{20{in[31]}},in[31:25],in[11:7]}; //store instructions
      10'bxxx1100011: out <= {{20{in[31]}},in[31],in[7],in[30:25],in[11:8]}; //beq,bne,blt,bge,bltu,bgeu
      default: out <= 32'b0;
    endcase
  end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  


////////////////////////////////////////CONTROL_PATH_MODULE///////////////////////////////////////////////////      
module control_path(opcode,control_sel,Branch,MemRead,MemtoReg,ALUop,MemWrite,ALUSrc,RegWrite, RegWrite_ext, RegWrite_multiple);
  
  input [6:0] opcode;
  input control_sel;
  output reg MemRead,MemtoReg,MemWrite,RegWrite,Branch,ALUSrc, RegWrite_ext, RegWrite_multiple;
  output reg [1:0] ALUop;
  
  always@(opcode,control_sel) begin
    casex({control_sel,opcode})
      8'b1xxxxxxx: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0000000000; //nop from hazard unit
      8'b00000000: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0000000000; //nop from ISA
	  8'b0xxxxx01: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0000000001; //custom: instruction for selecting the registers for the CLB 
	  8'b0xxxxx10: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0000000010; //custom: configure CLB control registers and CLB destination registers
      8'b00000011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b1111000000; //lw
      8'b00100011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b1000100000; //sw
      8'b00110011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0010001000; //R32-format
      8'b00010011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b1010001100; //Register32-Immediate Arithmetic Instructions
      8'b01100011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0000010100; //branch instructions
	  default:	   {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop, RegWrite_ext, RegWrite_multiple} <= 10'b0000000000; //nop from ISA
    endcase
  end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////PIPELINE_REG_MODULES///////////////////////////////////////////////////
module IF_ID_reg(clk,reset,write,pc_in,instruction_in,pc_out,instruction_out);
  
  input clk,write,reset;
  input [31:0] pc_in;
  input [31:0] instruction_in;
  
  output reg [31:0] pc_out;
  output reg [31:0] instruction_out;
  
  always@(posedge clk) begin
    if (reset) begin
      instruction_out<=32'b0;
    end
    else begin
      if(write) begin
        pc_out <= pc_in;
        instruction_out <= instruction_in;
      end
    end
  end

endmodule


module ID_EX_reg(clk,reset,write,instruction_in,
                 RegWrite_in,MemtoReg_in,MemRead_in,MemWrite_in,ALUSrc_in,Branch_in,ALUop_in,
                 pc_in,ALU_A_in,ALU_B_in,imm_in,
                 funct7_in,funct3_in,
                 rs1_in,rs2_in,rd_in,
                 
                 instruction_out,
                 RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,ALUSrc_out,Branch_out,ALUop_out,
                 pc_out,ALU_A_out,ALU_B_out,imm_out,
                 funct7_out,funct3_out,
                 rs1_out,rs2_out,rd_out,
                 
                 rs3_in,rs4_in,rs5_in,rs6_in,
                 rs3_out,rs4_out,rs5_out,rs6_out,
                 ALU_C_in, ALU_D_in, ALU_E_in, ALU_F_in,
                 ALU_C_out, ALU_D_out, ALU_E_out, ALU_F_out,
                 RegWrite_multiple_in, RegWrite_multiple_out,
                 RegWrite_ext_in,RegWrite_ext_out);
  
  input clk,write,reset;
  input [31:0] instruction_in;
  input RegWrite_in,MemtoReg_in,MemRead_in,MemWrite_in,Branch_in;
  input [1:0] ALUop_in;
  input ALUSrc_in;
  input [31:0] pc_in,ALU_A_in,ALU_B_in,imm_in;
  input [4:0] rs1_in,rs2_in,rd_in;
  input [2:0] funct3_in;
  input [6:0] funct7_in;
  input RegWrite_multiple_in,RegWrite_ext_in;
  input [4:0] rs3_in,rs4_in,rs5_in,rs6_in;
  input [31:0] ALU_C_in, ALU_D_in, ALU_E_in, ALU_F_in;

  output reg RegWrite_multiple_out,RegWrite_ext_out;
  output reg [31:0] ALU_C_out, ALU_D_out, ALU_E_out, ALU_F_out;
  output reg [31:0] instruction_out;
  output reg RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,Branch_out;
  output reg [1:0] ALUop_out;
  output reg ALUSrc_out;
  output reg [31:0] pc_out,ALU_A_out,ALU_B_out,imm_out;
  output reg [4:0] rs1_out,rs2_out,rd_out;
  output reg [2:0] funct3_out;
  output reg [6:0] funct7_out;
  output reg [4:0] rs3_out,rs4_out,rs5_out,rs6_out;
  
  always@(posedge clk) begin
    if (reset) begin
      
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
      MemRead_out <= 1'b0;
      MemWrite_out <= 1'b0;
      Branch_out <= 1'b0;
      RegWrite_multiple_out <= 1'b0;
      RegWrite_ext_out <= 1'b0;
    end
    else begin
      if (write) begin
        instruction_out <= instruction_in;
        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        ALUSrc_out <= ALUSrc_in;
        ALUop_out <= ALUop_in;
        Branch_out <= Branch_in;
        pc_out <= pc_in;
        ALU_A_out <= ALU_A_in;
        ALU_B_out <= ALU_B_in;
        imm_out <= imm_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rs3_out <= rs3_in;
        rs4_out <= rs4_in;
        rs5_out <= rs5_in;
        rs6_out <= rs6_in;
        rd_out <= rd_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
        ALU_C_out <= ALU_C_in;
        ALU_D_out <= ALU_D_in;
        ALU_E_out <= ALU_E_in;
        ALU_F_out <= ALU_F_in;
        RegWrite_multiple_out <= RegWrite_multiple_in;
        RegWrite_ext_out <= RegWrite_ext_in;
      end
    end
  end

endmodule


module EX_MEM_reg(clk,reset,write,instruction_in,
                  RegWrite_in,MemtoReg_in,MemRead_in,MemWrite_in,Branch_in,
                  pc_ex_in,pc_in,funct3_in,
                  ALU_in,zero_in,
                  reg2_data_in,
                  rs2_in,rd_in,
                  
                  instruction_out,
                  RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,Branch_out,
                  pc_ex_out,pc_out,funct3_out,
                  ALU_out,zero_out,
                  reg2_data_out,
                  rs2_out,rd_out,
                  
                  RegWrite_multiple_in, 
                  RegWrite_multiple_out,
                  RegWrite_ext_in,
                  RegWrite_ext_out);
  
  input clk,write,reset;
  input [31:0] instruction_in;
  input RegWrite_in,MemtoReg_in,MemRead_in,MemWrite_in,zero_in,Branch_in;
  input [31:0] pc_in,pc_ex_in;
  input [2:0] funct3_in;
  input [31:0] ALU_in,reg2_data_in;
  input [4:0] rs2_in,rd_in;
  input RegWrite_multiple_in,RegWrite_ext_in;

  output reg RegWrite_multiple_out,RegWrite_ext_out;
  output reg [31:0] instruction_out;
  output reg RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,zero_out,Branch_out;
  output reg [31:0] pc_out,pc_ex_out;
  output reg [2:0] funct3_out;
  output reg [31:0] ALU_out,reg2_data_out;
  output reg [4:0] rs2_out,rd_out;
    
  always@(posedge clk) begin
    if (reset) begin
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
      MemRead_out <= 1'b0;
      MemWrite_out <= 1'b0;
      Branch_out <= 1'b0;
      RegWrite_multiple_out <= 1'b0;
      RegWrite_ext_out <= 1'b0;
    end
    else begin
      if(write) begin
        instruction_out <= instruction_in;
        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        pc_out <= pc_in;
        pc_ex_out <= pc_ex_in;
        funct3_out <= funct3_in;
        zero_out <= zero_in;
        ALU_out <= ALU_in;
        reg2_data_out <= reg2_data_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        Branch_out <= Branch_in;
        RegWrite_multiple_out <= RegWrite_multiple_in;
        RegWrite_ext_out <= RegWrite_ext_in;
      end
    end
  end
endmodule


module MEM_WB_reg(clk,reset,write,
                  instruction_in,
                  RegWrite_in,MemtoReg_in,
                  PC_in,Data_in,ALU_in,rd_in,
                  
                  instruction_out,                
                  RegWrite_out,MemtoReg_out,
                  PC_out,Data_out,ALU_out,rd_out,
                  
                  RegWrite_ext_in,
                  RegWrite_ext_out,
                  RegWrite_multiple_in, 
                  RegWrite_multiple_out,
                  CLB_result1_in,
                  CLB_result2_in,
                  CLB_result3_in,
                  CLB_result1_out,
                  CLB_result2_out,
                  CLB_result3_out);
  
  input clk,write,reset;
  input [31:0] instruction_in;
  input [31:0] Data_in,ALU_in,PC_in;
  input RegWrite_in,MemtoReg_in,RegWrite_multiple_in,RegWrite_ext_in;
  input [4:0] rd_in;
  input [31:0] CLB_result1_in, CLB_result2_in, CLB_result3_in;
  
  output reg [31:0] instruction_out;
  output reg [31:0] Data_out,ALU_out,PC_out;
  output reg RegWrite_out,MemtoReg_out,RegWrite_multiple_out,RegWrite_ext_out;
  output reg [4:0] rd_out;
  output reg [31:0] CLB_result1_out, CLB_result2_out, CLB_result3_out;
  
  always@(posedge clk) begin
    if (reset) begin
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
      RegWrite_multiple_out <= 1'b0;
      RegWrite_ext_out <= 1'b0;
    end
    else begin
      if(write) begin
        instruction_out <= instruction_in;
        Data_out <= Data_in;
        ALU_out <= ALU_in;
        PC_out <= PC_in;
        RegWrite_out <= RegWrite_in;
        MemtoReg_out <= MemtoReg_in;
        rd_out <= rd_in;
        RegWrite_multiple_out <= RegWrite_multiple_in;
        RegWrite_ext_out <= RegWrite_ext_in;
        CLB_result1_out <= CLB_result1_in;
        CLB_result2_out <= CLB_result2_in;
        CLB_result3_out <= CLB_result3_in;
      end
    end
  end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////FORWARDING_MODULE/////////////////////////////////////////////////////
module forwarding(rs1,rs2,ex_mem_rd,mem_wb_rd,ex_mem_regwrite,mem_wb_regwrite,forwardA,forwardB);
  
  input [4:0] rs1,rs2,ex_mem_rd,mem_wb_rd;
  input ex_mem_regwrite,mem_wb_regwrite;
  
  output reg [1:0] forwardA,forwardB;
  
  always@(*) begin
  
    if(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == rs1)) //EX hazard rs1
      forwardA <= 2'b10;
    else if(mem_wb_regwrite && (mem_wb_rd != 5'b0) && 
                          !(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == rs1)) && 
                          (mem_wb_rd == rs1)) //MEM hazard rs1
      forwardA <= 2'b01;
    else
      forwardA <= 2'b00; //no hazard  
    
    if(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == rs2)) //EX hazard rs2
      forwardB <= 2'b10;
   
    else if(mem_wb_regwrite && (mem_wb_rd != 5'b0) && 
                          !(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == rs2)) &&
                          (mem_wb_rd == rs2)) //MEM hazard rs1
      forwardB <= 2'b01;
    else
      forwardB <= 2'b00; //no hazard
      
  end
endmodule


module load_store_forwarding(store_rs2,load_rd,MemWrite,MemtoReg,forwardC);
  
  input MemWrite,MemtoReg;
  input [4:0] store_rs2,load_rd;
  output reg forwardC;
  
  always@(*) begin
    if (MemWrite && MemtoReg && (store_rs2 == load_rd)) //load hazard
      forwardC <= 1'b1;
    else
      forwardC <= 1'b0;
  end

endmodule

module clb_forwarding(input [4:0] rd1,
                      input [4:0] rd2,
                      input [4:0] rd3,
                      input [4:0] rs1,
                      input [4:0] rs2,
                      input [4:0] rs3,
                      input [4:0] rs4,
                      input [4:0] rs5,
                      input [4:0] rs6,
                      input clb_write,
                      output reg [1:0] forward1,
                      output reg [1:0] forward2,
                      output reg [1:0] forward3,
                      output reg [1:0] forward4,
                      output reg [1:0] forward5,
                      output reg [1:0] forward6);
                      
    always@(*) begin
        if(clb_write && (rd1!=5'b0) && (rs1==rd1))
            forward1 <= 2'b01;
        else if(clb_write && (rd2!=5'b0) && (rs1==rd2))
            forward1 <= 2'b10;
        else if(clb_write && (rd3!=5'b0) && (rs1==rd3))
            forward1 <= 2'b11;
        else
            forward1 <= 2'b00;
            
        if(clb_write && (rd1!=5'b0) && (rs2==rd1))
            forward2 <= 2'b01;
        else if(clb_write && (rd2!=5'b0) && (rs2==rd2))
            forward2 <= 2'b10;
        else if(clb_write && (rd3!=5'b0) && (rs2==rd3))
            forward2 <= 2'b11;
        else
            forward2 <= 2'b00;
            
        if(clb_write && (rd1!=5'b0) && (rs3==rd1))
            forward3 <= 2'b01;
        else if(clb_write && (rd2!=5'b0) && (rs3==rd2))
            forward3 <= 2'b10;
        else if(clb_write && (rd3!=5'b0) && (rs3==rd3))
            forward3 <= 2'b11;
        else
            forward3 <= 2'b00;
            
        if(clb_write && (rd1!=5'b0) && (rs4==rd1))
            forward4 <= 2'b01;
        else if(clb_write && (rd2!=5'b0) && (rs4==rd2))
            forward4 <= 2'b10;
        else if(clb_write && (rd3!=5'b0) && (rs4==rd3))
            forward4 <= 2'b11;
        else
            forward4 <= 2'b00;
            
        if(clb_write && (rd1!=5'b0) && (rs5==rd1))
            forward5 <= 2'b01;
        else if(clb_write && (rd2!=5'b0) && (rs5==rd2))
            forward5 <= 2'b10;
        else if(clb_write && (rd3!=5'b0) && (rs5==rd3))
            forward5 <= 2'b11;
        else
            forward5 <= 2'b00;
            
        if(clb_write && (rd1!=5'b0) && (rs6==rd1))
            forward6 <= 2'b01;
        else if(clb_write && (rd2!=5'b0) && (rs6==rd2))
            forward6 <= 2'b10;
        else if(clb_write && (rd3!=5'b0) && (rs6==rd3))
            forward6 <= 2'b11;
        else
            forward6 <= 2'b00;
    end
                      
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////HAZARD_DETECTION_UNIT///////////////////////////////////////////////
module hazard_detection(rd,rs1,rs2,MemRead,PCwrite,IF_IDwrite,control_sel);
  input [4:0] rd,rs1,rs2;
  input MemRead;
  output reg PCwrite,IF_IDwrite,control_sel;
  
  always@(*) begin
    if(MemRead && ((rd==rs1) || (rd==rs2))) begin
      PCwrite <= 1'b0;
      IF_IDwrite <= 1'b0;
      control_sel <= 1'b1;
    end
    else begin
      PCwrite <= 1'b1;
      IF_IDwrite <= 1'b1;
      control_sel <= 1'b0;
    end
  end
          
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

module counter(clk,reset,write,out);
    input clk,reset,write;
    output [63:0] out;
    reg [63:0] cnt;
    always@(posedge clk) begin
        if(reset)
            cnt <= 64'b0;
        else if(write)
            cnt <= cnt + 1'b1;
    end
    assign out = cnt;
endmodule

//////////////////////////////////////////////RISC-V_MODULE///////////////////////////////////////////////////
//(* DONT_TOUCH = "true" *)
module RISC_V(input clk,
              output [9:0] instruction_address,
              input [31:0] instruction,
              
              output write_enable_basic,		// I: write enable for the single port mode
              output write_enable_conf,        // I: write enable for the configuration registers (32->36)
              output write_enable_CLB,        // I: write enable for multiport mode
              output [5:0] read_addr1,                // I: read addresses
              output [5:0] read_addr2,
              output [5:0] read_addr3,
              output [5:0] read_addr4,
              output [5:0] read_addr5,
              output [5:0] read_addr6,
              output [5:0] write_addr,                // I: write address for single port mode (NOTE: multiport writing addresses are handled by the configuration registers)
              output [5:0] write_addr_conf,        // I: write address for the configuration registers
              output [31:0] write_data1,            // I: write data for both single port and multiport modes
              output [31:0] write_data2,            // I: write data for multiport mode only
              output [31:0] write_data3,            // I: write data for multiport mode only
              output [31:0] write_data_conf,       // I: write data for the configuration registers
              input [31:0] read_data1,                // O: output data from the regFile
              input [31:0] read_data2,
              input [31:0] read_data3,
              input [31:0] read_data4,
              input [31:0] read_data5,
              input [31:0] read_data6,
              input [31:0] CLB_conf1,                // O: outputs for the CHM
              input [31:0] CLB_conf2,
              input [31:0] CLB_conf3,
              input [31:0] CLB_conf4,
              input [31:0] CLB_conf5,
              
              output [31:0] buff0,
              output [31:0] buff1,
              output [31:0] buff2,
              output [31:0] buff3,
              
              output MemRead,
              output MemWrite,
              output [4:0] funct3,
              output [9:0] data_address,
              output [31:0] data_write,
              input [31:0] data_read,
              
              output [31:0] pc_if,
              output [31:0] pc_id,
              output [31:0] pc_ex,
              output [31:0] pc_mem,
              output [31:0] pc_wb,
              
              output reg CSR_write,
              output reg autostop,
              output reg pause,
              input [2:0] CSR,
              output [63:0] timestamp);
  
  //CSR[0]=RESET
  //CSR[1]=PAUSE
  //////////////////////////////////////////IF signals////////////////////////////////////////////////////////
  wire [31:0] PC_IF; assign pc_if = PC_IF;               //current PC
  wire [31:0] PC_4_IF;             //PC+4 in IF stage
  wire [31:0] PC_MUX;
  wire [31:0] INSTRUCTION_IF;
  wire [31:0] IMM_IF;
  wire branch_taken;
  assign INSTRUCTION_IF = instruction;
  assign instruction_address = PC_IF[11:2];
  
  //////////////////////////////////////////ID signals////////////////////////////////////////////////////////
  wire [31:0] PC_ID; assign pc_id = PC_ID;
  wire [31:0] INSTRUCTION_ID;
  wire [31:0] IMM_ID;
  wire [31:0] REG_DATA1_ID,REG_DATA2_ID;
  wire RegWrite_ID,MemtoReg_ID,MemRead_ID,MemWrite_ID;
  wire [1:0] ALUop_ID;
  wire ALUSrc_ID;
  wire Branch_ID; 
  wire pipeline_stall;
  
  wire [2:0] FUNCT3_ID; assign FUNCT3_ID = INSTRUCTION_ID[14:12];
  wire [6:0] FUNCT7_ID; assign FUNCT7_ID = INSTRUCTION_ID[31:25];
  wire [6:0] OPCODE; assign OPCODE = INSTRUCTION_ID[6:0];
  wire [4:0] RD_ID; assign RD_ID = INSTRUCTION_ID[11:7];
 
  wire RegWrite_multiple_ID;	// bit to signal multiport writing from the CHM
  wire RegWrite_ext_ID;         // bit to signal writing to the extended part of the register file (registers 32->63)
  
  wire [5:0] RS1_ID; assign RS1_ID = {1'b0, INSTRUCTION_ID[19:15]};
  wire [5:0] RS2_ID; assign RS2_ID = {1'b0, INSTRUCTION_ID[24:20]};
  wire [5:0] RS3_ID; assign RS3_ID = {1'b0, INSTRUCTION_ID[31:27]};                            // third address input to the regFile
  wire [5:0] RS4_ID; assign RS4_ID = {1'b0, INSTRUCTION_ID[26:25], INSTRUCTION_ID[14:12]};    // fourth address input to the regFile
  wire [5:0] RS5_ID; assign RS5_ID = {1'b0, INSTRUCTION_ID[11:7]};                            // fifth address input to the regFile
  wire [5:0] RS6_ID; assign RS6_ID = {1'b0, INSTRUCTION_ID[6:2]};                            // sixth address input to the regFile
   
  wire [31:0] REG_DATA3_ID, REG_DATA4_ID, REG_DATA5_ID, REG_DATA6_ID;    // multiport regFile data outputs
  wire IF_ID_write,PC_write;
  
  //////////////////////////////////////////EX signals////////////////////////////////////////////////////////
  wire [31:0] INSTRUCTION_EX;
  wire [31:0] PC_EX,PC_Branch; assign pc_ex= PC_EX;
  wire [31:0] IMM_EX;
  wire [31:0] REG_DATA1_EX,REG_DATA2_EX;
  wire RegWrite_EX,MemtoReg_EX,MemRead_EX,MemWrite_EX;
  wire Branch_EX;
  wire [1:0] ALUop_EX;
  wire ALUSrc_EX;
  wire [2:0] FUNCT3_EX;
  wire [6:0] FUNCT7_EX;
  wire [4:0] RD_EX;
  wire [4:0] RS1_EX;
  wire [4:0] RS2_EX;
  wire [4:0] RS3_EX;
  wire [4:0] RS4_EX;
  wire [4:0] RS5_EX;
  wire [4:0] RS6_EX;
    
  wire [31:0] ALU_OUT_EX;
  wire [3:0] ALU_control;
  wire ZERO_EX;
  wire [1:0] forwardA,forwardB;
  wire [31:0] MUX_A_EX,MUX_B_EX;
  wire [31:0] RS2_IMM_EX;
  
  wire [31:0] REG_DATA3_EX, REG_DATA4_EX, REG_DATA5_EX, REG_DATA6_EX;
  wire RegWrite_multiple_EX;
  wire RegWrite_ext_EX;
  //////////////////////////////////////////MEM signals////////////////////////////////////////////////////////
  wire [31:0] INSTRUCTION_MEM;
  wire RegWrite_MEM,MemtoReg_MEM,MemRead_MEM,MemWrite_MEM;
  wire Branch_MEM;
  wire [31:0] PC_MEM, PC_MEMORY; assign pc_mem=PC_MEMORY;
  wire [31:0] REG_DATA2_MEM;
  wire [4:0] RS2_MEM;
  wire [4:0] RD_MEM;
  wire [31:0] ALU_OUT_MEM;
  wire ZERO_MEM;
  wire [2:0] FUNCT3_MEM;
  
  wire beq; assign beq = ZERO_MEM & (~FUNCT3_MEM[2]) & (~FUNCT3_MEM[1]) & (~FUNCT3_MEM[0]);
  wire bne; assign bne = (~ZERO_MEM) & (~FUNCT3_MEM[2]) & (~FUNCT3_MEM[1]) & FUNCT3_MEM[0];
  wire blt; assign blt = ALU_OUT_MEM[0] & FUNCT3_MEM[2] & (~FUNCT3_MEM[0]);
  wire bge; assign bge = (~ALU_OUT_MEM[0]) & FUNCT3_MEM[2] & FUNCT3_MEM[0];
  
  wire [31:0] DATA_MEMORY_MEM;
  wire forwardC;
  wire [31:0] MUX_C_MEM;
  
  wire [31:0] CLB_result1_MEM, CLB_result2_MEM, CLB_result3_MEM;
  wire RegWrite_multiple_MEM;
  wire RegWrite_ext_MEM;
  
  assign funct3 = {FUNCT3_MEM,ALU_OUT_MEM[1:0]};
  assign MemRead = MemRead_MEM;
  assign MemWrite = MemWrite_MEM;
  assign data_address = ALU_OUT_MEM[11:2];
  assign data_write = MUX_C_MEM;
  assign DATA_MEMORY_MEM = data_read;
  
  //////////////////////////////////////////WB signals////////////////////////////////////////////////////////
  wire [31:0] INSTRUCTION_WB;
  wire RegWrite_WB,MemtoReg_WB;
  wire [31:0] PC_WB; assign pc_wb = PC_WB;
  wire [31:0] DATA_MEMORY_WB;
  wire [31:0] ALU_OUT_WB;
  wire [31:0] ALU_DATA_WB;
  wire [4:0] RD_WB;
  
  wire [31:0] CLB_result1_WB, CLB_result2_WB, CLB_result3_WB;
  wire RegWrite_multiple_WB;
  wire RegWrite_ext_WB;
  
  //////////////////////////////////////pipeline registers////////////////////////////////////////////////////
  
  IF_ID_reg IF_ID_REGISTER(clk,CSR[0] | (Branch_MEM & ~branch_taken),
                           IF_ID_write&(~CSR[1]),
                           PC_IF,INSTRUCTION_IF,
                           PC_ID,INSTRUCTION_ID);
  
  ID_EX_reg ID_EX_REGISTER(clk,CSR[0] | (Branch_MEM & ~branch_taken),~CSR[1],
                           INSTRUCTION_ID,
                           RegWrite_ID,MemtoReg_ID,MemRead_ID,MemWrite_ID,ALUSrc_ID,Branch_ID,ALUop_ID,
                           PC_ID,REG_DATA1_ID,REG_DATA2_ID,IMM_ID,
                           FUNCT7_ID,FUNCT3_ID,
                           RS1_ID[4:0],RS2_ID[4:0],RD_ID,
                                 
                           INSTRUCTION_EX,
                           RegWrite_EX,MemtoReg_EX,MemRead_EX,MemWrite_EX,ALUSrc_EX,Branch_EX,ALUop_EX,
                           PC_EX,REG_DATA1_EX,REG_DATA2_EX,IMM_EX,
                           FUNCT7_EX,FUNCT3_EX,
                           RS1_EX,RS2_EX,RD_EX,
                           
                           RS3_ID[4:0],RS4_ID[4:0],RS5_ID[4:0],RS6_ID[4:0],
                           RS3_EX,RS4_EX,RS5_EX,RS6_EX,                              
                           REG_DATA3_ID, REG_DATA4_ID, REG_DATA5_ID, REG_DATA6_ID,
                           REG_DATA3_EX, REG_DATA4_EX, REG_DATA5_EX, REG_DATA6_EX,
                           RegWrite_multiple_ID, RegWrite_multiple_EX,
                           RegWrite_ext_ID,RegWrite_ext_EX);
  
  EX_MEM_reg EX_MEM_REGISTER(clk,CSR[0] | (Branch_MEM & ~branch_taken),~CSR[1],
                             INSTRUCTION_EX,
                             RegWrite_EX,MemtoReg_EX,MemRead_EX,MemWrite_EX,Branch_EX,
                             PC_EX,PC_Branch,FUNCT3_EX,
                             ALU_OUT_EX,ZERO_EX,
                             MUX_B_EX,
                             RS2_EX,RD_EX,
                                 
                             INSTRUCTION_MEM,
                             RegWrite_MEM,MemtoReg_MEM,MemRead_MEM,MemWrite_MEM,Branch_MEM,
                             PC_MEMORY,PC_MEM,FUNCT3_MEM,
                             ALU_OUT_MEM,ZERO_MEM,
                             REG_DATA2_MEM,
                             RS2_MEM,RD_MEM,
                                                           
                             RegWrite_multiple_EX,
                             RegWrite_multiple_MEM,
                             RegWrite_ext_EX,
                             RegWrite_ext_MEM);
  
  MEM_WB_reg MEM_WB_REGISTER(clk,CSR[0],~CSR[1],INSTRUCTION_MEM,
                             RegWrite_MEM,MemtoReg_MEM,
                             PC_MEMORY,
                             DATA_MEMORY_MEM,
                             ALU_OUT_MEM,
                             RD_MEM,
                                  
                             INSTRUCTION_WB,
                             RegWrite_WB,MemtoReg_WB,
                             PC_WB,
                             DATA_MEMORY_WB,
                             ALU_OUT_WB,
                             RD_WB,
                             
                             RegWrite_ext_MEM,
                             RegWrite_ext_WB,                    
                             RegWrite_multiple_MEM,
                             RegWrite_multiple_WB,
                             CLB_result1_MEM,
                             CLB_result2_MEM,
                             CLB_result3_MEM,
                             CLB_result1_WB,
                             CLB_result2_WB,
                             CLB_result3_WB);
                                        
  
  ///////////////////////////////////////////IF data path/////////////////////////////////////////////////////////
  
  PC PC_MODULE(clk,CSR[0],PC_write&(~CSR[1]),PC_MUX,PC_IF); //current PC
  
  assign IMM_IF = {{19{INSTRUCTION_IF[31]}},INSTRUCTION_IF[31],INSTRUCTION_IF[7],INSTRUCTION_IF[30:25],INSTRUCTION_IF[11:8],1'b0};
   
  assign PC_4_IF = (INSTRUCTION_IF[6:0]==7'b1100011) ? PC_IF+IMM_IF : PC_IF+32'h4;
   
  assign branch_taken = (beq|bne|blt|bge);
   
  assign PC_MUX = ((Branch_MEM & ~branch_taken)==1'b0) ? PC_4_IF : PC_MEM;              
   
  ///////////////////////////////////////////ID data path/////////////////////////////////////////////////////////
  
  control_path CONTROL_PATH_MODULE(OPCODE,         
                                   pipeline_stall, //hazard detection signal 
                                   Branch_ID,MemRead_ID,MemtoReg_ID,
                                   ALUop_ID,MemWrite_ID,ALUSrc_ID,RegWrite_ID,
                                   RegWrite_ext_ID,
                                   RegWrite_multiple_ID);
                                                             
                                                           
  assign write_data1 = (RegWrite_multiple_WB) ? CLB_result1_WB : ALU_DATA_WB;
  assign write_data2 = CLB_result2_WB;
  assign write_data3 = CLB_result3_WB;
  
  assign read_addr1 = RS1_ID;
  assign read_addr2 = RS2_ID;
  assign read_addr3 = RS3_ID;
  assign read_addr4 = RS4_ID;
  assign read_addr5 = RS5_ID;
  assign read_addr6 = RS6_ID;
  assign write_addr=({1'b0, RD_WB});
  
  assign write_enable_conf=RegWrite_ext_WB;
  assign write_enable_basic=RegWrite_WB; 
  assign write_enable_CLB=RegWrite_multiple_WB;
  
  assign REG_DATA1_ID =  read_data1;
  assign REG_DATA2_ID =  read_data2;
  assign REG_DATA3_ID =  read_data3;
  assign REG_DATA4_ID =  read_data4;
  assign REG_DATA5_ID =  read_data5;
  assign REG_DATA6_ID =  read_data6;
                                                                 
  imm_gen IMM_GEN_MODULE(INSTRUCTION_ID,IMM_ID);
  
  hazard_detection HAZARD_DETECTION_UNIT(RD_EX,  //ID_EX.rd
                                         RS1_ID[4:0], //IF_ID.rs1
                                         RS2_ID[4:0], //IF_ID.rs2
                                         MemRead_EX,   //ID_EX.MemRead
                                         PC_write,IF_ID_write,
                                         pipeline_stall);
                                
                                         
  ///////////////////////////////////////////EX data path/////////////////////////////////////////////////////////                                       
  
  wire [1:0] forward1,forward2,forward3,forward4,forward5,forward6;
  wire [31:0] data1, data2, data3, data4, data5, data6;
  
  assign data1 = (forward1 == 2'b01) ? CLB_result1_WB :
                 (forward1 == 2'b10) ? CLB_result2_WB :
                 (forward1 == 2'b11) ? CLB_result3_WB : REG_DATA1_EX;
                 
  assign data2 = (forward2 == 2'b01) ? CLB_result1_WB :
                 (forward2 == 2'b10) ? CLB_result2_WB :
                 (forward2 == 2'b11) ? CLB_result3_WB : REG_DATA2_EX;
                 
  assign data3 = (forward3 == 2'b01) ? CLB_result1_WB :
                 (forward3 == 2'b10) ? CLB_result2_WB :
                 (forward3 == 2'b11) ? CLB_result3_WB : REG_DATA3_EX;
                 
  assign data4 = (forward4 == 2'b01) ? CLB_result1_WB :
                 (forward4 == 2'b10) ? CLB_result2_WB :
                 (forward4 == 2'b11) ? CLB_result3_WB : REG_DATA4_EX;
                 
  assign data5 = (forward5 == 2'b01) ? CLB_result1_WB :
                 (forward5 == 2'b10) ? CLB_result2_WB :
                 (forward5 == 2'b11) ? CLB_result3_WB : REG_DATA5_EX;
                                  
  assign data6 = (forward6 == 2'b01) ? CLB_result1_WB :
                 (forward6 == 2'b10) ? CLB_result2_WB :
                 (forward6 == 2'b11) ? CLB_result3_WB : REG_DATA6_EX;
                 
  ALU ALU_MODULE(ALU_control,
                 MUX_A_EX,RS2_IMM_EX,
                 ZERO_EX,ALU_OUT_EX);
  
  ALUcontrol ALU_CONTROL_MODULE(ALUop_EX,    //ALUop
                                FUNCT7_EX,    //funct7
                                FUNCT3_EX,    //funct3
                                ALU_control);
  
  assign RS2_IMM_EX = (ALUSrc_EX == 1'b1) ? IMM_EX : MUX_B_EX;
                    
  assign PC_Branch = PC_EX + 32'h4;  //imm already shifted for branch address
                    
                  
  forwarding FORWARDING_UNIT(RS1_EX, //rs1
                             RS2_EX,  //rs2
                             RD_MEM,     //ex_mem_rd
                             RD_WB,     //mem_wb_rd
                             RegWrite_MEM,     //ex_mem_regwrite
                             RegWrite_WB,     //mem_wb_regwrite
                             forwardA,forwardB);
  
  assign MUX_A_EX = (forwardA == 2'b00) ? data1 : 
                    (forwardA == 2'b01) ? ALU_DATA_WB : 
                    (forwardA == 2'b10) ? ALU_OUT_MEM : 32'b0;
                      
  assign MUX_B_EX = (forwardB == 2'b00) ? data2 : 
                    (forwardB == 2'b01) ? ALU_DATA_WB : 
                    (forwardB == 2'b10) ? ALU_OUT_MEM : 32'b0;  
   
  wire [4:0] rd1,rd2,rd3;
  assign rd1 = CLB_conf1[31:27];
  assign rd2 = CLB_conf2[31:27];
  assign rd3 = CLB_conf3[31:27]; 
  clb_forwarding CLB_FRWD(rd1,
                          rd2,
                          rd3,
                          RS1_EX,
                          RS2_EX,
                          RS3_EX,
                          RS4_EX,
                          RS5_EX,
                          RS6_EX,
                          RegWrite_multiple_WB,
                          forward1,
                          forward2,
                          forward3,
                          forward4,
                          forward5,
                          forward6);
                    
  // All selection bits are taken from the CLB_conf nets
  CLB_full  CustomHardwareModule(.register_clk(clk),
                                 .register_reset(CSR[0]),
                                 .register_par_load(~CSR[1]),
                                 .result_sel({CLB_conf2[0], CLB_conf3[0]}),
                                                   
                                 .in0(data1), .in1(data2),
                                 .in2(data3), .in3(data4),
                                 .in4(data5), .in5(data6),
                                 .in6(32'b0), .in7(32'hffff_ffff),
                                                   
                                 .bypass_0({CLB_conf4[7:6], CLB_conf5[7:6]}),
                                 .bypass_1({CLB_conf4[5:4], CLB_conf5[5:4]}),
                                 .bypass_2({CLB_conf4[3:2], CLB_conf5[3:2]}),
                                 .bypass_3({CLB_conf4[1:0], CLB_conf5[1:0]}),
                                                   
                                 .sel0_00(CLB_conf1[23:21]),
                                 .sel0_10(CLB_conf1[20:18]),
                                 .sel0_20(CLB_conf1[17:15]),
                                 .sel0_30(CLB_conf1[14:12]),
                                 .sel1_00(CLB_conf1[11:9]),
                                 .sel1_10(CLB_conf1[8:6]),
                                 .sel1_20(CLB_conf1[5:3]),
                                 .sel1_30(CLB_conf1[2:0]),
                                                   
                                 .sel0_01(CLB_conf2[24:23]),
                                 .sel0_02(CLB_conf2[22:21]),
                                 .sel0_03(CLB_conf2[20:19]),
                                 .sel0_11(CLB_conf2[18:17]),
                                 .sel0_12(CLB_conf2[16:15]),
                                 .sel0_13(CLB_conf2[14:13]),
                                                   
                                 .sel1_01(CLB_conf2[12:11]),
                                 .sel1_02(CLB_conf2[10:9]),
                                 .sel1_03(CLB_conf2[8:7]),
                                 .sel1_11(CLB_conf2[6:5]),
                                 .sel1_12(CLB_conf2[4:3]),
                                 .sel1_13(CLB_conf2[2:1]),
                                                   
                                 .sel0_21(CLB_conf3[24:23]),
                                 .sel0_22(CLB_conf3[22:21]),
                                 .sel0_23(CLB_conf3[20:19]),
                                 .sel0_31(CLB_conf3[18:17]),
                                 .sel0_32(CLB_conf3[16:15]),
                                 .sel0_33(CLB_conf3[14:13]),
                                                   
                                 .sel1_21(CLB_conf3[12:11]),
                                 .sel1_22(CLB_conf3[10:9]),
                                 .sel1_23(CLB_conf3[8:7]),
                                 .sel1_31(CLB_conf3[6:5]),
                                 .sel1_32(CLB_conf3[4:3]),
                                 .sel1_33(CLB_conf3[2:1]),
                                                   
                                 .selOp_00(CLB_conf4[23:22]),
                                 .selOp_01(CLB_conf4[21:20]),
                                 .selOp_02(CLB_conf4[19:18]),
                                 .selOp_03(CLB_conf4[17:16]),
                                                   
                                 .selOp_10(CLB_conf4[15:14]),
                                 .selOp_11(CLB_conf4[13:12]),
                                 .selOp_12(CLB_conf4[11:10]),
                                 .selOp_13(CLB_conf4[9:8]),
                                                   
                                 .selOp_20(CLB_conf5[23:22]),
                                 .selOp_21(CLB_conf5[21:20]),
                                 .selOp_22(CLB_conf5[19:18]),
                                 .selOp_23(CLB_conf5[17:16]),
                                                   
                                 .selOp_30(CLB_conf5[15:14]),
                                 .selOp_31(CLB_conf5[13:12]),
                                 .selOp_32(CLB_conf5[11:10]),
                                 .selOp_33(CLB_conf5[9:8]),
                                 
                                 .buff0(buff0),
                                 .buff1(buff1),
                                 .buff2(buff2),
                                 .buff3(buff3),
                                                   
                                 .result0(CLB_result1_MEM),
                                 .result1(CLB_result2_MEM),
                                 .result2(CLB_result3_MEM)
                                 );              
                      
  ///////////////////////////////////////////MEM data path/////////////////////////////////////////////////////////
  load_store_forwarding LD_SD_FORWARDING(RS2_MEM,
                                         RD_WB,
                                         MemWrite_MEM,
                                         MemtoReg_WB,
                                         forwardC);
                                         
  assign MUX_C_MEM = (forwardC == 1'b1) ? DATA_MEMORY_WB : REG_DATA2_MEM; 
                        
                                                  
  ///////////////////////////////////////////MEM data path/////////////////////////////////////////////////////////
  
  assign ALU_DATA_WB = (MemtoReg_WB == 1'b1) ? DATA_MEMORY_WB : ALU_OUT_WB;
  
  wire [5:0] conf_addr;	// auto-updating address for the CHM configuration registers in the regFile
  address_counter conf_addr_cnt(.clk(clk), .res(CSR[0]), .cnt(RegWrite_ext_WB), .address(conf_addr));    // address generator for the CHM configuration registers
  assign write_addr_conf=conf_addr;
                                                                  
  // The configuration data is taken directly from the instruction field (the 30 MSB), and the arrangement of the bits depends on the destination register
  assign write_data_conf = (conf_addr == 32) ? {INSTRUCTION_WB[31:27], 3'b000, INSTRUCTION_WB[25:2]} :
                           (conf_addr == 33 || conf_addr == 34) ? {INSTRUCTION_WB[31:27], 2'b00, INSTRUCTION_WB[26:2]}:
                           (conf_addr == 35 || conf_addr == 36) ? {8'b0000_0000, INSTRUCTION_WB[25:2]} : 32'b0;
                                                                   
                                                     
                      
  //////////////////////////////////////////////OTHER STUFF/////////////////////////////////////////////////////////////
  
  counter TIMER(clk,CSR[0],~CSR[1],timestamp);
  
  wire halt_loop;
  assign halt_loop = (INSTRUCTION_WB==32'h00000063);
  
  always@(posedge clk) begin
   if(CSR[0]) begin
       pause <= 1'b1;
       autostop <= 1'b0;
       CSR_write <= 1'b0;
    end
   if(CSR[2]==1'b1 || halt_loop) begin
       autostop <= 1'b0;
       pause <= 1'b1;
       CSR_write <= 1'b1;
    end
    else begin
       pause <= CSR[1];
       autostop <= CSR[2];
       CSR_write <= 1'b0;
    end
  end
  
                                                                   
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////