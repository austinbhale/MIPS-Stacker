//////////////////////////////////////////////////////////////////////////////////
// Montek Singh
// 9/21/2020
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module debouncer #(parameter N=20)(
    input wire raw,
    input wire clk,
    output logic clean = 0
    );

	logic [N-1:0] count = 0;
	
	always_ff @(posedge clk) begin
		count <= (raw != clean)  ? count + 1 : 0;
		clean <= (&count == 1) ? ~clean : clean;
	end
	
endmodule