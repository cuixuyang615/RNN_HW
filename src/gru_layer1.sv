`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 22:59:00
// Design Name: 
// Module Name: gru_layer1
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


module gru_layer1(
    input logic clk,
    input logic rst_n,
    input logic valid,
    input logic [31:0] h_tm1 [31:0], // should keep same before compute done
    input logic [31:0] din,          // should keep same before compute done
    
    output logic din_request,// would be high in the following cycle of negedge done
    output logic ready,
    output logic done,
    output logic [31:0] dout1,
    output logic [31:0] dout2

    );
    
    
    /////////////////////////////////////////////
    //             ip instantiation            //
    /////////////////////////////////////////////
    
    ///////////// warr ////////////////
    logic warr_valid, warr_ready, warr_done;
    logic [31:0] warr_din;
    logic [6:0] warr_addr_base;
    logic [31:0] warr_dout1, warr_dout2;
    
    warr_vector_linear_1x1_32x96_2ports warr_linear_2ports(
        .clk(clk),
        .rst_n(rst_n),
        .valid(warr_valid),
        .din(warr_din),
        .addr_base(warr_addr_base),//0x0 for x_z, 0x20 for x_r, 0x40 for x_h
    
        .ready(warr_ready),
        .done(warr_done),
        .dout1(warr_dout1),
        .dout2(warr_dout2)
    );
    
    ///////////// uarr ////////////////
    logic uarr_valid, uarr_ready, uarr_done;
    logic [31:0] uarr_din [31:0];
    logic [6:0] uarr_addr_base;
    logic [31:0] uarr_dout1, uarr_dout2;
    
    assign ready = uarr_ready;
    
    uarr_vector_linear_1x32_32x96_2ports uarr_linear_2ports(
    .clk(clk),
    .rst_n(rst_n),
    .valid(uarr_valid),
    .din1(uarr_din),
    .din2(uarr_din),
    .addr_base(uarr_addr_base),//0x0 for x_z, 0x20 for x_r, 0x40 for x_h

    .ready(uarr_ready),
    .done(uarr_done),
    .dout1(uarr_dout1),
    .dout2(uarr_dout2)
    );
    
    //////////////// dual float add ///////////////////
    logic [2:0]  float_add_dual_done, float_add_dual_done_ready, float_add_dual_valid;
    
    logic [31:0] float_add_dual_dout1 [2:0];
    logic [31:0] float_add_dual_dout2 [2:0];
    
    logic [31:0] float_add_dual_din1_A [2:0];
    logic [31:0] float_add_dual_din1_B [2:0];
    logic [31:0] float_add_dual_din2_A [2:0];
    logic [31:0] float_add_dual_din2_B [2:0];
    
    assign done  = float_add_dual_done [2];
    assign dout1 = float_add_dual_dout1[2];
    assign dout2 = float_add_dual_dout2[2];
    genvar i;
    generate
    for(i=0;i<3;i=i+1)
    begin
        float_add_dual float_add_dual_unit(
            .clk(clk),
            .rst_n(rst_n),
            .valid(float_add_dual_valid[i]),
            .din1_A(float_add_dual_din1_A[i]),
            .din1_B(float_add_dual_din1_B[i]),
            .din2_A(float_add_dual_din2_A[i]),
            .din2_B(float_add_dual_din2_B[i]),
        
            .ready(float_add_dual_done_ready[i]),
            .done(float_add_dual_done[i]),
            .dout1(float_add_dual_dout1[i]),
            .dout2(float_add_dual_dout2[i])
        );
    end
    endgenerate
    
    //////////////// dual float multiply  ///////////////////
    logic [1:0]  float_multiply_dual_done, float_multiply_dual_done_ready, float_multiply_dual_valid;
    
    logic [31:0] float_multiply_dual_dout1 [1:0];
    logic [31:0] float_multiply_dual_dout2 [1:0];
    
    logic [31:0] float_multiply_dual_din1_A [1:0];
    logic [31:0] float_multiply_dual_din1_B [1:0];
    logic [31:0] float_multiply_dual_din2_A [1:0];
    logic [31:0] float_multiply_dual_din2_B [1:0];    
    generate
    for(i=0;i<2;i=i+1)
    begin
        float_multiply_dual float_multiply_dual_unit(
            .clk(clk),
            .rst_n(rst_n),
            .valid(float_multiply_dual_valid[i]),
            .din1_A(float_multiply_dual_din1_A[i]),
            .din1_B(float_multiply_dual_din1_B[i]),
            .din2_A(float_multiply_dual_din2_A[i]),
            .din2_B(float_multiply_dual_din2_B[i]),
        
            .ready(float_multiply_dual_done_ready[i]),
            .done(float_multiply_dual_done[i]),
            .dout1(float_multiply_dual_dout1[i]),
            .dout2(float_multiply_dual_dout2[i])
        );
    end
    endgenerate
    
    ////////////// dual sigmoid //////////////////
    logic float_sigmoid_dual_done, float_sigmoid_dual_done_ready, float_sigmoid_dual_valid;
    
    logic [31:0] float_sigmoid_dual_din1;
    logic [31:0] float_sigmoid_dual_din2;
    logic [31:0] float_sigmoid_dual_dout1;
    logic [31:0] float_sigmoid_dual_dout2;
    float_sigmoid_dual float_sigmoid_dual0(
        .clk(clk),
        .rst_n(rst_n),
        .valid(float_sigmoid_dual_valid),
        .din1(float_sigmoid_dual_din1),
        .din2(float_sigmoid_dual_din2),
    
        .ready(float_sigmoid_dual_done_ready),
        .done(float_sigmoid_dual_done),
        .dout1(float_sigmoid_dual_dout1),
        .dout2(float_sigmoid_dual_dout2)
    );    

    ////////////// dual tanh //////////////////
    logic float_tanh_dual_done, float_tanh_dual_done_ready, float_tanh_dual_valid;
    
    logic [31:0] float_tanh_dual_din1;
    logic [31:0] float_tanh_dual_din2;
    logic [31:0] float_tanh_dual_dout1;
    logic [31:0] float_tanh_dual_dout2;
    float_tanh_dual float_tanh_dual0(
        .clk(clk),
        .rst_n(rst_n),
        .valid(float_tanh_dual_valid),
        .din1(float_tanh_dual_din1),
        .din2(float_tanh_dual_din2),
    
        .ready(float_tanh_dual_done_ready),
        .done(float_tanh_dual_done),
        .dout1(float_tanh_dual_dout1),
        .dout2(float_tanh_dual_dout2)
    ); 
    
    /////////////////////////////////////////////
    //            control generation           //
    /////////////////////////////////////////////        
    
    // state counter generate
    logic state_cnt_en;
    logic [6:0] state_cnt;// state cnt, maximum 127
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            state_cnt_en <= 7'h0;
        else if(state_cnt == 7'd85+7'd1)
            state_cnt_en <= 7'h0;
        else if(valid)
            state_cnt_en <= 7'h1;
        else
            state_cnt_en <= state_cnt_en;
    end
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            state_cnt <= 7'h0;
        else if(state_cnt == 7'd85+7'd1)
            state_cnt <= 7'h0;
        else if(valid)
            state_cnt <= state_cnt + 7'h1;
        else if(state_cnt_en)
            state_cnt <= state_cnt + 7'h1;
        else
            state_cnt <= state_cnt;
    end
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            din_request <= 1'b0;
        else if (state_cnt==7'd85+7'd1)
            din_request <= 1'b1;
        else
            din_request <= 1'b0;
    end
    //assign din_request = (state_cnt==7'd86) ? 1'b1:1'b0;
    
    //initiate warr input    
    assign warr_din = din;
    //initiate uarr input   
    genvar j;
    generate
        for(j=0;j<32;j=j+1)
            assign uarr_din[j] = h_tm1[j];
    endgenerate
    
    //initiate first add-unit input   
    assign float_add_dual_din1_A[0] = warr_dout1;// add first re_r and x_r
    assign float_add_dual_din1_B[0] = uarr_dout1;
    assign float_add_dual_din2_A[0] = warr_dout2;//add second re_r and x_r
    assign float_add_dual_din2_B[0] = uarr_dout2;
    //initiate sigmoid input
    logic [31:0] r_s_ff1 [11:0]; //delay output1 of re_r+x_r for 12 cycle
    logic [31:0] r_s_ff2 [11:0]; //delay output2 of re_r+x_r for 12 cycle
    integer g;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            for(g=0;g<12;g=g+1)
            begin
                r_s_ff1[g] <= 32'h0;
                r_s_ff2[g] <= 32'h0;
            end
        end
        else
        begin
            r_s_ff1[0] <= float_add_dual_dout1[0];
            r_s_ff2[0] <= float_add_dual_dout2[0];
            for(g=0;g<11;g=g+1)
            begin
                r_s_ff1[g+1] <= r_s_ff1[g];
                r_s_ff2[g+1] <= r_s_ff2[g];
            end
        end
    end
    assign float_sigmoid_dual_din1 = (state_cnt < 7'd65) ? r_s_ff1[11]:float_add_dual_dout1[0]; // connect to add-unit1 output(delayed) to sigmoid
    assign float_sigmoid_dual_din2 = (state_cnt < 7'd65) ? r_s_ff2[11]:float_add_dual_dout2[0]; // connect to add-unit1 output(delayed) to sigmoid
    //initiate first multiply-unit input
    assign float_multiply_dual_din1_A[0] = float_sigmoid_dual_dout1; // always assign first port to sigmoid output
    assign float_multiply_dual_din2_A[0] = float_sigmoid_dual_dout2; // always assign first port to sigmoid output    
    assign float_multiply_dual_din1_B[0] = (state_cnt > 7'd83) ? 32'h0     :
                                           (state_cnt < 7'd68) ? uarr_dout1:h_tm1[(state_cnt-7'd68)<<1];
    assign float_multiply_dual_din2_B[0] = (state_cnt > 7'd83) ? 32'h0     :
                                           (state_cnt < 7'd68) ? uarr_dout2:h_tm1[((state_cnt-7'd68)<<1)+7'd1];
    //initiate second add-unit input
    logic [31:0] warr_dout1_ff,warr_dout2_ff;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            warr_dout1_ff <= 32'h0;
            warr_dout2_ff <= 32'h0;
        end
        else
        begin
            warr_dout1_ff <= warr_dout1;
            warr_dout2_ff <= warr_dout2;
        end
    end
    assign float_add_dual_din1_A[1] = (state_cnt < 7'd68) ? float_multiply_dual_dout1[0]:32'h3F800000;// result of r*re_h or 1.0
    assign float_add_dual_din1_B[1] = (state_cnt < 7'd68) ? warr_dout1_ff:{!float_sigmoid_dual_dout1[31],float_sigmoid_dual_dout1[30:0]};// result of delayed warr or -z
    assign float_add_dual_din2_A[1] = (state_cnt < 7'd68) ? float_multiply_dual_dout2[0]:32'h3F800000;// result of r*re_h or 1.0
    assign float_add_dual_din2_B[1] = (state_cnt < 7'd68) ? warr_dout2_ff:{!float_sigmoid_dual_dout2[31],float_sigmoid_dual_dout2[30:0]};// result of delayed warr or -z
    //initiate tanh input
    assign float_tanh_dual_din1 = float_add_dual_dout1[1]; // always connect input of sigmoid to output of second add
    assign float_tanh_dual_din2 = float_add_dual_dout2[1]; // always connect input of sigmoid to output of second add
    //initiate second multiply-unit input
    assign float_multiply_dual_din1_A[1] = float_add_dual_dout1[1];//connect input to output of second add and tanh
    assign float_multiply_dual_din1_B[1] = float_tanh_dual_dout1;  //connect input to output of second add and tanh
    assign float_multiply_dual_din2_A[1] = float_add_dual_dout2[1];
    assign float_multiply_dual_din2_B[1] = float_tanh_dual_dout2;
    //initate third add-unit input
    logic [31:0] z_htm1_delay1; //call for 1 cycle delay of first multiply result
    logic [31:0] z_htm1_delay2; //call for 1 cycle delay of first multiply result
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            z_htm1_delay1 <= 32'h0;
            z_htm1_delay2 <= 32'h0;
        end
        else
        begin
            z_htm1_delay1 <= float_multiply_dual_dout1[0];
            z_htm1_delay2 <= float_multiply_dual_dout2[0];
        end
    end
    assign float_add_dual_din1_A[2] = float_multiply_dual_dout1[1]; //connect input to output of second multiply
    assign float_add_dual_din1_B[2] = z_htm1_delay1;                //connect input to output of delayed first multiply
    assign float_add_dual_din2_A[2] = float_multiply_dual_dout2[1];
    assign float_add_dual_din2_B[2] = z_htm1_delay2;
    //应该写成三段式
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            uarr_valid                  <= 1'b0;
            warr_valid                  <= 1'b0;
            uarr_addr_base              <= 7'h0;
            warr_addr_base              <= 7'h0;
            float_add_dual_valid        <= 3'h0;
            float_multiply_dual_valid   <= 2'h0;
            float_sigmoid_dual_valid    <= 1'b0;
            float_tanh_dual_valid       <= 1'b0;
        end
        else
        begin
            case(state_cnt)
                7'd0:
                begin
                    if(valid)
                    begin
                        uarr_valid     <= 1'b1;
                        uarr_addr_base <= 7'h20;// set addr to 0x20, start computing re_r,re_h
                    end
                end
                7'd5:
                begin
                    warr_valid <= 1'b1;
                    warr_addr_base <= 7'h20;// set addr to 0x20, start computing x_r,x_h
                end
                7'd9:  float_add_dual_valid [0] <= 1'b1;// enable add-unit 1 for 16 cycle, only compute re_r+x_r
                7'd22: float_sigmoid_dual_valid <= 1'b1;// enable sigmoid for 16 cycle, only calculate r=sigmoid(re_r+x_r)
                7'd25:
                begin 
                    float_add_dual_valid [0] <= 1'b0;// disable add-unit 1, finish computation of re_r+x_r
                    float_multiply_dual_valid [0] <= 1'b1;//enable multiply-unit 1 for 16 cycle, compute r*re_h
                end
                7'd26: float_add_dual_valid [1] <= 1'b1;// enable add-unit 2 for 16 cycle, compute x_h+r*re_h
                7'd27: float_tanh_dual_valid <= 1'b1;// enable tanh, compute hh=tanh(x_h+r*re_h)
                7'd32://33
                begin
                    uarr_valid <= 1'b0;// disable uarr unit, finish computation of re_r, re_h
                end
                7'd37:
                begin
                    warr_valid <= 1'b0;// disable warr unit, finish computation of x_r, x_h
                end
                7'd38: float_sigmoid_dual_valid <= 1'b0;// disable sigmoid unit, finish computation of r=sigmoid(re_r+x_r)
                7'd41: float_multiply_dual_valid [0] <= 1'b0;// disable multiply-unit 1 unit, finish computation of r*re_h
                7'd42: float_add_dual_valid [1] <= 1'b0;// disable add-unit 2, finish computation of x_h+r*re_h
                7'd43: float_tanh_dual_valid <= 1'b0;// disable tanh unit, finish computation of hh=tanh(x_h+r*re_h)
                7'd54:
                begin
                    uarr_valid <= 1'b1;//start computing re_z
                    uarr_addr_base <= 7'h0;// set addr to 0x0, start computing re_z
                end
                7'd59:
                begin
                    warr_valid <= 1'b1;// start computing x_z
                    warr_addr_base <= 7'h0;// set addr to 0x0, start computing x_z
                end
                7'd63: float_add_dual_valid [0] <= 1'b1;// enable add-unit 1 for 16 cycle, only compute re_z+x_z
                7'd64: float_sigmoid_dual_valid <= 1'b1;// enable sigmoid for 16 cycle, only calculate z=sigmoid(re_z+x_z)
                7'd67:
                begin
                    float_multiply_dual_valid [0] <= 1'b1;//enable multiply-unit 1 for 16 cycle, compute z*htm1
                    float_add_dual_valid [1] <= 1'b1;// enable add-unit 2 for 16 cycle, compute 1-z
                end
                7'd68: float_multiply_dual_valid [1] <= 1'b1;//enable multiply-unit 2 for 16 cycle, compute (1-z)*hh
                7'd69: float_add_dual_valid [2] <= 1'b1;// enable add-unit 3 for 16 cycle, compute (1-z)*hh + z*htm1
                7'd70: uarr_valid <= 1'b0;// disable uarr, finish computation of re_z
                7'd75: warr_valid <= 1'b0;// disable warr, finish computation of x_z
                7'd79: float_add_dual_valid [0] <= 1'b0;// disable add-unit 1, finish computation of re_z+x_z
                7'd80: float_sigmoid_dual_valid <= 1'b0;// disable sigmoid unit, finish computation of z=sigmoid(re_z+x_z)
                7'd83:
                begin
                    float_multiply_dual_valid [0] <= 1'b0;// disable multiply-unit 1 unit, finish computation of z*htm1    
                    float_add_dual_valid [1] <= 1'b0;// disable add-unit 2, finish computation of 1-z
                end
                7'd84: float_multiply_dual_valid [1] <= 1'b0;//disable multiply-unit 2, finish the computation of (1-z)*hh
                7'd85: float_add_dual_valid [2] <= 1'b0;// disable add-unit 3, finish computation of (1-z)*hh + z*htm1
                default:
                begin
                ;
                end   
            endcase
        end
            
    end

        
endmodule
