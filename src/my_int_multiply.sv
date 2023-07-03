`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2023 16:10:59
// Design Name: 
// Module Name: my_int_multiply
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


// int adder with done signal output
module my_int_multiply(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        CE,
    input  logic [31:0] A,
    input  logic [31:0] B,
    
    output logic        ready,
    output logic [63:0] dout,
    output logic        done   //only high for 1 cycle when finished
);
    
    logic [63:0] P;
    
    int_multiply int_multiplier (
      //.CLK(clk),  // input wire CLK
      .A(A),      // input wire [31 : 0] A
      .B(B),      // input wire [31 : 0] B
      //.CE(CE),    // input wire CE
      .P(P)      // output wire [63 : 0] P
    );

    // works when latency = 0
    always_ff @(posedge clk)
    begin
        if(CE)
            done <= 1'b1;
        else
            done <= 1'b0;
    end
    
    assign dout = (rst_n) ? P:64'h0;
    assign ready = 1; //always ready;
    
endmodule
