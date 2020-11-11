//////////////////////////////////////////////////////////////////////////////////
//
// Austin Hale
// 10/18/2020
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module datapath #(
    parameter Nreg = 32,
    parameter Dbits = 32
)(
    input wire clk,
    input wire reset,
    input wire enable,
    output logic [31:0] pc  = 32'h00400000,
    input wire [31:0] instr,
    input wire [1:0] pcsel,
    input wire [1:0] wasel, 
    input wire sgnext,
    input wire bsel,
    input wire [1:0] wdsel,
    input wire [4:0] alufn,
    input wire werf, 
    input wire [1:0] asel,
    output wire Z,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_writedata,
    input wire [31:0] mem_readdata
);
    
    wire [Dbits-1:0] ReadData1, ReadData2, alu_result, aluA, aluB, JT, BT;
    
    // Sign Extension
    wire [15:0] imm = instr[15:0];
    wire [31:0] signImm = (sgnext & imm[15]) ? ({{16{1'b1}}, imm}) : {{16{1'b0}}, imm}; 
    
    wire [31:0] pcPlus4, newPC;
    logic [Dbits-1:0] reg_writedata;
    
    // BT adder
    assign BT = (signImm << 2) + pcPlus4;
    
    // PCSEL
    assign newPC = (pcsel == 2'b11) ? ReadData1                         // JT/JR
                 : (pcsel == 2'b10) ? {pc[31:28], instr[25:0], 2'b00}   // J/JAL
                 : (pcsel == 2'b01) ? BT                                // BEQ/BNE
                 : (pcsel == 2'b00) ? pcPlus4 : 32'b0x;
    
    // PC + 4
    assign pcPlus4 = pc + 4;
    
    always_ff @(posedge clk)
        if(reset)
            pc <= 32'h00400000;
        else if(enable) 
            pc <= newPC;
   
    // WASEL
    wire [4:0] reg_writeaddr;
    assign reg_writeaddr = (wasel == 2'b10) ? 5'b11111
                         : (wasel == 2'b01) ? instr[20:16]
                         : (wasel == 2'b00) ? instr[15:11] : 5'b0x;
                         
    assign mem_writedata = ReadData2;
    assign mem_addr = alu_result;
    
    // ASEL
    assign aluA = (asel == 0) ? ReadData1
                : (asel == 1) ? instr[10:6]
                : (asel == 2) ? 5'b10000
                : 32'b0x;
    
    // BSEL            
    assign aluB = (bsel) ? signImm : ReadData2;
    
    // WDSEL
    assign reg_writedata  = (wdsel == 2'b10) ? mem_readdata
                          : (wdsel == 2'b01) ? alu_result
                          : (wdsel == 2'b00) ? pcPlus4 
                          : 32'b0x;
                
    ALU #(Dbits) myAlu(aluA, aluB, alu_result, alufn, Z);
    register_file #(Nreg, Dbits) regFile(clk, werf, instr[25:21], instr[20:16], reg_writeaddr, reg_writedata, ReadData1, ReadData2);                     
       
endmodule
