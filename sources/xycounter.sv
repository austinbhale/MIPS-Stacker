`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// @author Austin Hale / Montek Singh
//////////////////////////////////////////////////////////////////////////////////


module xycounter #(parameter width=2, height=2) (
    input wire clock,
    input wire enable,
    output logic [$clog2(width)-1:0] x=0,
    output logic [$clog2(height)-1:0] y=0
    );
    
    always_ff @(posedge clock) begin
        if (enable) begin
            y = (x >= width - 1) ? y + 1 : y;
            x = (x >= width - 1) ? 0 : x + 1;
            y = (y >= height) ? 0 : y;
        end
    end
   
endmodule