

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

      

///////////////////////////////////////INSTRUCTION_MEMORY/////////////////////////////////////////////////////
/*module instruction_memory(address, instruction);
  
  input [9:0] address;
  output reg [31:0] instruction;
  reg [31:0] codeMemory [0:1023];
  
  initial $readmemh("code.mem", codeMemory);
  
  always@(address) begin
    instruction <= codeMemory[address];
  end

endmodule*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////ADDER_MODULE//////////////////////////////////////////////////////
module adder(ina,inb,out);
  input [31:0] ina,inb;
  output reg [31:0] out;
  
  always@(ina,inb) begin
    out <= ina+inb;
  end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////REGISTER_FILE_MODULE///////////////////////////////////////////////////////
/*module registers(clk,reg_write,read_reg1,read_reg2,write_reg,write_data,read_data1,read_data2);
  
  input clk,reg_write;
  input [4:0] read_reg1,read_reg2,write_reg;
  input [31:0] write_data;
  output [31:0] read_data1,read_data2;
  reg [31:0] Registers [0:31];
  
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      Registers[i] = i;
    end
  end
  
  always@(posedge clk) begin
    if(reg_write)
      Registers[write_reg] <= write_data;
  end
  
  assign read_data1 = (read_reg1 != 5'b0) ? //it is different from x0
                      (((reg_write == 1'b1)&&(read_reg1 == write_reg)) ? 
                      write_data : Registers[read_reg1]) : 32'b0;
                      
  assign read_data2 = (read_reg2 != 5'b0) ? //it is different from x0
                      (((reg_write == 1'b1)&&(read_reg2 == write_reg)) ? 
                      write_data : Registers[read_reg2]) : 32'b0;

endmodule*/
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



