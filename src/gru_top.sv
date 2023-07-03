`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/29 10:20:19
// Design Name: 
// Module Name: gru_top
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


module gru_top
#(
    parameter GRU_ITERATION_NUM = 8'd196,
    parameter GRU_DELAY = 87 + 1// 1 for delayed request_l1
)
(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] din,
    input  logic        valid,
    
    output logic        din_request,
    output logic [7:0]  din_index,
    output logic        done,// set 1 when dense layer3 is finished
    output logic [31:0] dense_result
    //output logic [31:0] h_tm1_l2 [31:0]

    );
    
    logic valid_l1, valid_l2;
    
    //logic [31:0] din_l1;
    //logic [31:0] din_l2 [31:0];
    logic [31:0] h_tm1_l1 [31:0];    // final h_tm_l1, would stay the same when computing, and update when computation is done
    logic [31:0] h_tm1_l2 [31:0];
    logic [31:0] h_tm1_l1_tmp [31:0];// temp h_tm_l1, would update corresponding result when computing
    logic [31:0] h_tm1_l2_tmp [31:0];
    assign dense_result = h_tm1_l2[0];
    
    logic ready_l1,ready_l2;
    logic done_l1,done_l2;
    logic [31:0] dout1_l1, dout2_l1, dout1_l2, dout2_l2;
    logic request_l1, request_l2;
    //  din_request has to be a pulse!!!!!
    assign din_request = request_l1 | valid;  
    logic [7:0] layer1_cnt;
    assign din_index = layer1_cnt;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            valid_l1    <= 1'b0;
            layer1_cnt  <= 8'h0;
        end
        else if(din_request)
        begin
            if(layer1_cnt == GRU_ITERATION_NUM)// 1 to 196 is valid state, set 3 for tb, actually to be 196
            begin
                layer1_cnt  <= 8'h0;
                valid_l1    <= 1'b0;
            end
            else
            begin
                layer1_cnt  <= layer1_cnt + 8'h1;
                valid_l1    <= 1'b1;
            end
        end
        else
        begin
            layer1_cnt <= layer1_cnt;
            valid_l1    <= 1'b0;
        end
    end
    
    gru_layer1 gru1(
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid_l1),
        .h_tm1(h_tm1_l1), // should keep same before compute done
        .din(din),          // should keep same before compute done
        
        .din_request(request_l1),
        .ready(ready_l1),
        .done(done_l1),
        .dout1(dout1_l1),
        .dout2(dout2_l1)
    );
    
    logic [GRU_DELAY-1:0] valid_l2_ff;
    logic dense_valid;
    
    assign valid_l2 = valid_l2_ff[GRU_DELAY-1] | dense_valid;// valid_l2 is the delay of valid_l1 and can be excite by dense layer computation request
    integer i;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            valid_l2_ff <= 'h0;
        else
        begin
            valid_l2_ff[0] <= valid_l1;
            for(i=0;i<GRU_DELAY-1;i=i+1)
                valid_l2_ff[i+1] <= valid_l2_ff[i];
        end
    end
    
    logic [1:0] ext_manipulate;
    logic dense_done;
    
    gru_layer2 gru2(
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid_l2),
        .h_tm1_l2(h_tm1_l2), // should keep same before compute done
        .din(h_tm1_l1),          // should keep same before compute done
        .ext_manipulate(ext_manipulate),
        
        .din_request(request_l2),
        .dense_done(dense_done),
        .ready(ready_l2),
        .done(done_l2),
        .dout1(dout1_l2),
        .dout2(dout2_l2)
    );
    
    logic h_tm1_l1_buff_done, h_tm1_l2_buff_done;
    logic [3:0] h_tm1_l1_buff_cnt, h_tm1_l2_buff_cnt;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            h_tm1_l1_buff_cnt <= 4'h0;
        else if(done_l1)
            h_tm1_l1_buff_cnt <= h_tm1_l1_buff_cnt + 1;
        else
            h_tm1_l1_buff_cnt <= h_tm1_l1_buff_cnt;
    end
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            h_tm1_l2_buff_cnt <= 4'h0;
        else if((ext_manipulate==2'b10)&&(h_tm1_l2_buff_cnt == 4'd7))// only write first 16 reg
            h_tm1_l2_buff_cnt <= 4'h0;
        else if((ext_manipulate==2'b11)&&(h_tm1_l2_buff_cnt == 4'd0))// only write first 1 reg
            h_tm1_l2_buff_cnt <= 4'h0;
        else if(done_l2)
            h_tm1_l2_buff_cnt <= h_tm1_l2_buff_cnt + 1;
        else
            h_tm1_l2_buff_cnt <= h_tm1_l2_buff_cnt;
    end
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            h_tm1_l1_tmp <= '{32{32'h0}};
        else if(done_l1)
        begin
            h_tm1_l1_tmp[{h_tm1_l1_buff_cnt,1'b0}]  <= dout1_l1;
            h_tm1_l1_tmp[{h_tm1_l1_buff_cnt,1'b1}]  <= dout2_l1;
        end
    end
    always_ff @(posedge clk)
    begin
        if(!rst_n)
        begin
            h_tm1_l2_tmp <= '{32{32'h0}};
        end
        else if(done_l2)
        begin
            h_tm1_l2_tmp[{h_tm1_l2_buff_cnt,1'b0}]  <= dout1_l2;
            h_tm1_l2_tmp[{h_tm1_l2_buff_cnt,1'b1}]  <= dout2_l2;
        end
    end
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            h_tm1_l1 <= '{32{32'h0}};
        else if(request_l1)
            for(i=0;i<32;i=i+1)
                h_tm1_l1[i] <= h_tm1_l1_tmp[i];
    end
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            h_tm1_l2 <= '{32{32'h0}};
        else if(request_l2)
            for(i=0;i<32;i=i+1)
                h_tm1_l2[i] <= h_tm1_l2_tmp[i];
    end
    
    logic layer1_all_done;
    logic layer2_all_done;
    
    //set to be 3 for tb, actually for 196 for tb
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            layer1_all_done <= 1'b0;
        else if((layer1_cnt==GRU_ITERATION_NUM)&&(h_tm1_l1_buff_cnt==4'd15))
            layer1_all_done <= 1'b1;
        else
            layer1_all_done <= 1'b0;
    end
    
    logic [GRU_DELAY-1:0] layer2_all_done_ff;
    assign layer2_all_done = layer2_all_done_ff[GRU_DELAY-1];// valid_l2 is the delay of valid_l1
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            layer2_all_done_ff <= 'h0;
        else
        begin
            layer2_all_done_ff[0] <= layer1_all_done;
            for(i=0;i<GRU_DELAY-1;i=i+1)
                layer2_all_done_ff[i+1] <= layer2_all_done_ff[i];
        end
    end
    
    logic stage_done;
    assign stage_done = dense_done | layer2_all_done;   //dense_done
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            ext_manipulate <= 2'b00;
        else if(stage_done)// change when layer2 done, dense layer1 done, dense layer2 done, dense layer3 done
            ext_manipulate <= ext_manipulate + 2'd1;
        else
            ext_manipulate <= ext_manipulate;
    end
    
    //assign done = layer2_all_done;
    //logic final_stage_sigmoid_valid;
    
    // as output has extra buffer stage, the done signal should also be buffered for 1 stage to remain coherency.
    logic done_no_delay;
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            done_no_delay <= 1'b0;
        else if((stage_done)&&(ext_manipulate==2'b11))// enable sigmoid when stage of 
            done_no_delay <= 1'b1;
        else
            done_no_delay <= 1'b0;
    end
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            done <= 1'b0;
        else
            done <= done_no_delay;
    end
    
    
    always_ff @(posedge clk)
    begin
        if(!rst_n)
            dense_valid <= 1'b0;
        else if((stage_done)&&(ext_manipulate!=2'b11)) // only set when gru is done, dense layer 1 is done and dense layer 2 is done
            dense_valid <= 1'b1;
        else
            dense_valid <= 1'b0;
    end
    
endmodule
