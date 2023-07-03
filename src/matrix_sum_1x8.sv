`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2023 16:41:52
// Design Name: 
// Module Name: matrix_sum_1x8
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


module matrix_sum_1x8(
    input           clk,
    input           rst_n,
    input   [7:0]   matrix_in_valid,
    input   [31:0]  matrix_in [7:0],
    
    output          ready,
    output          done,
    output  [31:0]  result


    );
    
    //because the output of float add is already been buffered,
    //we just need to wire the ips together without applying additional register
    //using pipelined design
    
    logic [31:0] sum_result_first_4  [3:0];
    logic [3:0]  sum_result_first_done;
    
    logic [31:0] sum_result_second_2  [1:0];
    logic [1:0]  sum_result_second_done;
    
    logic [3:0] layer1_channel1_ready;
    logic [3:0] layer1_channel2_ready;
    logic [3:0] layer1_ready;
    
    logic [1:0] layer2_channel1_ready;
    logic [1:0] layer2_channel2_ready;
    
    logic  layer3_channel1_ready;
    logic  layer3_channel2_ready;
    
    assign ready = & layer1_ready;
    
    //add tree of 8 input number
    genvar i;
    generate
    
        //generating first layer in sum tree
        //the position of A is even number and B is odd number in the tree
        //e.g 
        //      sum_result_first_4[0] = matrix_in[0] + matrix_in[1]
        for(i=0;i<4;i=i+1)
        begin
        
            assign layer1_ready[i] = layer1_channel1_ready[i] & layer1_channel2_ready[i];
             
            float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer1_channel1_ready[i]),
                .s_axis_a_tvalid(layer1_channel1_ready[i] & matrix_in_valid[2*i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(matrix_in[2*i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer1_channel2_ready[i]),
                .s_axis_b_tvalid(layer1_channel2_ready[i] & matrix_in_valid[2*i+1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(matrix_in[2*i+1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_result_first_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_result_first_4[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        end
        
        //generating second layer in sum tree
        //the position of A is even number and B is odd number in the tree
        //e.g 
        //      sum_result_second_2[0] = sum_result_first_4[0] + sum_result_first_4[1]
        for(i=0;i<2;i=i+1)
        begin 
            float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer2_channel1_ready[i]),
                .s_axis_a_tvalid(layer2_channel1_ready[i] & sum_result_first_done[2*i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(sum_result_first_4[2*i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer2_channel2_ready[i]),
                .s_axis_b_tvalid(layer2_channel2_ready[i] & sum_result_first_done[2*i+1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(sum_result_first_4[2*i+1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_result_second_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_result_second_2[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        end
        
        //generating third/final layer in sum tree
        float_add float_adder_final (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer3_channel1_ready),
                .s_axis_a_tvalid(layer3_channel1_ready & sum_result_second_done[0]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(sum_result_second_2[0]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer3_channel2_ready),
                .s_axis_b_tvalid(layer3_channel2_ready & sum_result_second_done[1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(sum_result_second_2[1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(done),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(result)    // output wire [31 : 0] m_axis_result_tdata
                );
            
    endgenerate
        
endmodule
