//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 10/14/2020
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none


// These are non-R-type.  OPCODES defined here:

`define LW     6'b 100011
`define SW     6'b 101011

`define ADDI   6'b 001000
`define ADDIU  6'b 001001        // NOTE:  addiu *does* sign-extend the imm
`define SLTI   6'b 001010
`define SLTIU  6'b 001011
`define ORI    6'b 001101
`define LUI    6'b 001111
`define ANDI   6'b 001100
`define XORI   6'b 001110

`define BEQ    6'b 000100
`define BNE    6'b 000101
`define J      6'b 000010
`define JAL    6'b 000011


// These are all R-type, i.e., OPCODE=0.  FUNC field defined here:

`define ADD    6'b 100000
`define ADDU   6'b 100001
`define SUB    6'b 100010
`define AND    6'b 100100
`define OR     6'b 100101
`define XOR    6'b 100110
`define NOR    6'b 100111
`define SLT    6'b 101010
`define SLTU   6'b 101011
`define SLL    6'b 000000
`define SLLV   6'b 000100
`define SRL    6'b 000010
`define SRLV   6'b 000110
`define SRA    6'b 000011
`define SRAV   6'b 000111
`define JR     6'b 001000
`define JALR   6'b 001001


module controller_test;

   logic enable = 1'b1;
   logic [5:0] op;
   logic [5:0] func;
   logic Z;
   
   wire [1:0] pcsel;
   wire [1:0] wasel; 
   wire sgnext;
   wire bsel;
   wire [1:0] wdsel; 
   wire [4:0] alufn;
   wire wr;
   wire werf; 
   wire [1:0] asel;

   // Instantiate the Unit Under Test (UUT)
   controller uut(.*);                      // The ".*" connects all signals by name






   initial begin
      enable = 1'b1;

      // Add stimulus here
      // Inputs change every 1 ns
      
      #1 {op, func, Z} = {`LW,    6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`SW,    6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`ADDI,  6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`ADDIU, 6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`SLTI,  6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`SLTIU, 6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`ORI,   6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`LUI,   6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`ANDI,  6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`XORI,  6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`BEQ,   6'b xxxxxx, 1'b 0};
      #1 {op, func, Z} = {`BEQ,   6'b xxxxxx, 1'b 1};
      #1 {op, func, Z} = {`BNE,   6'b xxxxxx, 1'b 0};
      #1 {op, func, Z} = {`BNE,   6'b xxxxxx, 1'b 1};
      #1 {op, func, Z} = {`J,     6'b xxxxxx, 1'b x};
      #1 {op, func, Z} = {`JAL,   6'b xxxxxx, 1'b x};
      
      #1 {op, func, Z} = {6'b 000000, `ADD,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `ADDU,  1'b x};
      #1 {op, func, Z} = {6'b 000000, `SUB,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `AND,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `OR,    1'b x};
      #1 {op, func, Z} = {6'b 000000, `XOR,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `NOR,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `SLT,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `SLTU,  1'b x};
      #1 {op, func, Z} = {6'b 000000, `SLL,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `SLLV,  1'b x};
      #1 {op, func, Z} = {6'b 000000, `SRL,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `SRLV,  1'b x};
      #1 {op, func, Z} = {6'b 000000, `SRA,   1'b x};
      #1 {op, func, Z} = {6'b 000000, `SRAV,  1'b x};
      #1 {op, func, Z} = {6'b 000000, `JR,    1'b x};
      #1 {op, func, Z} = {6'b 000000, `JALR,    1'b x};

      #1 {op, func, Z} = {6'b 000000, `ADD,   1'b x}; // werf should be 1
      #1 enable = 1'b0;                             // disable processor
      #1 {op, func, Z} = {6'b 000000, `ADD,   1'b x}; // werf should be 0
      #1 enable = 1'b1;                             // re-enable processor
      #1 {op, func, Z} = {`SW,    6'b xxxxxx, 1'b x}; // wr should be 1
      #1 enable = 1'b0;                             // disable processor
      #1 {op, func, Z} = {`SW,    6'b xxxxxx, 1'b x}; // wr should be 0


      // Wait another 2 ns, and then finish simulation
      #2 $finish;
   end




   // SELF-CHECKING CODE
   
   selfcheck c();  // c(checker_RD1, checker_RD2, checker_ALUResult, checker_FlagZ);
   
   function mismatch;  // some trickery needed to match two values with don't cares
       input p, q;      // mismatch in a bit position is ignored if q has an 'x' in that bit
       integer p, q;
       mismatch = (((p ^ q) ^ q) !== q);
   endfunction
   
   wire ERROR;
   
   wire ERROR_pcsel  = mismatch(pcsel, c.pcsel)? 1'bX : 1'b0;
   wire ERROR_wasel  = mismatch(wasel, c.wasel)? 1'bX : 1'b0;
   wire ERROR_sgnext = mismatch(sgnext, c.sgnext)? 1'bX : 1'b0;
   wire ERROR_bsel   = mismatch(bsel, c.bsel)? 1'bX : 1'b0;
   wire ERROR_wdsel  = mismatch(wdsel, c.wdsel)? 1'bX : 1'b0;
   wire ERROR_alufn  = mismatch(alufn, c.alufn)? 1'bX : 1'b0;
   wire ERROR_wr     = mismatch(wr, c.wr)? 1'bX : 1'b0;
   wire ERROR_werf   = mismatch(werf, c.werf)? 1'bX : 1'b0;
   wire ERROR_asel   = mismatch(asel, c.asel)? 1'bX : 1'b0;
   
   assign ERROR = ERROR_pcsel | ERROR_wasel | ERROR_sgnext | ERROR_bsel | ERROR_wdsel | ERROR_alufn | ERROR_wr | ERROR_werf | ERROR_asel;
   

   initial begin
      $monitor("     #%02d {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b%b};", $time, {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel});
   end
   
