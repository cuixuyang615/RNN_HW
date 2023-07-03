`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/01 02:50:23
// Design Name: 
// Module Name: dense_l3_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dense_l3_mem(
    input logic         clk,
    input logic         rst_n,
    input logic  [7:0]  addr_base,
    
    output logic [31:0] dout [31:0]//,
    //output logic        busy

    );
    
    //logic [15:0] rsta_busy;
    //logic [15:0] rstb_busy;
    
   // assign busy = (&rsta_busy) & (&rstb_busy);
	dense_l3_mem_0 dense_l3_0 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[0]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[1])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_1 dense_l3_1 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[2]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[3])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_2 dense_l3_2 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[4]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[5])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_3 dense_l3_3 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[6]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[7])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_4 dense_l3_4 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[8]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[9])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_5 dense_l3_5 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[10]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[11])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_6 dense_l3_6 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[12]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[13])          // output wire [31 : 0] doutb
	);

	dense_l3_mem_7 dense_l3_7 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[14]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[15])          // output wire [31 : 0] doutb
	);


endmodule
