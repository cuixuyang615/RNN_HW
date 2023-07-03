`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2023 16:34:12
// Design Name: 
// Module Name: int_logic
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


module int_logic(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              CE,
    input  logic [31:0]       A,
    input  logic [31:0]       B,
    
    //expansional, perform:
    //                    AND if 1,  OR if 0 bitwise now
    //                    SLT if 2,  3 for nothing
    input  logic [ 1:0]       logic_ctrl, 
    
    output logic              ready,
    output logic [31:0]       dout,
    output logic              done

    );
    
    logic [31:0] result;
    
    always_ff @(posedge clk)
    begin
        if((!CE) | (!rst_n))
            result <= 32'h0;
        else
        begin
            case(logic_ctrl)
                2'd2:       result <= (A < B);//SLT
                2'd1:       result <=  A & B;//AND
                2'd0:       result <=  A | B;//OR
                default:    result <=  32'h0;
            endcase
        end
    end
    
    // works when latency = 0
    always_ff @(posedge clk)
    begin
        if((!CE) | (!rst_n))
            done <= 1'b0;
        else
            done <= 1'b1;
    end
    
    assign dout = (rst_n) ? result:32'h0;
    assign ready = 1; //always ready;
    
endmodule
