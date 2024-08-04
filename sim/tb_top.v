`timescale 1ns/1ns 

module tb_top ();

parameter CLK_PERIOD = 20;
parameter DIV_CLK = 25;

reg         sys_clk;        
reg         sys_rst_n;

initial begin
    sys_clk     <= 1'b0;
    sys_rst_n   <= 1'b0;
    #110
    sys_rst_n   <= 1'b1;
end

always  #(CLK_PERIOD / 2)   sys_clk  =  ~sys_clk;

top u_riscv_core (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n)
);

endmodule