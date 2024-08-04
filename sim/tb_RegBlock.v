`timescale 1ns/1ns 

module RegBlock_tb ();

parameter CLK_PERIOD = 20;
parameter DIV_CLK = 25;

reg         sys_clk;        
reg         sys_rst_n;

reg [31:0]      addrA_i;
reg [31:0]      addrB_i;
reg [31:0]      data_i;
reg             wen_i;


wire [31:0]     dataA_o;
wire [31:0]     dataB_o;

initial begin
    sys_clk     <= 1'b0;
    sys_rst_n   <= 1'b0;
    addrA_i     <= 32'b0;
    addrB_i     <= 32'b0;
    data_i      <= 32'b0;
    wen_i       <= 1'b0;
    #100
    sys_rst_n   <= 1'b1;
    #50

    addrA_i     <= 32'h1;
    addrB_i     <= 32'h0;
    data_i      <= 32'h55555555;    
    wen_i       <= 1'b1;

    #40
    addrA_i     <= 32'h2;
    addrB_i     <= 32'h1;
    data_i      <= 32'haaaaaaaa;    
    wen_i       <= 1'b1;

    #40
    addrA_i     <= 32'h3;
    addrB_i     <= 32'h2;
    data_i      <= 32'h0f0f0f0f;
    wen_i       <= 1'b1;

    #40
    addrA_i     <= 32'h4;
    addrB_i     <= 32'h3;
    data_i      <= 32'h0000ffff;
    wen_i       <= 1'b1;

    #40
    addrA_i     <= 32'h1;
    addrB_i     <= 32'h2;
    wen_i       <= 1'b0;

    #40
    addrA_i     <= 32'h3;
    addrB_i     <= 32'h3;
    wen_i       <= 1'b0;
end


always  #(CLK_PERIOD / 2)   sys_clk  =  ~sys_clk;

RegBlock #(32) u_RegBlock (
    .clk_i      (sys_clk    ),
    .rst_i      (~sys_rst_n ),

    .wen_i      (wen_i      ),
    .data_i     (data_i     ),
    .addrA_i    (addrA_i    ),
    .dataA_o    (dataA_o    ),

    .addrB_i    (addrB_i    ),
    .dataB_o    (dataB_o    )
);

endmodule