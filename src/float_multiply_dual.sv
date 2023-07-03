`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 21:56:29
// Design Name: 
// Module Name: float_multiply_dual
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


module float_multiply_dual(
    input logic clk,
    input logic rst_n,
    input logic [31:0] din1_A,
    input logic [31:0] din1_B,
    input logic [31:0] din2_A,
    input logic [31:0] din2_B,
    input logic valid,
    
    output logic ready,
    output logic done,
    output logic [31:0] dout1,
    output logic [31:0] dout2
    );
    
    logic [1:0] multiply_channel1_ready;
    logic [1:0] multiply_channel2_ready;
    logic [1:0] multiply_done;
    
    assign ready = (& multiply_channel1_ready) & (& multiply_channel2_ready);
    assign done = multiply_done[0] & multiply_done[1];
    
    float_multiply float_multiply1 (
        .aclk(clk),
        .aresetn(rst_n),
                    
        .s_axis_a_tready(multiply_channel1_ready[0]),
        .s_axis_a_tvalid(multiply_channel1_ready[0] & valid),            // input wire s_axis_a_tvalid
        .s_axis_a_tdata(din1_A),              // input wire [31 : 0] s_axis_a_tdata
                    
        .s_axis_b_tready(multiply_channel2_ready[0]),
        .s_axis_b_tvalid(multiply_channel2_ready[0] & valid),            // input wire s_axis_b_tvalid
        .s_axis_b_tdata(din1_B),              // input wire [31 : 0] s_axis_b_tdata
                    
        .m_axis_result_tvalid(multiply_done[0]),  // output wire m_axis_result_tvalid
        .m_axis_result_tdata(dout1)    // output wire [31 : 0] m_axis_result_tdata
    );
        
    float_multiply float_multiply2 (
        .aclk(clk),
        .aresetn(rst_n),
                    
        .s_axis_a_tready(multiply_channel1_ready[1]),
        .s_axis_a_tvalid(multiply_channel1_ready[1] & valid),            // input wire s_axis_a_tvalid
        .s_axis_a_tdata(din2_A),              // input wire [31 : 0] s_axis_a_tdata
                    
        .s_axis_b_tready(multiply_channel2_ready[1]),
        .s_axis_b_tvalid(multiply_channel2_ready[1] & valid),            // input wire s_axis_b_tvalid
        .s_axis_b_tdata(din2_B),              // input wire [31 : 0] s_axis_b_tdata
                    
        .m_axis_result_tvalid(multiply_done[1]),  // output wire m_axis_result_tvalid
        .m_axis_result_tdata(dout2)    // output wire [31 : 0] m_axis_result_tdata
    );  
endmodule
