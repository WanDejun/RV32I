`timescale 1ns/1ns 

module tb_RAM ();

parameter CLK_PERIOD = 20;
parameter DIV_CLK = 25;

reg         sys_clk;        
reg         sys_rst_n;

reg [31:0]      addrwire_i;
reg [31:0]      data_i;
reg [3:0]       wen_i;


wire [31:0]     data_o;

initial begin
    sys_clk     <= 1'b0;
    sys_rst_n   <= 1'b0;
    #110
    sys_rst_n   <= 1'b1;

    addrwire_i  <= 32'b0;
    data_i      <= 32'h000f000f;
    wen_i       <= 4'b1011;

    #20
    addrwire_i  <= 32'h4;
    data_i      <= 32'h55555555;    
    wen_i       <= 4'b0011;

    #20
    addrwire_i  <= 32'h8;
    data_i      <= 32'h00004567;
    wen_i       <= 4'b0011;

    #20
    addrwire_i  <= 32'h0a;
    data_i      <= 32'h0f0f0f0f;
    wen_i       <= 4'b1100;

    #20
    addrwire_i  <= 32'h16;
    data_i      <= 32'h0000ffff;
    wen_i       <= 4'b1111;

    #20
    addrwire_i  <= 32'h0;
    wen_i       <= 4'b0000;

    #20
    addrwire_i  <= 32'h4;
    wen_i       <= 4'b0000;

    #20
    addrwire_i  <= 32'h8;
    wen_i       <= 4'b0000;
end


always  #(CLK_PERIOD / 2)   sys_clk  =  ~sys_clk;

RAM #(128) u_RAM (
    .clk_i                       (sys_clk    ),      // 时钟
    .rst_i                       (~sys_rst_n ),      // 复位
    .addrwire_i                  (addrwire_i ),      // 读写地址
    .data_i                      (data_i     ),      // 写数据
    .wen_i                       (wen_i      ),      // 写使能

    .data_o                      (data_o     )
);

endmodule