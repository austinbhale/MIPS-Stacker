//////////////////////////////////////////////////////////////////////////////////
//
// Austin Hale
// 10/30/2020
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`default_nettype none

module memIO#(
    parameter wordsize=32,
    parameter dmem_size=64,
    parameter dmem_init="wherever_data_is.mem",
    parameter Nchars=32,
    parameter smem_size=128,                            
    parameter smem_init="wherever_code_is.mem"
)(
    input wire clk,
    input wire cpu_wr,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_writedata,
    output wire [31:0] cpu_readdata,
    input wire [10:0] vga_addr,
    output wire [3:0] vga_readdata,
    input wire [31:0] keyb_char,
    input wire [31:0] accel_val,
    output wire [31:0] period,
    output wire [15:0] lights,
    input wire [31:0] buttons
);
    
    wire [31:0] smem_readdata;
    wire [31:0] dmem_readdata;   
    wire dmem_wr, smem_wr;
    
    assign smem_wr = ((cpu_wr == 1) & (cpu_addr[17:16] == 2'b10)) ? 1 : 0;
    assign dmem_wr = ((cpu_wr == 1) & (cpu_addr[17:16] == 2'b01)) ? 1 : 0;
    
    wire sound_wr, lights_wr;
    assign sound_wr = ((cpu_wr == 1) & (cpu_addr[3:2] == 2'b10) & (cpu_addr[17:16] == 2'b11)) ? 1 : 0;
    assign lights_wr = ((cpu_wr == 1) & (cpu_addr[3:2] == 2'b11) & (cpu_addr[17:16] == 2'b11)) ? 1 : 0;
    
    assign cpu_readdata = ((cpu_addr[17:16] == 2'b11) & (cpu_addr[4:2] == 3'b100)) ? buttons
                        : ((cpu_addr[17:16] == 2'b11) & (cpu_addr[3:2] == 2'b00)) ? keyb_char
                        : ((cpu_addr[17:16] == 2'b11) & (cpu_addr[3:2] == 2'b01)) ? accel_val
                        : (cpu_addr[17:16] == 2'b10) ? smem_readdata
                        : (cpu_addr[17:16] == 2'b01) ? dmem_readdata
                        : 32'b0;
   
    logic [31:0] period_t = 32'h00000000;  
    always_ff @(posedge clk)
    begin
        if(sound_wr)
            period_t <= cpu_writedata[31:0];
    end    
    assign period = period_t;
    
    logic [15:0] lights_t = 16'h0000;
    always_ff @(posedge clk)
    begin
        if(lights_wr)
            lights_t <= {2'hf, cpu_writedata[13:2], 2'hf}; // corners are always lit
    end
    
    assign lights = lights_t;
     
    ram_module_2_port #(.Nloc(smem_size), .Dbits(wordsize), .Nchars(Nchars), .initfile(smem_init)) smem(clk, smem_wr, cpu_addr[31:2], cpu_writedata, vga_addr, smem_readdata, vga_readdata);  
    ram_module #(.Nloc(dmem_size), .Dbits(wordsize), .initfile(dmem_init)) dmem(clk, dmem_wr, cpu_addr[31:2], cpu_writedata, dmem_readdata);  

endmodule