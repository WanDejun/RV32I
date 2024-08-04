`timescale 1ns/1ns 

module tb_comparer ();

parameter CLK_PERIOD = 20;
parameter DIV_CLK = 25;

reg         sys_clk;        
reg         sys_rst_n;

reg [31:0]  dataA;
reg [31:0]  dataB;
reg         signedFlag;

wire        less;

initial begin
    sys_clk     <= 1'b0;
    sys_rst_n   <= 1'b0;
    #110
    sys_rst_n   <= 1'b1;

    dataA       <= 32'd12345;
    dataB       <= 32'd12344;
    signedFlag  <= 1'b0;
    #20

    dataA       <= 32'd56565;
    dataB       <= 32'd65656;
    signedFlag  <= 1'b0;
    #20

    dataA       <= 32'd11111;
    dataB       <= 32'd11111;
    signedFlag  <= 1'b0;
    #20

    dataA       <= 32'd87654321;
    dataB       <= 32'd87655321;
    signedFlag  <= 1'b0;
    #20

    dataA       <= 32'h80012345;
    dataB       <= 32'h00012345;
    signedFlag  <= 1'b1;
    #20

    dataA       <= 32'hffff1234;
    dataB       <= 32'hffff1233;
    signedFlag  <= 1'b0;
    #20

    dataA       <= 32'hffff1234;
    dataB       <= 32'hffff1233;
    signedFlag  <= 1'b1;
end


always  #(CLK_PERIOD / 2)   sys_clk  =  ~sys_clk;

comparer u_comparer (
    .A_i            (dataA),
    .B_i            (dataB),
    .signedFlag_i   (signedFlag),

    .less_o         (less)
);

endmodule