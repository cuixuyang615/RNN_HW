`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/10 02:42:40
// Design Name: 
// Module Name: uarr_l2_mem
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


module uarr_l2_mem(
    input logic         clk,
    input logic         rst_n,
    input logic  [7:0]  addr_base,
    
    output logic [31:0] dout [31:0]//,
    //output logic        busy

    );
    
    //logic [15:0] rsta_busy;
    //logic [15:0] rstb_busy;
    
   // assign busy = (&rsta_busy) & (&rstb_busy);
   
	uarr_l2_mem_0 uarr_l2_0 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[0]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[1])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_1 uarr_l2_1 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[2]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[3])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_2 uarr_l2_2 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[4]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[5])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_3 uarr_l2_3 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[6]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[7])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_4 uarr_l2_4 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[8]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[9])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_5 uarr_l2_5 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[10]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[11])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_6 uarr_l2_6 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[12]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[13])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_7 uarr_l2_7 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[14]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[15])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_8 uarr_l2_8 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[16]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[17])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_9 uarr_l2_9 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[18]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[19])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_10 uarr_l2_10 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[20]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[21])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_11 uarr_l2_11 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[22]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[23])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_12 uarr_l2_12 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[24]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[25])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_13 uarr_l2_13 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[26]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[27])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_14 uarr_l2_14 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[28]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[29])          // output wire [31 : 0] doutb
	);

	uarr_l2_mem_15 uarr_l2_15 (
		.clka(clk),            // input wire clka
		.rsta(!rst_n),            // input wire rsta
		.addra(addr_base),          // input wire [7 : 0] addra
		.douta(dout[30]),          // output wire [31 : 0] douta
		.clkb(clk),            // input wire clkb
		.rstb(!rst_n),            // input wire rstb
		.addrb(addr_base+1),          // input wire [7 : 0] addrb
		.doutb(dout[31])          // output wire [31 : 0] doutb
	);

   
endmodule