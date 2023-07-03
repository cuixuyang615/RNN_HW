`include "ALU_defines.sv"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2023 15:36:00
// Design Name: 
// Module Name: ALU
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


module ALU(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic    [31:0]   oprandA [7:0],
    input  logic    [31:0]   oprandB [7:0],
    input  logic    [3:0]    ALUctr,             //marcos defined in ALU_defines.sv
    
    output logic             ready,
    output logic             zero,
    output logic             done,               //combinational
    output logic    [31:0]   ALUout  [7:0]       //combinational

    );
    
    // comparator, could also be realized by using sub
    assign zero = (oprandA[0] == oprandB[0]) ? 1'b1:1'b0;
    
    //matrix tanh operation unit
    logic matrix_tanh_en;
    logic matrix_tanh_done;
    logic [31:0] matrix_tanh_result [7:0];
    logic matrix_tanh_ready;
    
    matrix_tanh_1x8 matrix_tanh(
        .clk                (         clk         ),
        .rst_n              (        rst_n        ),
        .din_valid          ( {8{matrix_tanh_en}} ),
        .din                (       oprandA       ),
        
        .ready              (  matrix_tanh_ready  ),
        .done               (   matrix_tanh_done  ),
        .dout               (  matrix_tanh_result )    
        );
    
    //matrix sigmoid operation unit
    logic matrix_sigmoid_en;
    logic matrix_sigmoid_done;
    logic [31:0] matrix_sigmoid_result [7:0];
    logic matrix_sigmoid_ready;
    
    matrix_sigmoid_1x8 matrix_sigmoid(
        .clk                (          clk           ),
        .rst_n              (          rst_n         ),
        .din_valid          ( {8{matrix_sigmoid_en}} ),
        .din                (         oprandA        ),
        
        .ready              (  matrix_sigmoid_ready  ),
        .done               (   matrix_sigmoid_done  ),
        .dout               (  matrix_sigmoid_result )    
        );
    
    //matrix dot operation unit
    logic matrix_dot_en;
    logic matrix_dot_done;
    logic [31:0] matrix_dot_result [7:0];
    logic matrix_dot_ready;
    
    matrix_dot_1x8_8x1 matrix_dot(
        .clk                (        clk         ),
        .rst_n              (       rst_n        ),
        .A_valid            ( {8{matrix_dot_en}} ),
        .B_valid            ( {8{matrix_dot_en}} ),
        .A                  (       oprandA      ),
        .B                  (       oprandB      ),
        
        .ready              (  matrix_dot_ready  ),
        .done               (   matrix_dot_done  ),
        .result             (  matrix_dot_result )    
        );
        
    //matrix add operation unit
    logic matrix_add_en;
    logic matrix_add_done;
    logic [31:0] matrix_add_result [7:0];
    logic matrix_add_ready;
    
    matrix_add_1x8_8x1 matrix_add(
        .clk                (        clk         ),
        .rst_n              (       rst_n        ),
        .A_valid            ( {8{matrix_add_en}} ),
        .B_valid            ( {8{matrix_add_en}} ),
        .A                  (       oprandA      ),
        .B                  (       oprandB      ),
    
        .ready              (  matrix_add_ready  ),
        .done               (   matrix_add_done  ),
        .result             (  matrix_add_result )    
    );
    
    //matrix sum operation unit        
    logic matrix_sum_en;
    logic matrix_sum_done;
    logic [31:0] matrix_sum_result;
    logic matrix_sum_ready;
    
    matrix_sum_1x8 matrix_sum(
        .clk                (        clk         ),
        .rst_n              (       rst_n        ),
        .matrix_in_valid    ( {8{matrix_sum_en}} ),
        .matrix_in          (       oprandA      ),

        .ready              (  matrix_sum_ready  ),
        .done               (   matrix_sum_done  ),
        .result             (  matrix_sum_result )
    );

    //float point add or sub operation unit    
    logic float_add_en;
    logic float_add_done;
    logic [31:0] float_add_result;
    logic [31:0] float_add_oprandB;
    
    logic float_add_ready;
    logic float_add_channel1_ready;
    logic float_add_channel2_ready;
    assign float_add_ready = float_add_channel1_ready & float_add_channel2_ready;
    
    logic [31:0] single32_oprandB;   //first 32bit number in oprandB group
    assign single32_oprandB = oprandB[0];
    
    //for float number, directly invert sign-bit if it is an sub, in default it is an add
    assign float_add_oprandB = (ALUctr==`ALUFSUB) ? {!single32_oprandB[31],single32_oprandB[30:0]}:single32_oprandB;
    
    float_add float_adder (
        .aclk                 (        clk         ),
        .aresetn              (       rst_n        ),
        
        .s_axis_a_tready      (  float_add_channel1_ready   ),
        .s_axis_a_tvalid      (    float_add_en    ),               // input wire s_axis_a_tvalid
        .s_axis_a_tdata       (     oprandA[0]     ),               // input wire [31 : 0] s_axis_a_tdata
        
        .s_axis_b_tready      (  float_add_channel2_ready   ),
        .s_axis_b_tvalid      (    float_add_en    ),               // input wire s_axis_b_tvalid
        .s_axis_b_tdata       ( float_add_oprandB  ),               // input wire [31 : 0] s_axis_b_tdata
        
        .m_axis_result_tvalid (   float_add_done   ),               // output wire m_axis_result_tvalid
        .m_axis_result_tdata  (  float_add_result  )                // output wire [31 : 0] m_axis_result_tdata
    );
    
    //float point multiply operation unit
    logic float_multiply_en;
    logic float_multiply_done;
    logic [31:0] float_multiply_result;
    
    logic float_mul_ready;
    logic float_mul_channel1_ready;
    logic float_mul_channel2_ready;
    assign float_mul_ready = float_mul_channel1_ready & float_mul_channel2_ready;
    
    float_multiply float_multiplier (
        .aclk                 (        clk         ),
        .aresetn              (       rst_n        ),
        
        .s_axis_a_tready      (  float_mul_channel1_ready   ),
        .s_axis_a_tvalid      (  float_multiply_en ),               // input wire s_axis_a_tvalid
        .s_axis_a_tdata       (     oprandA[0]     ),               // input wire [31 : 0] s_axis_a_tdata
        
        .s_axis_b_tready      (  float_mul_channel2_ready   ),
        .s_axis_b_tvalid      (  float_multiply_en ),               // input wire s_axis_b_tvalid
        .s_axis_b_tdata       (     oprandB[0]     ),               // input wire [31 : 0] s_axis_b_tdata
        
        .m_axis_result_tvalid ( float_multiply_done),               // output wire m_axis_result_tvalid
        .m_axis_result_tdata  (float_multiply_result)               // output wire [31 : 0] m_axis_result_tdata
    );
    
    //int add operation unit
    logic int_add_en;
    logic int_add_done;
    logic [31:0] int_add_result;
    
    logic int_add_ready;
    
    logic int_add_ctrl; //control whether to perform an add or a sub
    assign int_add_ctrl = (ALUctr==`ALUSUB) ? 0:1;//0 for sub, 1 for add(default)
    
    my_int_add int_adder (
        .clk                  (        clk        ),        // input wire CLK
        .rst_n                (       rst_n       ),
        .A                    (     oprandA[0]    ),        // input wire [31 : 0] A
        .B                    (     oprandB[0]    ),        // input wire [31 : 0] B
        .ADD                  (    int_add_ctrl   ),        // input wire ADD
        .CE                   (     int_add_en    ),        // input wire CE
        
        .ready                (   int_add_ready   ),
        .dout                 (   int_add_result  ),        // output wire [31 : 0] S
        .done                 (    int_add_done   )
    );
    
    //int multiply operation unit
    logic int_multiply_en;
    logic int_multiply_done;
    logic int_multiply_ready;
    
    logic [63:0] int_multiply_result; //64 bits
    logic [31:0] int_multiply_result_high, int_multiply_result_low; // two 32-bit result for register storing
    assign {int_multiply_result_high,int_multiply_result_low} = int_multiply_result;
    
    my_int_multiply int_multiplier (
        .clk                  (        clk        ),        // input wire CLK
        .rst_n                (       rst_n       ),
        .A                    (     oprandA[0]    ),        // input wire [31 : 0] A
        .B                    (     oprandB[0]    ),        // input wire [31 : 0] B
        .CE                   (  int_multiply_en  ),        // input wire CE
        
        .ready                (int_multiply_ready ),
        .dout                 (int_multiply_result),        // output wire [63 : 0] P
        .done                 ( int_multiply_done )
    );
    
    //int logic compute unit
    logic int_logic_en;
    logic int_logic_done;
    logic int_logic_ready;
    
    logic [31:0] int_logic_result;
    
    //expansional, perform:
    //                    AND if 1,  OR if 0 bitwise now
    //                    SLT if 2, 
    logic [1:0]logic_ctrl; 
    assign logic_ctrl = (ALUctr==`ALUSLT) ? 2'd2:
                        (ALUctr==`ALUADD) ? 2'd1:
                        (ALUctr==`ALUOR ) ? 2'd0:2'd3;
    int_logic int_logic_compute(
        .clk                  (        clk        ),
        .rst_n                (       rst_n       ),
        .CE                   (    int_logic_en   ),
        .A                    (     oprandA[0]    ),
        .B                    (     oprandB[0]    ),
        .logic_ctrl           (     logic_ctrl    ), //expansional, perform AND if 1, OR if 0 bitwise now
        
        .ready                (  int_logic_ready  ),
        .dout                 (  int_logic_result ),
        .done                 (   int_logic_done  ) 
    );      
    
    ////////////////////////////////////////////////////////////////
    //                                                            //
    //                                                            //
    //                    CONTROL SIGNAL PART                     //
    //                                                            //
    //                                                            //
    ////////////////////////////////////////////////////////////////
    
    //  unit en signal:
    //  [9] => matrix_sigmoid_en
    //  [8] => matrix_tanh_en
    //  [7] => int_logic_en
    //  [6] => matrix_dot_en
    //  [5] => matrix_add_en
    //  [4] => matrix_sum_en
    //  [3] => float_add_en
    //  [2] => float_multiply_en
    //  [1] => int_add_en
    //  [0] => int_multiply_en
    logic [9:0] unit_en;
    assign {matrix_sigmoid_en, matrix_tanh_en, int_logic_en, matrix_dot_en, matrix_add_en, matrix_sum_en, float_add_en, float_multiply_en, int_add_en, int_multiply_en} = unit_en;
    parameter  MSIGEN = 10,//10'b1000000000,
                MTANHEN=  9,//10'b0100000000,
                ILOGEN =  8,//10'b0010000000,
                MDOTEN =  7,//10'b0001000000,
                MADDEN =  6,//10'b0000100000,
                MSUMEN =  5,//10'b0000010000,
                FADDEN =  4,//10'b0000001000,
                FMULEN =  3,//10'b0000000100,
                IADDEN =  2,//10'b0000000010,
                IMULEN =  1,//10'b0000000001,
                NONE   =  0;//10'b0000000000;
    
    