endmodule


// CHECKER MODULE
module selfcheck();
   logic [1:0] pcsel;
   logic [1:0] wasel;
   logic sgnext;
   logic bsel;
   logic [1:0] wdsel;
   logic [4:0] alufn;
   logic wr;
   logic werf;
   logic [1:0] asel;
      
   initial begin
   fork
     #00 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'bxxxxxxxxxxxxx00xx};
     #01 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b000111100xx010100};
     #02 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00xx11xx0xx011000};
     #03 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b000111010xx010100};
     #05 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b000111011x0110100};
     #06 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b000111011x1110100};
     #07 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00010101x01000100};
     #08 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0001x101x00100110};
     #09 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00010101x00000100};
     #10 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00010101x10000100};
     #11 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00xx10xx1xx010000};
     #12 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b01xx10xx1xx010000};
     #14 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00xx10xx1xx010000};
     #15 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b10xxxxxxxxxxx00xx};
     #16 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b1010xx00xxxxx01xx};
     #17 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0010xx010100};
     #19 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0011xx010100};
     #20 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x00000100};
     #21 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x01000100};
     #22 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x10000100};
     #23 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x11000100};
     #24 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0011x0110100};
     #25 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0011x1110100};
     #26 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x00100101};
     #27 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x00100100};
     #28 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x10100101};
     #29 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x10100100};
     #30 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x11100101};
     #31 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x001x11100100};
     #32 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b11xxxxxxxxxxx00xx};
     #33 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b1100xx00xxxxx01xx};
     #34 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0010xx010100};
     #35 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0010xx010000};
     #37 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b0000x0010xx010100};
     #38 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00xx11xx0xx011000};
     #39 {pcsel, wasel, sgnext, bsel, wdsel, alufn, wr, werf, asel} <= {17'b00xx11xx0xx010000};
   
   join
   end
endmodule