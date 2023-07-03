`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/02 00:06:00
// Design Name: 
// Module Name: float_sigmoid_single
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


module float_sigmoid_single(
    input logic clk,
    input logic rst_n,
    input logic [31:0] din,
    input logic valid,
    
    output logic ready,
    output logic done,
    output logic [31:0] dout
    );
    
    logic [31:0] exp_result;
    logic exp_done;
    
    logic [31:0] add_result;
    logic add_done;
    
    logic sigmoid_done;
    assign done = sigmoid_done;
    
    logic exp_ready, add_ready_channel1, add_ready_channel2, recip_ready;
    //wire ready;
    assign ready = exp_ready;
      
            float_exponential sigmoid_exp (
              .aclk(clk),                                  // input wire aclk
              //.aclken(A_valid[i]),                              // input wire aclken
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(exp_ready),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(exp_ready & valid),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata({!din[31],din[30:0]}), //exp^-x             // input wire [31 : 0] s_axis_a_tdata
              
              .m_axis_result_tvalid(exp_done),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(exp_result)    // output wire [31 : 0] m_axis_result_tdata
            );
            
            float_add sigmoid_add (
              .aclk(clk),                                  // input wire aclk
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(add_ready_channel1),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(add_ready_channel1 & exp_done),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(32'h3f800000),              //1.0   // input wire [31 : 0] s_axis_a_tdata
              
              .s_axis_b_tready(add_ready_channel2),            // output wire s_axis_a_tready
              .s_axis_b_tvalid(add_ready_channel2 & exp_done),            // input wire s_axis_b_tvalid
              .s_axis_b_tdata(exp_result),              // input wire [31 : 0] s_axis_b_tdata
              
              .m_axis_result_tvalid(add_done),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(add_result)    // output wire [31 : 0] m_axis_result_tdata
            );
            
            float_reciprocal sigmoid_recip (
              .aclk(clk),                                  // input wire aclk
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(recip_ready),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(recip_ready & add_done),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(add_result),              // input wire [31 : 0] s_axis_a_tdata
              
              .m_axis_result_tvalid(sigmoid_done),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(dout)    // output wire [31 : 0] m_axis_result_tdata
            );

endmodule
