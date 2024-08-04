`timescale 1ns/1ns 

module tb_ALU ();

parameter CLK_PERIOD = 20;
parameter DIV_CLK = 25;

reg         sys_clk;        
reg         sys_rst_n;

reg     [2:0]   ALUControl;
reg     [31:0]  srcA;
reg     [31:0]  srcB;

wire    [31:0]  result;
wire            zero;
wire            carrayOut;
wire            negative;
wire            overflow;

initial begin
    sys_clk     <= 1'b0;
    sys_rst_n   <= 1'b0;
    #110
    sys_rst_n   <= 1'b1;

    #20
    ALUControl  <= 3'b000; // add
    srcA        <= 32'h01234567;
    srcB        <= 32'h11111111;
    
    #20
    ALUControl  <= 3'b001; // sub
    srcA        <= 32'h01234567;
    srcB        <= 32'h11111111;
    
    #20
    ALUControl  <= 3'b010; // and
    srcA        <= 32'h01234567;
    srcB        <= 32'h11111111;
    
    #20
    ALUControl  <= 3'b100; // xor
    srcA        <= 32'h01234567;
    srcB        <= 32'h11111111;

    #20
    ALUControl  <= 3'b011; // or
    srcA        <= 32'h01234567;
    srcB        <= 32'h11111111;

    #20
    ALUControl  <= 3'b100; // sub
    srcA        <= 32'h01234567;
    srcB        <= 32'h01234567;
end


always  #(CLK_PERIOD / 2)   sys_clk  =  ~sys_clk;

ALU #(32) u_ALU ( 
    .clk_i              (sys_clk    ),
    .rst_i              (~sys_rst_n ),

    .ALUControl_i       (ALUControl ),
    .srcA_i             (srcA       ),
    .srcB_i             (srcB       ),

    .result_o           (result     ),
    .zero_o             (zero       ),
    .carrayOut_o        (carrayOut  ),
    .negative_o         (negative   ),
    .overflow_o         (overflow   )
);
endmodule