//////////////////////////////////////////MUX_2_1_MODULE/////////////////////////////////////////////////////
module mux2_1(ina,inb,sel,out);
  
  input [31:0] ina,inb;
  input sel;
  output [31:0] out;
  
  assign out=(sel==1'b0) ? ina : inb;

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////MUX_4_1_MODULE/////////////////////////////////////////////////////
module mux4_1(ina,inb,inc,ind,sel,out);
  
  input [31:0] ina,inb,inc,ind;
  input [1:0] sel;
  output reg [31:0] out;
  
  always@(ina,inb,inc,ind,sel) begin
    case(sel)
      2'b00: out = ina;
      2'b01: out = inb;
      2'b10: out = inc;
      2'b11: out = ind;
    endcase
  end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

 

////////////////////////////////////////////DATA_MEMORY///////////////////////////////////////////////////////
/*module data_memory(clk,mem_read,mem_write,address,write_data,read_data); 
  
  input clk,mem_read,mem_write;
  input [9:0] address;
  input [31:0] write_data;
  output [31:0] read_data;
  reg [31:0] DataMemory [0:1023];
  
  integer i;
  initial begin
    for (i = 0; i < 1024; i = i + 1) begin
      DataMemory[i] = 32'b0;
    end
  end
  
  always@(posedge clk) begin
    if(mem_write)
      DataMemory[address] <= write_data;
  end
  
  assign read_data = (mem_read==1'b1) ? DataMemory[address] : 32'b0;  
  
endmodule*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
  


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
module control_path(opcode,control_sel,Branch,MemRead,MemtoReg,ALUop,MemWrite,ALUSrc,RegWrite);
  
  input [6:0] opcode;
  input control_sel;
  output reg MemRead,MemtoReg,MemWrite,RegWrite,Branch,ALUSrc;
  output reg [1:0] ALUop;
  
  always@(opcode,control_sel) begin
    casex({control_sel,opcode})
      8'b1xxxxxxx: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b00000000; //nop from hazard unit
      8'b00000011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b11110000; //lw
      8'b00100011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b10001000; //sw
      8'b00110011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b00100010; //R32-format
      8'b00010011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b10100011; //Register32-Immediate Arithmetic Instructions
      8'b01100011: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b00000101; //branch instructions
      default: {ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUop} <= 8'b0;
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
      pc_out<=32'b0;
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
                 rs1_out,rs2_out,rd_out);
  
  input clk,write,reset;
  input [31:0] instruction_in;
  input RegWrite_in,MemtoReg_in,MemRead_in,MemWrite_in,Branch_in;
  input [1:0] ALUop_in;
  input ALUSrc_in;
  input [31:0] pc_in,ALU_A_in,ALU_B_in,imm_in;
  input [4:0] rs1_in,rs2_in,rd_in;
  input [2:0] funct3_in;
  input [6:0] funct7_in;

  output reg [31:0] instruction_out;
  output reg RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,Branch_out;
  output reg [1:0] ALUop_out;
  output reg ALUSrc_out;
  output reg [31:0] pc_out,ALU_A_out,ALU_B_out,imm_out;
  output reg [4:0] rs1_out,rs2_out,rd_out;
  output reg [2:0] funct3_out;
  output reg [6:0] funct7_out;
  
  always@(posedge clk) begin
    if (reset) begin
      instruction_out <= 32'b0;
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
      MemRead_out <= 1'b0;
      MemWrite_out <= 1'b0;
      ALUSrc_out <= 1'b0;
      ALUop_out <= 2'b0;
      Branch_out <= 1'b0;
      pc_out <= 32'b0;
      ALU_A_out <= 32'b0;
      ALU_B_out <= 32'b0;
      imm_out <= 32'b0;
      rs1_out <= 5'b0;
      rs2_out <= 5'b0;
      rd_out <= 5'b0;
      funct3_out <= 3'b0;
      funct7_out <= 7'b0;
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
        rd_out <= rd_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
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
                  rs2_out,rd_out);
  
  input clk,write,reset;
  input [31:0] instruction_in;
  input RegWrite_in,MemtoReg_in,MemRead_in,MemWrite_in,zero_in,Branch_in;
  input [31:0] pc_in,pc_ex_in;
  input [2:0] funct3_in;
  input [31:0] ALU_in,reg2_data_in;
  input [4:0] rs2_in,rd_in;

  output reg [31:0] instruction_out;
  output reg RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,zero_out,Branch_out;
  output reg [31:0] pc_out,pc_ex_out;
  output reg [2:0] funct3_out;
  output reg [31:0] ALU_out,reg2_data_out;
  output reg [4:0] rs2_out,rd_out;
    
  always@(posedge clk) begin
    if (reset) begin
      instruction_out <= 32'b0;
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
      MemRead_out <= 1'b0;
      MemWrite_out <= 1'b0;
      pc_out <= 32'b0;
      pc_ex_out <= 32'b0;
      funct3_out <= 3'b0;
      zero_out <= 1'b0;
      reg2_data_out <= 32'b0;
      ALU_out <= 32'b0;      
      rs2_out <= 5'b0;
      rd_out <= 5'b0;
      Branch_out <= 1'b0;
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
                  PC_out,Data_out,ALU_out,rd_out);
  
  input clk,write,reset;
  input [31:0] instruction_in;
  input [31:0] Data_in,ALU_in,PC_in;
  input RegWrite_in,MemtoReg_in;
  input [4:0] rd_in;
  
  output reg [31:0] instruction_out;
  output reg [31:0] Data_out,ALU_out,PC_out;
  output reg RegWrite_out,MemtoReg_out;
  output reg [4:0] rd_out;
  
  always@(posedge clk) begin
    if (reset) begin
      instruction_out <= 32'b0;
      Data_out <= 32'b0;
      ALU_out <= 32'b0;
      PC_out <= 32'b0;
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
      rd_out <= 5'b0;
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

module counter(clk,reset,cnt);
    input clk,reset;
    output reg [63:0] cnt;
    always@(posedge clk) begin
        if(reset)
            cnt <= 64'b0;
        else
            cnt <= cnt + 1'b1;
    end
endmodule


//////////////////////////////////////////////RISC-V_MODULE///////////////////////////////////////////////////
(* DONT_TOUCH = "true" *)
module RISC_V(input clk,
              output [9:0] instruction_address,
              input [31:0] instruction,
              
              output RegWrite,
              output [5:0] Reg1_ReadAddress,
              output [5:0] Reg2_ReadAddress,
              output [5:0] Reg_WriteAddress,
              output [31:0] Reg_WriteData,
              input [31:0] Reg1_ReadData,
              input [31:0] Reg2_ReadData,
              
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
  wire [4:0] RS1_ID; assign RS1_ID = INSTRUCTION_ID[19:15];
  wire [4:0] RS2_ID; assign RS2_ID = INSTRUCTION_ID[24:20];
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
  
  wire [31:0] ALU_OUT_EX;
  wire [3:0] ALU_control;
  wire ZERO_EX;
  wire [1:0] forwardA,forwardB;
  wire [31:0] MUX_A_EX,MUX_B_EX;
  wire [31:0] RS2_IMM_EX;
  
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
  
  assign Reg_WriteAddress = {1'b0,RD_WB};
  assign Reg_WriteData = ALU_DATA_WB;
  assign RegWrite = RegWrite_WB;
  
   assign REG_DATA1_ID = (RS1_ID != 5'b0) ? //it is different from x0
                         (((RegWrite_WB == 1'b1)&&(RS1_ID == RD_WB)) ? 
                         ALU_DATA_WB : Reg1_ReadData) : 32'b0;
   assign REG_DATA2_ID = (RS2_ID != 5'b0) ? //it is different from x0
                         (((RegWrite_WB == 1'b1)&&(RS2_ID == RD_WB)) ? 
                         ALU_DATA_WB : Reg2_ReadData) : 32'b0;
   assign Reg1_ReadAddress = {1'b0,RS1_ID};
   assign Reg2_ReadAddress = {1'b0,RS2_ID};
  
  //////////////////////////////////////pipeline registers////////////////////////////////////////////////////
  
  (* DONT_TOUCH = "true" *) IF_ID_reg IF_ID_REGISTER(clk,CSR[0],
                                                         IF_ID_write&(~CSR[1]),
                                                         PC_IF,INSTRUCTION_IF,
                                                         PC_ID,INSTRUCTION_ID);
  
  (* DONT_TOUCH = "true" *) ID_EX_reg ID_EX_REGISTER(clk,CSR[0],(~CSR[1]),INSTRUCTION_ID,
                                                         RegWrite_ID,MemtoReg_ID,MemRead_ID,MemWrite_ID,ALUSrc_ID,Branch_ID,ALUop_ID,
                                                         PC_ID,REG_DATA1_ID,REG_DATA2_ID,IMM_ID,
                                                         FUNCT7_ID,FUNCT3_ID,
                                                         RS1_ID,RS2_ID,RD_ID,
                                 
                                                         INSTRUCTION_EX,
                                                         RegWrite_EX,MemtoReg_EX,MemRead_EX,MemWrite_EX,ALUSrc_EX,Branch_EX,ALUop_EX,
                                                         PC_EX,REG_DATA1_EX,REG_DATA2_EX,IMM_EX,
                                                         FUNCT7_EX,FUNCT3_EX,
                                                         RS1_EX,RS2_EX,RD_EX);
  
  (* DONT_TOUCH = "true" *) EX_MEM_reg EX_MEM_REGISTER(clk,CSR[0],(~CSR[1]),INSTRUCTION_EX,
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
                                                           RS2_MEM,RD_MEM);
  
  (* DONT_TOUCH = "true" *) MEM_WB_reg MEM_WB_REGISTER(clk,CSR[0],(~CSR[1]),INSTRUCTION_MEM,
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
                                                          RD_WB);
                                         
  
  ///////////////////////////////////////////IF data path/////////////////////////////////////////////////////////
  
  (* DONT_TOUCH = "true" *) PC PC_MODULE(clk,CSR[0],PC_write&(~CSR[1]),PC_MUX,PC_IF); //current PC
  
  //(* DONT_TOUCH = "true" *) instruction_memory INSTRUCTION_MEMORY_MODULE(PC_IF[11:2],INSTRUCTION_IF);
  
  (* DONT_TOUCH = "true" *) adder ADDER_PC_4_IF(PC_IF,32'b0100,PC_4_IF);  //PC+4
  //assign PC_4_IF = PC_IF+32'h00000004;
  
  (* DONT_TOUCH = "true" *) mux2_1 MUX_PC(PC_4_IF,                 //PC+4
                                              PC_MEM,           //selction between pc from branch predictor or pc from EX stage
                                              (Branch_MEM & (beq|bne|blt|bge)), //select if we take or not the branch(if there is a branch instruction)
                                              PC_MUX);
  //assign PC_MUX = (Branch_MEM & (beq|bne|blt|bge)==1'b1) ? PC_MEM : PC_4_IF;              
   
  ///////////////////////////////////////////ID data path/////////////////////////////////////////////////////////
  
  (* DONT_TOUCH = "true" *) control_path CONTROL_PATH_MODULE(OPCODE,         
                                                                 pipeline_stall, //hazard detection signal 
                                                                 Branch_ID,MemRead_ID,MemtoReg_ID,
                                                                 ALUop_ID,MemWrite_ID,ALUSrc_ID,RegWrite_ID);
  
  /*(* DONT_TOUCH = "true" *) registers REGISTER_FILE_MODULE(clk,RegWrite_WB, 
                                                               RS1_ID,    
                                                               RS2_ID,    
                                                               RD_WB,     
                                                               ALU_DATA_WB,
                                                               REG_DATA1_ID,REG_DATA2_ID);*/
  
  (* DONT_TOUCH = "true" *) imm_gen IMM_GEN_MODULE(INSTRUCTION_ID,IMM_ID);
  
  (* DONT_TOUCH = "true" *) hazard_detection HAZARD_DETECTION_UNIT(RD_EX,  //ID_EX.rd
                                                                       RS1_ID, //IF_ID.rs1
                                                                       RS2_ID, //IF_ID.rs2
                                                                       MemRead_EX,   //ID_EX.MemRead
                                                                       PC_write,IF_ID_write,
                                                                       pipeline_stall);
                                
                                         
  ///////////////////////////////////////////EX data path/////////////////////////////////////////////////////////                                       
  
  (* DONT_TOUCH = "true" *) ALU ALU_MODULE(ALU_control,
                                               MUX_A_EX,RS2_IMM_EX,
                                               ZERO_EX,ALU_OUT_EX);
  
  (* DONT_TOUCH = "true" *) ALUcontrol ALU_CONTROL_MODULE(ALUop_EX,    //ALUop
                                                              FUNCT7_EX,    //funct7
                                                              FUNCT3_EX,    //funct3
                                                              ALU_control);
  
  (* DONT_TOUCH = "true" *) mux2_1 MUX_RS2_IMM(MUX_B_EX,     //rs2
                                                 IMM_EX,        //imm
                                                 ALUSrc_EX,     //ALUSrc
                                                 RS2_IMM_EX);
  //assign RS2_IMM_EX = (ALUSrc_EX == 1'b1) ? IMM_EX : MUX_B_EX;
                    
  (* DONT_TOUCH = "true" *) adder ADDER_IMM_EX(PC_EX,      //PC
                                               IMM_EX<<1, //imm<<1
                                               PC_Branch);
  //assign PC_Branch = PC_EX + (IMM_EX<<1);
                    
                  
  (* DONT_TOUCH = "true" *) forwarding FORWARDING_UNIT(RS1_EX, //rs1
                                                       RS2_EX,  //rs2
                                                       RD_MEM,     //ex_mem_rd
                                                       RD_WB,     //mem_wb_rd
                                                       RegWrite_MEM,     //ex_mem_regwrite
                                                       RegWrite_WB,     //mem_wb_regwrite
                                                       forwardA,forwardB);
  
  (* DONT_TOUCH = "true" *) mux4_1 MUX_FORWARD_A(REG_DATA1_EX,   //ID_EX source
                                                 ALU_DATA_WB, //MEM_WB source
                                                 ALU_OUT_MEM,   //EX_MEM source
                                                 32'b0,            //not used
                                                 forwardA,MUX_A_EX);
  /*assign MUX_A_EX = (forwardA == 2'b00) ? REG_DATA1_EX : 
                    ((forwardA == 2'b01) ? ALU_DATA_WB : 
                    ((forwardA == 2'b10) ? ALU_OUT_MEM : 32'b0));*/
                      
  (* DONT_TOUCH = "true" *) mux4_1 MUX_FORWARD_B(REG_DATA2_EX,    //ID_EX source
                                                     ALU_DATA_WB, //MEM_WB source
                                                     ALU_OUT_MEM,   //EX_MEM source
                                                     32'b0,            //not used
                                                     forwardB,MUX_B_EX);
  /*assign MUX_B_EX = (forwardB == 2'b00) ? REG_DATA2_EX : 
                    ((forwardB == 2'b01) ? ALU_DATA_WB : 
                    ((forwardB == 2'b10) ? ALU_OUT_MEM : 32'b0));*/                
                      
  ///////////////////////////////////////////MEM data path/////////////////////////////////////////////////////////
         
  /*(* DONT_TOUCH = "true" *) data_memory DATA_MEMORY_MODULE(clk,
                                                           MemRead_MEM,      //MemRead
                                                           MemWrite_MEM,     //MemWrite
                                                           ALU_OUT_MEM[11:2],      //ALU_OUT(address)
                                                           MUX_C_MEM,     //rs2(data)
                                                           DATA_MEMORY_MEM);*/
  (* DONT_TOUCH = "true" *) load_store_forwarding LD_SD_FORWARDING(RS2_MEM,
                                                                   RD_WB,
                                                                   MemWrite_MEM,
                                                                   MemtoReg_WB,
                                                                   forwardC);
                                         
  (* DONT_TOUCH = "true" *) mux2_1 MUX_FORWARD_C(REG_DATA2_MEM,
                                                 DATA_MEMORY_WB,
                                                 forwardC,
                                                 MUX_C_MEM);
  //assign MUX_C_MEM = (forwardC == 1'b1) ? DATA_MEMORY_WB : REG_DATA2_MEM; 
                        
                                                  
  ///////////////////////////////////////////MEM data path/////////////////////////////////////////////////////////
  
  (* DONT_TOUCH = "true" *) mux2_1 MUX_ALU_DATA(ALU_OUT_WB,   //ALU_out result
                                                DATA_MEMORY_WB, //Data_memory_out 
                                                MemtoReg_WB,    //MemtoReg
                                                ALU_DATA_WB);
  //assign ALU_DATA_WB = (MemtoReg_WB == 1'b1) ? DATA_MEMORY_WB : ALU_OUT_WB;
                      
  //////////////////////////////////////////////OTHER STUFF/////////////////////////////////////////////////////////////
  
  counter TIMER(clk&(~CSR[1]),CSR[0],timestamp);
  
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