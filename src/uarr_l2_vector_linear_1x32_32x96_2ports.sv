`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/18 23:20:22
// Design Name: 
// Module Name: uarr_l2_vector_linear_1x32_32x96_2ports
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


module uarr_l2_vector_linear_1x32_32x96_2ports(
    input logic         clk,
    input logic         rst_n,
    input logic         valid,
    input logic  [31:0] din1 [31:0],
    input logic  [31:0] din2 [31:0],
    input logic  [6:0]  addr_base,// 0x0 for re_z (16 cycles of valid), 0x20 for re_r and re_h (32 cycles of valid).
    input logic  [1:0]  source,   // 0 for warr, 1 for dense layer1, 2 for dense layer 2, 3 for dense layer 3.

    output logic        ready,
    output logic        done,
    output logic [31:0] dout1,
    output logic [31:0] dout2

    );
    
    // input vector fifo generate, always enabled    
//    logic [31:0] zero [0:31];
//    genvar i;
//    generate
//        for(i=0;i<32;i=i+1)
//            assign zero[i] = 32'h0;
//    endgenerate
    
    logic [31:0] vector1_ff [1:0][31:0];
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            vector1_ff[0] <= '{32{32'h0}};//zero;
            vector1_ff[1] <= '{32{32'h0}};//zero;
        end
        else
        begin
            vector1_ff[0] <= din1;
            vector1_ff[1] <= vector1_ff[0];
        end
    end
    
    logic [31:0] vector2_ff [1:0][31:0];
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            vector2_ff[0] <= '{32{32'h0}};//zero;
            vector2_ff[1] <= '{32{32'h0}};//zero;
        end
        else
        begin
            vector2_ff[0] <= din2;
            vector2_ff[1] <= vector2_ff[0];
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
    
    
    logic  [31:0] weight_unit1 [31:0];
    logic  [31:0] bias_unit1;
    logic  [31:0] weight_unit2 [31:0];
    logic  [31:0] bias_unit2;
    
    logic  [31:0] weight_in_unit1 [31:0];
    logic  [31:0] bias_in_unit1;
    logic  [31:0] weight_in_unit2 [31:0];
    logic  [31:0] bias_in_unit2;
    
    logic [7:0] arr_addr_unit1;
    logic [6:0] bias_addr_unit1;
    logic [7:0] arr_addr_unit2;
    logic [6:0] bias_addr_unit2;    
    
    assign bias_addr_unit1 = {counter,1'b0} + addr_base; // compute even number
    assign arr_addr_unit1 = {bias_addr_unit1,1'b0};// arr_addr_unit1 = bias_addr_unit1 *2
    assign bias_addr_unit2 = {counter,1'b0} + addr_base + 1'b1; //compute odd number
    assign arr_addr_unit2 = {bias_addr_unit2,1'b0};// arr_addr_unit2 = bias_addr_unit2 *2
    
    logic ready_unit1, ready_unit2;
    logic done_unit1, done_unit2;
    assign ready = ready_unit1 & ready_unit2;
    assign done = done_unit1 & done_unit2;
    
/////////////// unit 1 ip ///////////////////
    uarr_l2_mem uarr_l2_bram_unit1(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit1),
       
        .dout(weight_unit1)
    );
    
    bias_r_l2_mem bias_r_l2_bram_unit1 (
        .clka(clk),
        .rsta(!rst_n),
        .addra(bias_addr_unit1),       
        .douta(bias_unit1)
    );
    
    vector_linear_32x1_1x1 re_linear_unit1(
        .clk(clk),
        .rst_n(rst_n),
        .valid(linear_en_ff[1]),
        .vector(vector1_ff[1]),  
        .weight(weight_in_unit1),
        .bias(bias_in_unit1),
        
        .ready(ready_unit1),
        .done(done_unit1),
        .result(dout1)

    );
/////////////// unit 2 ip ///////////////////    
    uarr_l2_mem uarr_l2_bram_unit2(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit2),
       
        .dout(weight_unit2)
    );
    
    bias_r_l2_mem bias_r_bram_unit2 (
        .clka(clk),
        .rsta(!rst_n),
        .addra(bias_addr_unit2),       
        .douta(bias_unit2)
    );
    
    vector_linear_32x1_1x1 re_linear_unit2(
        .clk(clk),
        .rst_n(rst_n),
        .valid(linear_en_ff[1]),
        .vector(vector2_ff[1]),  
        .weight(weight_in_unit2),
        .bias(bias_in_unit2),
        
        .ready(ready_unit2),
        .done(done_unit2),
        .result(dout2)

    );

logic [31:0] dense_l1_unit1 [31:0];
logic [31:0] dense_l1_unit2 [31:0];
logic [31:0] bias_dense_l1_unit1,bias_dense_l1_unit2;
/////////////// dense layer 1 mem ///////////////////
    dense_l1_mem dense_l1_bram_unit1(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit1),
       
        .dout(dense_l1_unit1)
    );
    
    dense_l1_mem dense_l1_bram_unit2(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit2),
       
        .dout(dense_l1_unit2)
    );
    
    bias_dense_l1_mem bias_dense_l1_bram_unit (
        .clka(clk),
        .rsta(!rst_n),
        .addra(bias_addr_unit1),       
        .douta(bias_dense_l1_unit1),
        .clkb(clk),
        .rstb(!rst_n),
        .addrb(bias_addr_unit2),       
        .doutb(bias_dense_l1_unit2)
    );
    
logic [31:0] dense_l2_unit1 [31:0];
logic [31:0] dense_l2_unit2 [31:0];
logic [31:0] bias_dense_l2_unit1,bias_dense_l2_unit2;
/////////////// dense layer 2 mem ///////////////////
    dense_l2_mem dense_l2_bram_unit1(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit1),
       
        .dout(dense_l2_unit1)
    );
    
    dense_l2_mem dense_l2_bram_unit2(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit2),
       
        .dout(dense_l2_unit2)
    );
    
    bias_dense_l2_mem bias_dense_l2_bram_unit (
        .clka(clk),
        .rsta(!rst_n),
        .addra(bias_addr_unit1),       
        .douta(bias_dense_l2_unit1),
        .clkb(clk),
        .rstb(!rst_n),
        .addrb(bias_addr_unit2),       
        .doutb(bias_dense_l2_unit2)
    );
    
logic [31:0] dense_l3_unit1 [31:0];
logic [31:0] dense_l3_unit2 [31:0];
logic [31:0] bias_dense_l3_unit1,bias_dense_l3_unit2;
/////////////// dense layer 3 mem ///////////////////
    dense_l3_mem dense_l3_bram_unit1(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit1),
       
        .dout(dense_l3_unit1)
    );
    
    dense_l3_mem dense_l3_bram_unit2(
        .clk(clk),
        .rst_n(rst_n),
        .addr_base(arr_addr_unit2),
       
        .dout(dense_l3_unit2)
    );
    
    bias_dense_l3_mem bias_dense_l3_bram_unit (
        .clka(clk),
        .rsta(!rst_n),
        .addra(bias_addr_unit1),       
        .douta(bias_dense_l3_unit1),
        .clkb(clk),
        .rstb(!rst_n),
        .addrb(bias_addr_unit2),       
        .doutb(bias_dense_l3_unit2)
    );
    
    
    //weight and bias muxer, detecting source: 0 for warr, 1 for dense layer1, 2 for dense layer 2, 3 for dense layer 3.
    integer j;
    always_comb
    begin
        case(source)
            2'b00:  //weight and bias muxer, detecting source: 0 for warr
            begin
                for(j=0;j<32;j=j+1)
                begin
                    weight_in_unit1[j]  = weight_unit1[j];
                    weight_in_unit2[j]  = weight_unit2[j];
                end
                bias_in_unit1 = bias_unit1;
                bias_in_unit2 = bias_unit2;
            end
            2'b01:  //weight and bias muxer, detecting source: 1 for dense layer1
            begin
                for(j=0;j<32;j=j+1)
                begin
                    weight_in_unit1[j]  = dense_l1_unit1[j];
                    weight_in_unit2[j]  = dense_l1_unit2[j];
                end
                bias_in_unit1 = bias_dense_l1_unit1;
                bias_in_unit2 = bias_dense_l1_unit2;
            end
            2'b10:  //weight and bias muxer, detecting source: 2 for dense layer 2
            begin
                for(j=0;j<32;j=j+1)
                begin
                    weight_in_unit1[j]  = dense_l2_unit1[j];
                    weight_in_unit2[j]  = dense_l2_unit2[j];
                end
                bias_in_unit1 = bias_dense_l2_unit1;
                bias_in_unit2 = bias_dense_l2_unit2;
            end
            2'b11:  //weight and bias muxer, detecting source: 3 for dense layer 3
            begin
                for(j=0;j<16;j=j+1)
                begin
                    weight_in_unit1[j]  = dense_l3_unit1[j];
                    weight_in_unit2[j]  = dense_l3_unit2[j];
                end
                for(j=16;j<32;j=j+1)
                begin
                    weight_in_unit1[j]  = 32'h0;// padding 0.0 for [16:31] weight
                    weight_in_unit2[j]  = 32'h0;// padding 0.0 for [16:31] weight
                end
                bias_in_unit1 = bias_dense_l3_unit1;
                bias_in_unit2 = bias_dense_l3_unit2;// padding 0.0 for bias. this value has been set to 0.0 in bram ip
            end
            //default:
        endcase
    end

endmodule
