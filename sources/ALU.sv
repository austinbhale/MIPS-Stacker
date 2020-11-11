`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// @author Austin Hale / Montek Singh
//////////////////////////////////////////////////////////////////////////////////


module ALU #(parameter N=32) (
    input wire [N-1:0] A, B,
    output wire [N-1:0] R,
    input wire [4:0] ALUfn,
    output wire FlagZ
    );
    
    wire subtract, bool1, bool0, shft, math; 
    assign {subtract, bool1, bool0, shft, math} = ALUfn[4:0];                   // Separate ALUfn into named bits
    
    wire [N-1:0] addsubResult, shiftResult, logicalResult;                      // Results from the three ALU components
    wire comparatorResult;
    addsub #(N) AS(A, B, subtract, addsubResult, FlagN, FlagC, FlagV);
    shifter #(N) S(B, A[$clog2(N)-1:0], ~(bool1|bool0), ~(bool1&bool0), shiftResult);
    logical #(N) L(A, B, {bool1, bool0}, logicalResult);
    
    comparator C(FlagN, FlagV, FlagC, bool0, comparatorResult);
    
    assign R = (!shft & math) ? addsubResult :                                  // 4-way multiplexer to select result
               (shft & !math) ? shiftResult :
               (!shft & !math) ? logicalResult :
               {{(N-1){1'b0}}, comparatorResult};
 
    assign FlagZ = ~|R;                                                         // Use a reduction operator here
     
endmodule
