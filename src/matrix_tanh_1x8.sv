`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2023 16:54:15
// Design Name: 
// Module Name: matrix_tanh_1x8
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
//  old version tanh, using cos and sin ip core in vivado
//////////////////////////////////////////////////////////////////////////////////


module matrix_tanh_1x8(
    input           clk,
    input           rst_n,
    input   [7:0]   din_valid,
    input   [31:0]  din [7:0],    // |A| < pi/4 (0.7854)
                                // The phase signals are always represented using a fixed-point
                                // twos complement number with an integer width of 3 bits
    
    output          ready,
    output          done,
    output  [31:0]  dout [7:0]

    );
    
    wire [7:0]  sinh_cosh_done;
    wire [7:0]  sinh_cosh_convert_done;
    
    wire sinh_done [7:0];
    wire cosh_done [7:0];
    wire [31:0] sinh_result [7:0];
    wire [31:0] cosh_result [7:0];
    
    wire [31:0] sinh_float [7:0];
    wire [31:0] cosh_float [7:0];
    
    //wire [63:0] sin_cos_result [7:0];
    
    wire [7:0] tanh_done;
    assign done = &tanh_done;
    
    wire [7:0] float2fix_done;
    wire [31:0] din_fixed [7:0];
    
    wire float2fix_ready;
    wire cordic_ready;
    wire sinh_fix2float_ready;
    wire cosh_fix2float_ready;
    wire divide_ready_channel1, divide_ready_channel2;
    assign ready = float2fix_ready;
    
    genvar i;
    generate
    
        for(i=0;i<8;i=i+1)
        begin    
            floati2fix fixed_converter (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(float2fix_ready),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(float2fix_ready & din_valid[i]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(din[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .m_axis_result_tvalid(float2fix_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(din_fixed[i])    // output wire [31 : 0] m_axis_result_tdata
                );
         
            cordic_sinh_cosh cordic (
                .aclk(clk),                                 // input wire aclk
                .aresetn(rst_n),                            // input wire aresetn
                
                .s_axis_phase_tready(cordic_ready),            // output wire s_axis_a_tready
                .s_axis_phase_tvalid(cordic_ready & float2fix_done[i]),           // input wire s_axis_phase_tvalid
                .s_axis_phase_tdata(din_fixed[i]),                  // input wire [31 : 0] s_axis_phase_tdata
                
                .m_axis_dout_tvalid(sinh_cosh_done[i]),       // output wire m_axis_dout_tvalid
                .m_axis_dout_tdata({sinh_result[i],cosh_result[i]})       // output wire [63 : 0] m_axis_dout_tdata
                );
                
           fix2float sinh_converter (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(sinh_fix2float_ready),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(sinh_fix2float_ready & sinh_cosh_done[i]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(sinh_result[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .m_axis_result_tvalid(sinh_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(sinh_float[i])    // output wire [31 : 0] m_axis_result_tdata
                );
                
           fix2float cosh_converter (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(cosh_fix2float_ready),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(cosh_fix2float_ready & sinh_cosh_done[i]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(cosh_result[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .m_axis_result_tvalid(cosh_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(cosh_float[i])    // output wire [31 : 0] m_axis_result_tdata
                );
                
            assign sinh_cosh_convert_done[i] = cosh_done[i] & sinh_done[i];
                
            float_divide float_divider (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(divide_ready_channel1),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(divide_ready_channel1 & sinh_cosh_convert_done[i]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(sinh_float[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .s_axis_b_tready(divide_ready_channel2),            // output wire s_axis_a_tready
                  .s_axis_b_tvalid(divide_ready_channel2 & sinh_cosh_convert_done[i]),            // input wire s_axis_b_tvalid
                  .s_axis_b_tdata(cosh_float[i]),              // input wire [31 : 0] s_axis_b_tdata
                  
                  .m_axis_result_tvalid(tanh_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(dout[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        end
        
    endgenerate
            
endmodule