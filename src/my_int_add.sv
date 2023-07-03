// int adder with done signal output
module my_int_add(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        ADD,
    input  logic        CE,
    input  logic [31:0] A,
    input  logic [31:0] B,

    output logic        ready,
    output logic [31:0] dout,
    output logic        done   //only high for 1 cycle when finished
);

    logic [31:0] S;
    int_add int_adder (
          .A(A),      // input wire [31 : 0] A
          .B(B),      // input wire [31 : 0] B
          //.CLK(clk),  // input wire CLK
          .ADD(ADD),  // input wire ADD
          .CE(CE),    // input wire CE
          .S(S)      // output wire [31 : 0] S
        );
    
    // works when latency = 0
    always_ff @(posedge clk)
    begin
        if(CE)
            done <= 1'b1;
        else
            done <= 1'b0;
    end
    
    assign dout = (rst_n) ? S:32'h0;
    assign ready = 1; //always ready;
endmodule
