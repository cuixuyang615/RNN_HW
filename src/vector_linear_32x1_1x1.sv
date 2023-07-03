`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/09 12:26:05
// Design Name: 
// Module Name: matrix_linear_32x1_1x1
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


module vector_linear_32x1_1x1(
    input logic         clk,
    input logic         rst_n,
    input logic         valid,
    input logic [31:0]  vector [31:0],  
    input logic [31:0]  weight [31:0],
    input logic [31:0]  bias,
    
    output logic        ready,
    output logic        done,
    output logic [31:0] result

    );
    
    logic sum_valid;
    ///////// weight part ///////////////
    logic [31:0] dot_done;
    assign sum_valid = &dot_done;
    
    logic [31:0] multiply_channel1_ready;
    logic [31:0] multiply_channel2_ready;
    
    logic [31:0] multiply_ready;
    assign ready = &multiply_ready;
    
    logic [31:0] dot_result [31:0];
    
    genvar i;
    generate        
        for(i=0;i<32;i=i+1)
        begin
        
            assign multiply_ready[i] = multiply_channel1_ready[i] & multiply_channel2_ready[i];
        
            float_multiply float_multiplier (
              .aclk(clk),
              .aresetn(rst_n),
              
              .s_axis_a_tready(multiply_channel1_ready[i]),
              .s_axis_a_tvalid(multiply_channel1_ready[i] & valid),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(vector[i]),              // input wire [31 : 0] s_axis_a_tdata
              
              .s_axis_b_tready(multiply_channel2_ready[i]),
              .s_axis_b_tvalid(multiply_channel2_ready[i] & valid),            // input wire s_axis_b_tvalid
              .s_axis_b_tdata(weight[i]),              // input wire [31 : 0] s_axis_b_tdata
              
              .m_axis_result_tvalid(dot_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(dot_result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
        
        end
    
    endgenerate
    
    //because the output of float add is already been buffered,
    //we just need to wire the ips together without applying additional register
    //using pipelined design
    
    logic [31:0] sum_layer1_result [15:0];
    logic [15:0] sum_layer1_result_done;
    
    logic [31:0] sum_layer2_result [7:0];
    logic [7:0]  sum_layer2_result_done;
    
    logic [31:0] sum_layer3_result [3:0];
    logic [3:0]  sum_layer3_result_done;
    
    logic [31:0] sum_layer4_result [1:0];
    logic [1:0 ] sum_layer4_result_done;
    
    logic [31:0] sum_layer5_result;
    logic        sum_layer5_result_done;
    
    logic [15:0] layer1_channel1_ready;
    logic [15:0] layer1_channel2_ready;
    logic [15:0] layer1_ready;
    
    logic [7:0] layer2_channel1_ready;
    logic [7:0] layer2_channel2_ready;
    
    logic [3:0] layer3_channel1_ready;
    logic [3:0] layer3_channel2_ready;
    
    logic [1:0] layer4_channel1_ready;
    logic [1:0] layer4_channel2_ready;
    
    logic  layer5_channel1_ready;
    logic  layer5_channel2_ready;
    
    
    //add tree of 8 input number
    generate
    
        //generating first layer in sum tree
        //the position of A is even number and B is odd number in the tree
        //e.g 
        //      sum_result_first_4[0] = matrix_in[0] + matrix_in[1]
        for(i=0;i<16;i=i+1)
        begin    
            float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer1_channel1_ready[i]),
                .s_axis_a_tvalid(layer1_channel1_ready[i] & dot_done[2*i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(dot_result[2*i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer1_channel2_ready[i]),
                .s_axis_b_tvalid(layer1_channel2_ready[i] & dot_done[2*i+1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(dot_result[2*i+1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_layer1_result_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_layer1_result[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        end
        
        //generating second layer in sum tree
        //the position of A is even number and B is odd number in the tree
        //e.g 
        //      sum_result_second_2[0] = sum_result_first_4[0] + sum_result_first_4[1]
        for(i=0;i<8;i=i+1)
        begin 
            float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer2_channel1_ready[i]),
                .s_axis_a_tvalid(layer2_channel1_ready[i] & sum_layer1_result_done[2*i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(sum_layer1_result[2*i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer2_channel2_ready[i]),
                .s_axis_b_tvalid(layer2_channel2_ready[i] & sum_layer1_result_done[2*i+1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(sum_layer1_result[2*i+1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_layer2_result_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_layer2_result[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        end
        
        for(i=0;i<4;i=i+1)
        float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer3_channel1_ready[i]),
                .s_axis_a_tvalid(layer3_channel1_ready[i] & sum_layer2_result_done[2*i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(sum_layer2_result[2*i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer3_channel2_ready[i]),
                .s_axis_b_tvalid(layer3_channel2_ready[i] & sum_layer2_result_done[2*i+1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(sum_layer2_result[2*i+1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_layer3_result_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_layer3_result[i])    // output wire [31 : 0] m_axis_result_tdata
                );
         
         for(i=0;i<2;i=i+1)
         float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer4_channel1_ready[i]),
                .s_axis_a_tvalid(layer4_channel1_ready[i] & sum_layer3_result_done[2*i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(sum_layer3_result[2*i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer4_channel2_ready[i]),
                .s_axis_b_tvalid(layer3_channel2_ready[i] & sum_layer3_result_done[2*i+1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(sum_layer3_result[2*i+1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_layer4_result_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_layer4_result[i])    // output wire [31 : 0] m_axis_result_tdata
                );
           
           float_add float_adder (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(layer5_channel1_ready),
                .s_axis_a_tvalid(layer5_channel1_ready & sum_layer4_result_done[0]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(sum_layer4_result[0]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(layer5_channel2_ready),
                .s_axis_b_tvalid(layer5_channel2_ready & sum_layer4_result_done[1]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(sum_layer4_result[1]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(sum_layer5_result_done),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(sum_layer5_result)    // output wire [31 : 0] m_axis_result_tdata
                );            
    endgenerate
              
    //6 stage pipeline (multiply takes 1), without output buffer
    logic  [31:0] bias_ff [5:0];
    integer j;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            bias_ff[0] <= 32'h0;
            bias_ff[1] <= 32'h0;
            bias_ff[2] <= 32'h0;
            bias_ff[3] <= 32'h0;
            bias_ff[4] <= 32'h0;
            bias_ff[5] <= 32'h0;
//            for(j=0;j<6;j++) 
//                bias_ff[j] <= 32'h0;
        end
        else
        begin
            bias_ff[0] <= bias;
            bias_ff[1] <= bias_ff[0];
            bias_ff[2] <= bias_ff[1];
            bias_ff[3] <= bias_ff[2];
            bias_ff[4] <= bias_ff[3];
            bias_ff[5] <= bias_ff[4];
//            for(j=0;j<5;j++)
//                bias_ff[j+1] <= bias_ff[j];
        end             
    end
              
    logic  bias_channel1_ready;
    logic  bias_channel2_ready;
              
    float_add bias_adder (
         .aclk(clk),
         .aresetn(rst_n),
                
         .s_axis_a_tready(bias_channel1_ready),
         .s_axis_a_tvalid(bias_channel1_ready & sum_layer5_result_done),            // input wire s_axis_a_tvalid
         .s_axis_a_tdata(sum_layer5_result),              // input wire [31 : 0] s_axis_a_tdata
         
         .s_axis_b_tready(bias_channel2_ready),
         .s_axis_b_tvalid(bias_channel2_ready & sum_layer5_result_done),            // input wire s_axis_b_tvalid
         .s_axis_b_tdata(bias_ff[5]),              // input wire [31 : 0] s_axis_b_tdata
                
         .m_axis_result_tvalid(done),  // output wire m_axis_result_tvalid
         .m_axis_result_tdata(result)    // output wire [31 : 0] m_axis_result_tdata
         );
endmodule
