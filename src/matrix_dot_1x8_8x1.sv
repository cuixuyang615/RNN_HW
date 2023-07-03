`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cxy
// 
// Create Date: 02.02.2023 13:44:19
// Design Name: 
// Module Name: matrix_dot_1x8_8x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      matrix_dot_1x8_8x1
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module matrix_dot_1x8_8x1(
    input           clk,
    input           rst_n,
    input   [7:0]   A_valid,
    input   [7:0]   B_valid,
    input   [31:0]  A [7:0],
    input   [31:0]  B [7:0],
    
    output          ready,
    output          done,
    output  [31:0]  result [7:0]

    );
    
//    wire en;
//    assign en = A_valid & B_valid;
    logic [7:0] dot_done;
    assign done = &dot_done;
    
    logic [7:0] multiply_channel1_ready;
    logic [7:0] multiply_channel2_ready;
    
    logic [7:0] multiply_ready;
    assign ready = &multiply_ready;
    
    genvar i;
    generate        
        for(i=0;i<8;i=i+1)
        begin
        
            assign multiply_ready[i] = multiply_channel1_ready[i] & multiply_channel2_ready[i];
        
            float_multiply float_multiplier (
              .aclk(clk),
              .aresetn(rst_n),
              
              .s_axis_a_tready(multiply_channel1_ready[i]),
              .s_axis_a_tvalid(multiply_channel1_ready[i] & A_valid[i]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(A[i]),              // input wire [31 : 0] s_axis_a_tdata
              
              .s_axis_b_tready(multiply_channel2_ready[i]),
              .s_axis_b_tvalid(multiply_channel2_ready[i] & B_valid[i]),            // input wire s_axis_b_tvalid
              .s_axis_b_tdata(B[i]),              // input wire [31 : 0] s_axis_b_tdata
              
              .m_axis_result_tvalid(dot_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
        
        end
    
    endgenerate
    
endmodule
