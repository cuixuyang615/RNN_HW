`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/01 02:53:11
// Design Name: 
// Module Name: matrix_sigmoid_1x8
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


module matrix_sigmoid_1x8(
    input           clk,
    input           rst_n,
    input   [7:0]   din_valid,
    input   [31:0]  din [7:0],    
    
    output          ready,
    output          done,
    output  [31:0]  dout [7:0]

    );
    
    wire [31:0] exp_result [7:0];
    wire exp_done [7:0];
    
    wire [31:0] add_result [7:0];
    wire add_done [7:0];
    
    wire [7:0] sigmoid_done;
    assign done = &sigmoid_done;
    
    wire exp_ready, add_ready_channel1, add_ready_channel2, recip_ready;
    //wire ready;
    assign ready = exp_ready;
    
    genvar i;
    generate
    
        for(i=0;i<8;i=i+1)
        begin    
            float_exponential sigmoid_exp (
              .aclk(clk),                                  // input wire aclk
              //.aclken(A_valid[i]),                              // input wire aclken
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(exp_ready),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(exp_ready & din_valid[i]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata({!din[i][31],din[i][30:0]}), //exp^-x             // input wire [31 : 0] s_axis_a_tdata
              
              .m_axis_result_tvalid(exp_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(exp_result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
            
            float_add sigmoid_add (
              .aclk(clk),                                  // input wire aclk
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(add_ready_channel1),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(add_ready_channel1 & exp_done[i]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(32'h3f800000),              //1.0   // input wire [31 : 0] s_axis_a_tdata
              
              .s_axis_b_tready(add_ready_channel2),            // output wire s_axis_a_tready
              .s_axis_b_tvalid(add_ready_channel2 & exp_done[i]),            // input wire s_axis_b_tvalid
              .s_axis_b_tdata(exp_result[i]),              // input wire [31 : 0] s_axis_b_tdata
              
              .m_axis_result_tvalid(add_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(add_result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
            
            float_reciprocal sigmoid_recip (
              .aclk(clk),                                  // input wire aclk
              .aresetn(rst_n),                            // input wire aresetn
              
              .s_axis_a_tready(recip_ready),            // output wire s_axis_a_tready
              .s_axis_a_tvalid(recip_ready & add_done[i]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(add_result[i]),              // input wire [31 : 0] s_axis_a_tdata
              
              .m_axis_result_tvalid(sigmoid_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(dout[i])    // output wire [31 : 0] m_axis_result_tdata
            );
        end
        
    endgenerate
            
endmodule
