`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 21:56:29
// Design Name: 
// Module Name: float_add_dual
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


module float_add_dual(
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
    
    logic [1:0] add_channel1_ready;
    logic [1:0] add_channel2_ready;
    logic [1:0] add_done;
    
    assign ready = (& add_channel1_ready) & (& add_channel2_ready);
    assign done = add_done[0] & add_done[1];
    
    float_add float_adder1 (
        .aclk(clk),
        .aresetn(rst_n),
                    
        .s_axis_a_tready(add_channel1_ready[0]),
        .s_axis_a_tvalid(add_channel1_ready[0] & valid),            // input wire s_axis_a_tvalid
        .s_axis_a_tdata(din1_A),              // input wire [31 : 0] s_axis_a_tdata
                    
        .s_axis_b_tready(add_channel2_ready[0]),
        .s_axis_b_tvalid(add_channel2_ready[0] & valid),            // input wire s_axis_b_tvalid
        .s_axis_b_tdata(din1_B),              // input wire [31 : 0] s_axis_b_tdata
                    
        .m_axis_result_tvalid(add_done[0]),  // output wire m_axis_result_tvalid
        .m_axis_result_tdata(dout1)    // output wire [31 : 0] m_axis_result_tdata
    );
        
    float_add float_adder2 (
        .aclk(clk),
        .aresetn(rst_n),
                    
        .s_axis_a_tready(add_channel1_ready[1]),
        .s_axis_a_tvalid(add_channel1_ready[1] & valid),            // input wire s_axis_a_tvalid
        .s_axis_a_tdata(din2_A),              // input wire [31 : 0] s_axis_a_tdata
                    
        .s_axis_b_tready(add_channel2_ready[1]),
        .s_axis_b_tvalid(add_channel2_ready[1] & valid),            // input wire s_axis_b_tvalid
        .s_axis_b_tdata(din2_B),              // input wire [31 : 0] s_axis_b_tdata
                    
        .m_axis_result_tvalid(add_done[1]),  // output wire m_axis_result_tvalid
        .m_axis_result_tdata(dout2)    // output wire [31 : 0] m_axis_result_tdata
    );        
endmodule