//    //comninational logic
//    assign ALUout[7:2] = (ALUctr==`ALUFDOTM) ? matrix_dot_result[7:2]:matrix_add_result[7:2];
//    assign ALUout[1]   = (ALUctr==`ALUMUL)   ? int_multiply_result_high :     //storing higher 32-bits result of multiply
//                         (ALUctr==`ALUFDOTM) ? matrix_dot_result[1]     :
//                                               matrix_add_result[1];
    always_comb
    begin
        if(!rst_n)
        begin
           unit_en  = {10{NONE}};  //disable all alu unit if reset
           done     = 0;
           for(integer i=0;i<8;i++)
               ALUout[i]   = 32'h0; // set output to 0 if reset
        end
        else //if(en)
        begin
            case(ALUctr)
                `ALUADD,`ALUSUB:
                begin
                    ready       = int_add_ready;
                    unit_en     = en<<(IADDEN-1);
                    done        = int_add_done;
                    ALUout[0]   = int_add_result;
                    for(integer i=1;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 for others
                end
                `ALUMUL:
                begin
                    ready       = int_multiply_ready;
                    unit_en     = en<<(IMULEN-1);
                    done        = int_multiply_done;
                    ALUout[0]   = int_multiply_result_low;  //storing lower 32-bits result of multiply
                    ALUout[1]   = int_multiply_result_high; //storing higher 32-bits result of multiply
                    for(integer i=2;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 for others
                end
                `ALUAND,`ALUOR,`ALUSLT:
                begin
                    ready       = int_logic_ready;
                    unit_en     = en<<(ILOGEN-1);
                    done        = int_logic_done;
                    ALUout[0]   = int_logic_result;
                    for(integer i=1;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 if reset
                end
                /////////////////////`ALUDIV:
                `ALUFADD,`ALUFSUB:
                begin
                    ready       = float_add_ready;
                    unit_en     = en<<(FADDEN-1);
                    done        = float_add_done;
                    ALUout[0]   = float_add_result;
                    for(integer i=1;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 if reset
                end
                `ALUFMUL:
                begin
                    ready       = float_mul_ready;
                    unit_en     = en<<(FMULEN-1);
                    done        = float_multiply_done;
                    ALUout[0]   = float_multiply_result;
                    for(integer i=1;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 if reset
                end
                //////////////////////`ALUFDIV:
                `ALUFADDM:
                begin
                    ready       = matrix_add_ready;
                    unit_en     = en<<(MADDEN-1);
                    done        = matrix_add_done;
                    ALUout      = matrix_add_result;
                end
                `ALUFDOTM:
                begin
                    ready       = matrix_dot_ready;
                    unit_en     = en<<(MDOTEN-1);
                    done        = matrix_dot_done;
                    ALUout      = matrix_dot_result;
                end
                `ALUFSUMM:
                begin
                    ready       = matrix_sum_ready;
                    unit_en     = en<<(MSUMEN-1);
                    done        = matrix_sum_done;
                    ALUout[0]   = matrix_sum_result;
                    for(integer i=1;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 if reset
                end
                `ALUFSIGM:
                begin
                    ready       = matrix_sigmoid_ready;
                    unit_en     = en<<(MSIGEN-1);
                    done        = matrix_sigmoid_done;
                    ALUout      = matrix_sigmoid_result;
                end
                `ALUFTANHM:
                begin
                    ready       = matrix_tanh_ready;
                    unit_en     = en<<(MTANHEN-1);
                    done        = matrix_tanh_done;
                    ALUout      = matrix_tanh_result;
                end
                default:
                begin
                    ready    = 0;
                    unit_en  = {10{NONE}};  //disable all alu unit if reset
                    done     = 0;
                    for(integer i=0;i<8;i++)
                        ALUout[i]   = 32'h0; // set output to 0 if reset
                end
            endcase
                
        end
        
//        else
//        begin
//        unit_en  = NONE;  //disable all alu unit if reset
//        done     = 0;
//        ALUout[0]= 32'h0; // set output to 0 if reset
//        end
            
    end
endmodule
