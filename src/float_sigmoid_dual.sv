`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 21:56:29
// Design Name: 
// Module Name: float_sigmoid_dual
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


module float_sigmoid_dual(
    input logic clk,
    input logic rst_n,
    input logic [31:0] din1,
    input logic [31:0] din2,
    input logic valid,
    
    output logic ready,
    output logic done,
    output logic [31:0] dout1,
    output logic [31:0] dout2
    );
    
    logic [31:0] din [1:0];
    assign din[0] = din1;
    assign din[1] = din2;
    
    logic [31:0] dout [1:0];
    assign dout1 = dout[0];
    assign dout2 = dout[1];
    
    logic [31:0] exp_result [1:0];
    logic exp_done [1:0];
    
    logic [31:0] add_result [1:0];
    logic add_done [1:0];
    
    logic [1:0] sigmoid_done;
    assign done = &sigmoid_done;
    
    logic [1:0] exp_ready, add_ready_channel1, add_ready_channel2, recip_ready;
    //wire ready;
    assign ready = & exp_ready;
    
    genvar i;
    generate
    
        for(i=0;i<2;i=i+1)
        begin    
            float_exponential sigmoid_exp (
              .aclk(clk),                                  // input wire aclk
              //.aclken(A_valid[i]),                              // input wire aclken
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(exp_ready[i]),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(exp_ready[i] & valid),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata({!din[i][31],din[i][30:0]}), //exp^-x             // input wire [31 : 0] s_axis_a_tdata
              
              .m_axis_result_tvalid(exp_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(exp_result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
            
            float_add sigmoid_add (
              .aclk(clk),                                  // input wire aclk
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(add_ready_channel1[i]),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(add_ready_channel1[i] & exp_done[i]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(32'h3f800000),              //1.0   // input wire [31 : 0] s_axis_a_tdata
              
              .s_axis_b_tready(add_ready_channel2[i]),            // output wire s_axis_a_tready
              .s_axis_b_tvalid(add_ready_channel2[i] & exp_done[i]),            // input wire s_axis_b_tvalid
              .s_axis_b_tdata(exp_result[i]),              // input wire [31 : 0] s_axis_b_tdata
              
              .m_axis_result_tvalid(add_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(add_result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
            
            float_reciprocal sigmoid_recip (
              .aclk(clk),                                  // input wire aclk
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(recip_ready[i]),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(recip_ready[i] & add_done[i]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(add_result[i]),              // input wire [31 : 0] s_axis_a_tdata
              
              .m_axis_result_tvalid(sigmoid_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(dout[i])    // output wire [31 : 0] m_axis_result_tdata
            );
        end
        
    endgenerate
endmodule
