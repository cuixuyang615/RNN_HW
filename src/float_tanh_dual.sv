`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 21:56:29
// Design Name: 
// Module Name: float_tanh_dual
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

module float_tanh_dual
#(
    parameter DIN_INT_DELAY  = 37,
    parameter DIN_SIGN_DELAY = 41
)
(
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
    assign din[0] = (din1[31]) ? {1'b0,din1[30:0]}:din1; //abs value
    assign din[1] = (din2[31]) ? {1'b0,din2[30:0]}:din2; //abs value
    
    logic [31:0] dout [1:0]; 
    logic [DIN_SIGN_DELAY-1:0] din1_sign_ff;
    logic [DIN_SIGN_DELAY-1:0] din2_sign_ff;
    integer j;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            din1_sign_ff <= 'h0;
            din2_sign_ff <= 'h0;
        end
        else
        begin
            din1_sign_ff[0] <= din1[31];
            din2_sign_ff[0] <= din2[31];
            for(j=0;j<DIN_SIGN_DELAY-1;j=j+1)
            begin
                din1_sign_ff[j+1] <= din1_sign_ff[j];
                din2_sign_ff[j+1] <= din2_sign_ff[j];
            end
        end
    end
    
    
    assign dout1 = {din1_sign_ff[DIN_SIGN_DELAY-1],dout[0][30:0]};
    assign dout2 = {din2_sign_ff[DIN_SIGN_DELAY-1],dout[1][30:0]};
    
    logic [1:0]  sinh_cosh_done;
    logic [1:0]  sinh_cosh_convert_done;
    
    logic sinh_done [1:0];
    logic cosh_done [1:0];
    logic [31:0] sinh_result [1:0];
    logic [31:0] cosh_result [1:0];
    
    logic [31:0] sinh_float [1:0];
    logic [31:0] cosh_float [1:0];
    
    //wire [63:0] sin_cos_result [7:0];
    
    logic [1:0] tanh_done;
    assign done = &tanh_done;
    
    logic [1:0] float2fix_done;
    logic [39:0] din_fixed [1:0];//valid for 35 bit, 6 int + 29 fractional
    logic [4:0] din_int [1:0];// 5 bit int, without sign bit
    logic [28:0] din_frac [1:0];
    
    logic [1:0] float2fix_ready;
    logic [1:0] cordic_ready;
    logic [1:0] sinh_fix2float_ready;
    logic [1:0] cosh_fix2float_ready;
    logic [1:0] divide_ready_channel1, divide_ready_channel2;
    assign ready = & float2fix_ready;
    
    logic [31:0] multiply_din1 [1:0] [3:0];
    logic [31:0] multiply_din2 [1:0] [3:0];
    logic [3:0] multiply_channel1_ready [1:0];
    logic [3:0] multiply_channel2_ready [1:0] ;
    logic [3:0] multiply_done [1:0];
    logic [31:0] multiply_result [1:0] [3:0];
    
    logic [1:0] add_channel1_ready [1:0];
    logic [1:0] add_channel2_ready [1:0] ;
    logic [1:0] add_done [1:0];
    logic [31:0] add_result [1:0] [1:0];
    
    logic [31:0] cosh [31:0];// = '{'{32'h3f800000},'{32'h3fc583ab},'{32'h4070c7d0},'{32'h41211525},'{32'h41da7743},'{32'h42946b7e},'{32'h4349b734},'{32'h4409144a},'{32'h44ba4f55},'{32'h457d38ac},'{32'h462c14ef},'{32'h46e9e224},'{32'h479ef0b3},'{32'h485805ad},'{32'h4912cd62},'{32'h49c78665},'{32'h4a87975f},'{32'h4b3849a4},'{32'h4bfa7910},'{32'h4caa36c8},'{32'h4d675844},'{32'h4e1d3710},'{32'h4ed5ad6e},'{32'h4f91357a},'{32'h50455bfe},'{32'h51061e9d},'{32'h51b64993},'{32'h5277c118},'{32'h53285dd2},'{32'h53e4d572},'{32'h549b8238},'{32'h55535bb3}};
    logic [31:0] sinh [31:0];// = '{'{32'h00000000},'{32'h3f966cfe},'{32'h40681e7b},'{32'h41204937},'{32'h41da51c0},'{32'h4294680b},'{32'h4349b691},'{32'h4409143b},'{32'h44ba4f53},'{32'h457d38ac},'{32'h462c14ee},'{32'h46e9e224},'{32'h479ef0b3},'{32'h485805ad},'{32'h4912cd62},'{32'h49c78665},'{32'h4a87975f},'{32'h4b3849a4},'{32'h4bfa7910},'{32'h4caa36c8},'{32'h4d675844},'{32'h4e1d3710},'{32'h4ed5ad6e},'{32'h4f91357a},'{32'h50455bfe},'{32'h51061e9d},'{32'h51b64993},'{32'h5277c118},'{32'h53285dd2},'{32'h53e4d572},'{32'h549b8238},'{32'h55535bb3}};
    initial
    begin
        $readmemh("E:/PG/final project/sinh.txt",sinh);
        $readmemh("E:/PG/final project/cosh.txt",cosh);
    end
    logic [4:0] din_int_ff [1:0] [DIN_INT_DELAY-1:0];
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            din_int_ff <= '{'{DIN_INT_DELAY{5'h0}},'{DIN_INT_DELAY{5'h0}}};
        end
        else
        begin
            din_int_ff[0][0] <= din_int[0];
            din_int_ff[1][0] <= din_int[1];
            for(j=0;j<DIN_INT_DELAY-1;j=j+1)
            begin
                din_int_ff[0][j+1] <= din_int_ff[0][j];
                din_int_ff[1][j+1] <= din_int_ff[1][j];
            end
        end
    end
    
    genvar i,k;
    generate
        
        for(i=0;i<2;i=i+1)
        begin    
            assign din_int[i] = din_fixed[i][33:29];
            assign din_frac[i] = din_fixed[i][28:0];
            
            floati2fix fixed_converter (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(float2fix_ready[i]),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(float2fix_ready[i] & valid),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(din[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .m_axis_result_tvalid(float2fix_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(din_fixed[i])    // output wire [31 : 0] m_axis_result_tdata
                );
         
            cordic_sinh_cosh cordic (
                .aclk(clk),                                 // input wire aclk
                .aresetn(rst_n),                            // input wire aresetn
                
                .s_axis_phase_tready(cordic_ready[i]),            // output wire s_axis_a_tready
                .s_axis_phase_tvalid(cordic_ready[i] & float2fix_done[i]),           // input wire s_axis_phase_tvalid
                .s_axis_phase_tdata({3'b000,din_frac[i]}),//extend to fractional float:+0.xxx                  // input wire [31 : 0] s_axis_phase_tdata
                
                .m_axis_dout_tvalid(sinh_cosh_done[i]),       // output wire m_axis_dout_tvalid
                .m_axis_dout_tdata({sinh_result[i],cosh_result[i]})       // output wire [63 : 0] m_axis_dout_tdata
                );
                
           fix2float sinh_converter (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(sinh_fix2float_ready[i]),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(sinh_fix2float_ready[i] & sinh_cosh_done[i]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(sinh_result[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .m_axis_result_tvalid(sinh_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(sinh_float[i])    // output wire [31 : 0] m_axis_result_tdata
                );
                
           fix2float cosh_converter (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(cosh_fix2float_ready[i]),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(cosh_fix2float_ready[i] & sinh_cosh_done[i]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(cosh_result[i]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .m_axis_result_tvalid(cosh_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(cosh_float[i])    // output wire [31 : 0] m_axis_result_tdata
                );
                
            assign sinh_cosh_convert_done[i] = cosh_done[i] & sinh_done[i];
            
            // for din1: sinh, cosh, cosh, sinh of din_int
            assign multiply_din1 [i][0] = sinh[din_int_ff[i][DIN_INT_DELAY-1]];
            assign multiply_din1 [i][1] = cosh[din_int_ff[i][DIN_INT_DELAY-1]];
            assign multiply_din1 [i][2] = cosh[din_int_ff[i][DIN_INT_DELAY-1]];
            assign multiply_din1 [i][3] = sinh[din_int_ff[i][DIN_INT_DELAY-1]];
            // for din1: cosh, sinh, cosh, sinh of din_frac
            assign multiply_din2 [i][0] = cosh_float[i];
            assign multiply_din2 [i][1] = sinh_float[i];
            assign multiply_din2 [i][2] = cosh_float[i];
            assign multiply_din2 [i][3] = sinh_float[i];
            
            // compute sinh(int)*cosh(frac) ,cosh(int)*sinh(frac), cosh(int)*cosh(frac), sinh(int)*sinh(frac) in sequence
            for(k=0;k<4;k=k+1)
            begin
                //sinh(int) * cosh(frac)
                float_multiply float_multiplier (
                    .aclk(clk),
                    .aresetn(rst_n),
                                
                    .s_axis_a_tready(multiply_channel1_ready[i][k]),
                    .s_axis_a_tvalid(multiply_channel1_ready[i][k] & sinh_cosh_convert_done[i]),            // input wire s_axis_a_tvalid
                    .s_axis_a_tdata(multiply_din1[i][k]),              // input wire [31 : 0] s_axis_a_tdata
                                
                    .s_axis_b_tready(multiply_channel2_ready[i][k]),
                    .s_axis_b_tvalid(multiply_channel2_ready[i][k] & sinh_cosh_convert_done[i]),            // input wire s_axis_b_tvalid
                    .s_axis_b_tdata(multiply_din2[i][k]),              // input wire [31 : 0] s_axis_b_tdata
                                
                    .m_axis_result_tvalid(multiply_done[i][k]),  // output wire m_axis_result_tvalid
                    .m_axis_result_tdata(multiply_result[i][k])    // output wire [31 : 0] m_axis_result_tdata
                );
            end
            for(k=0;k<2;k=k+1)
            begin
                float_add float_adder1 (
                    .aclk(clk),
                    .aresetn(rst_n),
                                
                    .s_axis_a_tready(add_channel1_ready[i][k]),
                    .s_axis_a_tvalid(add_channel1_ready[i][k] & multiply_done[i][2*k]),            // input wire s_axis_a_tvalid
                    .s_axis_a_tdata(multiply_result[i][2*k]),              // input wire [31 : 0] s_axis_a_tdata
                                
                    .s_axis_b_tready(add_channel2_ready[i][k]),
                    .s_axis_b_tvalid(add_channel2_ready[i][k] & multiply_done[i][2*k+1]),            // input wire s_axis_b_tvalid
                    .s_axis_b_tdata((multiply_result[i][2*k+1])),              // input wire [31 : 0] s_axis_b_tdata
                                
                    .m_axis_result_tvalid(add_done[i][k]),  // output wire m_axis_result_tvalid
                    .m_axis_result_tdata(add_result[i][k])    // output wire [31 : 0] m_axis_result_tdata
                );
            end
           
            float_divide float_divider (
                  .aclk(clk),                                  // input wire aclk
                  .aresetn(rst_n),                            // input wire aresetn
                  
                  .s_axis_a_tready(divide_ready_channel1[i]),            // output wire s_axis_a_tready
                  .s_axis_a_tvalid(divide_ready_channel1[i] & add_done[i][0]),            // input wire s_axis_a_tvalid
                  .s_axis_a_tdata(add_result[i][0]),              // input wire [31 : 0] s_axis_a_tdata
                  
                  .s_axis_b_tready(divide_ready_channel2[i]),            // output wire s_axis_a_tready
                  .s_axis_b_tvalid(divide_ready_channel2[i] & add_done[i][1]),            // input wire s_axis_b_tvalid
                  .s_axis_b_tdata(add_result[i][1]),              // input wire [31 : 0] s_axis_b_tdata
                  
                  .m_axis_result_tvalid(tanh_done[i]),  // output wire m_axis_result_tvalid
                  .m_axis_result_tdata(dout[i])    // output wire [31 : 0] m_axis_result_tdata
                );
        end        
    endgenerate
    
    //logic [31:0] test;
    //assign test = sinh[{4'h0, rst_n}];
endmodule
