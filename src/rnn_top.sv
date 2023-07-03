`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/02 00:02:23
// Design Name: 
// Module Name: rnn_top
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


module rnn_top(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] din,
    input  logic        valid,
    
    //output logic        din_request,
    output logic [7:0]  din_index,
    output logic        done,
    output logic [31:0] dout
    );
    
    logic [31:0] dense_result;
    logic gru_dense_done;
    gru_top gru(
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .valid(valid),
        
        //.din_request(din_request),
        .din_index(din_index),
        .done(gru_dense_done),
        .dense_result(dense_result)

    );
    
    float_sigmoid_single final_sigmoid(
        .clk(clk),
        .rst_n(rst_n),
        .din(dense_result),
        .valid(gru_dense_done),
        
        .ready(),
        .done(done),
        .dout(dout)
    );
endmodule
