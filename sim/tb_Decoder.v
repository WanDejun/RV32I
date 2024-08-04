`timescale 1ns/1ns 

module tb_Docoder ();

parameter CLK_PERIOD = 20;
parameter DIV_CLK = 25;

reg         sys_clk;        
reg         sys_rst_n;

reg     [31:0]  inst;

wire    [2:0]   ALUControl;
wire    [31:0]  imm;
wire    [31:0]  shamt;

wire    [1:0]   srcAE;
wire    [1:0]   srcBE;

wire    [4:0]   rs1;
wire    [4:0]   rs2;
wire    [4:0]   rd;

wire            RdMem;
wire            WrMem;
wire            WrPc;
wire            WrReg;

initial begin
    sys_clk     <=  1'b0;
    sys_rst_n   <=  1'b0;
    #110
    sys_rst_n   <=  1'b1;

    inst        <=  31'b0000000_00001_00010_000_00011_0110011;  // add r3, r1, r2
    #20
    inst        <=  31'b0100000_00011_00010_000_00001_0110011;  // sub r1, r2, r3
    #20
    inst        <=  31'b001001100000_00010_000_00011_0010011;   // addi r2 0x260 r3
    #20
    inst        <=  31'b001001100000_00010_100_00011_0010011;   // xori r2 0x260 r3
    #20
    inst        <=  31'b0000000_00001_00010_010_00011_0110011;  // slt r2 r1 r3
    #20
    inst        <=  31'b000000001111_00011_100_00010_0000011;   // lw
    #20
    inst        <=  31'b001001100000_00011_100_00010_0100011;   // sw
    #20
    inst        <=  31'b1_0101010101_1_10101010_00010_1101111;  // jal r2 0x01010101010101010101
end


always  #(CLK_PERIOD / 2)   sys_clk  =  ~sys_clk;

Docoder u_Decoder (
    .clk_i              (sys_clk    ),
    .rst_i              (~sys_rst_n ),

    .inst_i             (inst       ),

    .ALUControl_o       (ALUControl ),
    .imm_o              (imm        ),
    .shamt_o            (shamt      ),

    .srcAE_o            (srcAE      ),
    .srcBE_o            (srcBE      ),

    .rs1_o              (rs1        ),
    .rs2_o              (rs2        ),
    .rd_o               (rd         ),

    .RdMem_o            (RdMem      ),
    .WrMem_o            (WrMem      ),
    .WrPc_o             (WrPc       ),
    .WrReg_o            (WrReg      )

);

endmodule