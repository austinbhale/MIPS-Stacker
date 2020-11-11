`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// @author Austin Hale / Montek Singh
//////////////////////////////////////////////////////////////////////////////////

module screenmem #(
    parameter Nloc,                      // Number of memory locations
    parameter Dbits,
    parameter bmem_init = "smem_screentest.mem"  
    )(
    input wire [$clog2(Nloc)-1 : 0] WriteAddr,
    output wire [Dbits-1 : 0] ReadData
);
    
    logic [Dbits-1:0] mem [Nloc-1:0];                    // The actual registers where data is stored
    initial $readmemh(bmem_init, mem, 0, Nloc-1);
    
    assign ReadData = mem[WriteAddr];
    
endmodule
