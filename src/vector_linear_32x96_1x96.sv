`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/09 16:24:40
// Design Name: 
// Module Name: vector_linear_32x96_1x96
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


module vector_linear_32x96_1x96(
    input logic         clk,
    input logic         rst_n,
    input logic         valid,
    input logic [31:0]  vector [31:0],  
    input logic [31:0]  weight_start_addr,
    input logic [31:0]  bias_start_addr,
    
    output logic        ready,
    output logic        done,
    output logic [31:0] result

    );
endmodule
