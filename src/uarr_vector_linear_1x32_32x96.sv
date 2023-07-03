`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/10 16:00:29
// Design Name: 
// Module Name: uarr_vector_linear_32x1_32x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     first version, one valid pulse will make module compute consecutive 32 re element based on 
// addr_base(0x0 for re_z, 0x20 for re_r, 0x40 for re_h)
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uarr_vector_linear_1x32_32x96(
    input logic         clk,
    input logic         rst_n,
    input logic         valid,
    input logic  [31:0] din [31:0],
    input logic  [6:0]  addr_base,//0x0 for re_z, 0x20 for re_r, 0x40 for re_h

    output logic        ready,
    output logic        done,
    output logic [31:0] dout

    );
    
    logic  [31:0] weight [31:0];
    logic  [31:0] bias;
    
    logic [7:0] uarr_addr;
    logic [6:0] bias_addr;
    assign uarr_addr = {bias_addr,1'b0};// uarr_addr = bias_addr *2
    
    // input vector fifo generate, always enabled    
    logic [31:0] vector_ff [3:0][31:0];
    logic [31:0] zero [0:31];
    genvar i;
    generate
        for(i=0;i<32;i=i+1)
            assign zero[i] = 32'h0;
    endgenerate
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            vector_ff[0] <= zero;
            vector_ff[1] <= zero;
            vector_ff[2] <= zero;
            vector_ff[3] <= zero;
        end
        else
        begin
            vector_ff[0] <= din;
            vector_ff[1] <= vector_ff[0];
            vector_ff[2] <= vector_ff[1];
            vector_ff[3] <= vector_ff[2];
        end
    end
    
    logic cnt_en;
    logic [4:0] counter;//maximum 32
    assign bias_addr = counter + addr_base;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            cnt_en <= 0;
        else if(counter == 5'd31)
            cnt_en <= 0;
        else if(valid)
            cnt_en <= 1;
    end
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            counter <= 5'h0; //re_z for default
        else if(cnt_en)
            counter <= counter + 1;
        else
            counter <= 5'h0; 
    end
    
    logic [2:0]linear_en_ff;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            linear_en_ff <= 2'h0;
        else
            linear_en_ff <= {linear_en_ff[1:0], cnt_en};
    end
        
    uarr_mem uarr_bram(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(uarr_addr),
       
        .dout(weight)
    );
    
    bias_r bias_r_bram (
        .clka(clk),
        .rsta(!rst_n),
        .addra(bias_addr),       
        .douta(bias)
    );
    
    vector_linear_32x1_1x1 re_linear(
        .clk(clk),
        .rst_n(rst_n),
        .valid(linear_en_ff[1]),
        .vector(vector_ff[2]),  
        .weight(weight),
        .bias(bias),
        
        .ready(ready),
        .done(done),
        .result(dout)

    );


    
endmodule
