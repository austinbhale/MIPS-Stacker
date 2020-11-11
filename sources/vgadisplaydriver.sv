//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 1/31/2020
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none
//`include "display10x4.vh"
`include "display640x480.vh"

module vgadisplaydriver #(
    parameter Nchars = 11,
    parameter Nloc = 2816,
    parameter Dbits = 12,
    parameter bmem_init = "bmem_test.mem"
    )(
    input wire clk,
    input wire [3:0] charcode,
    output wire [11:0] smem_addr,
    output wire [3:0] red, green, blue,
    output wire hsync, vsync
);

   wire [`xbits-1:0] x;
   wire [`ybits-1:0] y;
   wire activevideo;
   
   wire [11:0] RGB;
   wire [$clog2(Nloc)-1:0] BitmapAddr;

   vgatimer myvgatimer(clk, hsync, vsync, activevideo, x, y);
   
   assign smem_addr = (y[`ybits-1:4] << 5) + (y[`ybits-1:4] << 3) + x[`xbits-1:4];
   
   assign BitmapAddr = {charcode, y[3:0], x[3:0]};
   
   screenmem #(Nloc, Dbits, bmem_init) bmem(BitmapAddr, RGB);
   
   assign red[3:0]   = (activevideo == 1) ? RGB[11:8] : 4'b0;
   assign green[3:0] = (activevideo == 1) ? RGB[7:4] : 4'b0;
   assign blue[3:0]  = (activevideo == 1) ? RGB[3:0] : 4'b0;

endmodule