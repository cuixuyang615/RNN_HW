`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 11:52:23
// Design Name: 
// Module Name: warr_vector_linear_1x1_32x96_2ports
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


module warr_vector_linear_1x1_32x96_2ports(
    input logic         clk,
    input logic         rst_n,
    input logic         valid,
    input logic  [31:0] din,
    input logic  [6:0]  addr_base,//0x0 for x_z (16 cycles of valid), 0x20 for x_r and x_h (32 cycles of valid)

    output logic        ready,
    output logic        done,
    output logic [31:0] dout1,
    output logic [31:0] dout2
    );
    
    // input vector fifo generate, always enabled    
    
    logic [31:0] din_ff [1:0];
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            din_ff[0] <= 32'h0;
            din_ff[1] <= 32'h0;
        end
        else
        begin
            din_ff[0] <= din;
            din_ff[1] <= din_ff[0];
        end
    end

    
    logic [4:0] counter;//maximum 32
//    logic cnt_en;
//    always_ff @(posedge clk)
//    begin
//        if(!rst_n)
//            cnt_en <= 0;
//        else if(counter == 5'd31)
//            cnt_en <= 0;
//        else if(valid)
//            cnt_en <= 1;
//    end
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            counter <= 5'h0; //re_z for default
        else if(valid)
            counter <= counter + 1;
        else
            counter <= 5'h0; 
    end
    
    logic [1:0]linear_en_ff;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            linear_en_ff <= 2'h0;
        else
            linear_en_ff <= {linear_en_ff[1:0], valid};
    end
    
    
    logic  [31:0] weight [1:0];
    logic  [31:0] bias [1:0];
    
    logic [6:0] warr_addr_unit1;
    logic [6:0] bias_addr_unit1;
    logic [6:0] warr_addr_unit2;
    logic [6:0] bias_addr_unit2;    
    
    assign bias_addr_unit1 = {counter,1'b0} + addr_base; // compute even number
    assign warr_addr_unit1 = bias_addr_unit1;// warr_addr_unit1 = bias_addr_unit1
    assign bias_addr_unit2 = {counter,1'b0} + addr_base + 1'b1; //compute odd number
    assign warr_addr_unit2 = bias_addr_unit2;// warr_addr_unit2 = bias_addr_unit2
    
    warr_mem warr_bram (
      .clka(clk),    // input wire clka
      .rsta(!rst_n),    // input wire rsta
      .addra(warr_addr_unit1),  // input wire [6 : 0] addra
      .douta(weight[0]),  // output wire [31 : 0] douta
      .clkb(clk),    // input wire clkb
      .rstb(!rst_n),    // input wire rstb
      .addrb(warr_addr_unit2),  // input wire [6 : 0] addrb
      .doutb(weight[1])  // output wire [31 : 0] doutb
    );
    
    bias_i_mem bias_i_bram (
      .clka(clk),    // input wire clka
      .rsta(!rst_n),    // input wire rsta
      .addra(bias_addr_unit1),  // input wire [6 : 0] addra
      .douta(bias[0]),  // output wire [31 : 0] douta
      .clkb(clk),    // input wire clkb
      .rstb(!rst_n),    // input wire rstb
      .addrb(bias_addr_unit2),  // input wire [6 : 0] addrb
      .doutb(bias[1])  // output wire [31 : 0] doutb
    );
    logic [31:0] bias_ff [1:0];
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            bias_ff[0] <= 32'h0;
            bias_ff[1] <= 32'h0;
        end
        else
        begin
            bias_ff[0] <= bias[0];
            bias_ff[1] <= bias[1];
        end
    end
    logic multiply_ready[1:0];
    logic multiply_channel1_ready[1:0];
    logic multiply_channel2_ready[1:0];
    
    logic dot_done [1:0];
    logic [31:0] dot_result [1:0];
    
    logic add_channel1_ready[1:0];
    logic add_channel2_ready[1:0];
    
    logic add_done [1:0];
    logic [31:0] dout [1:0];
    assign dout1 = dout[0];
    assign dout2 = dout[1];
    
    assign done = add_done[0] & add_done[1];
    assign ready = multiply_ready[0] & multiply_ready[1];
    genvar i;
    generate        
        for(i=0;i<2;i=i+1)
        begin
        
            assign multiply_ready[i] = multiply_channel1_ready[i] & multiply_channel2_ready[i];
        
            float_multiply float_multiplier_warr (
              .aclk(clk),
              .aresetn(rst_n),
              
              .s_axis_a_tready(multiply_channel1_ready[i]),
              .s_axis_a_tvalid(multiply_channel1_ready[i] & linear_en_ff[1]),            // input wire s_axis_a_tvalid
              .s_axis_a_tdata(din_ff[1]),              // input wire [31 : 0] s_axis_a_tdata
              
              .s_axis_b_tready(multiply_channel2_ready[i]),
              .s_axis_b_tvalid(multiply_channel2_ready[i] & linear_en_ff[1]),            // input wire s_axis_b_tvalid
              .s_axis_b_tdata(weight[i]),              // input wire [31 : 0] s_axis_b_tdata
              
              .m_axis_result_tvalid(dot_done[i]),  // output wire m_axis_result_tvalid
              .m_axis_result_tdata(dot_result[i])    // output wire [31 : 0] m_axis_result_tdata
            );
        end
        for(i=0;i<2;i=i+1)
        begin    
            float_add float_adder_warr (
                .aclk(clk),
                .aresetn(rst_n),
                
                .s_axis_a_tready(add_channel1_ready[i]),
                .s_axis_a_tvalid(add_channel1_ready[i] & dot_done[i]),            // input wire s_axis_a_tvalid
                .s_axis_a_tdata(bias_ff[i]),              // input wire [31 : 0] s_axis_a_tdata
                
                .s_axis_b_tready(add_channel2_ready[i]),
                .s_axis_b_tvalid(add_channel2_ready[i] & dot_done[i]),            // input wire s_axis_b_tvalid
                .s_axis_b_tdata(dot_result[i]),              // input wire [31 : 0] s_axis_b_tdata
                
                .m_axis_result_tvalid(add_done[i]),  // output wire m_axis_result_tvalid
                .m_axis_result_tdata(dout[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        
        end
    
    endgenerate
    
endmodule
