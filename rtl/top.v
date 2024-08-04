`include "define.v"
module top (
    input   wire        sys_clk,
    input   wire        sys_rst_n
);

// conrtroler
wire [4:0]  runSignal;


// pc
wire [31:0] pc;
wire [31:0] pcNxtAddr;
wire [31:0] pcPlus4;


// Decoder
wire    [31:0]  inst;           // 指令输入
wire    [2:0]   ALUControl;     // 运算期
wire    [31:0]  imm;            // 运算期
wire    [31:0]  shamt;          // 运算期
wire            signedFlag;     // 运算期
wire    [1:0]   srcAE;          // 运算期
wire    [1:0]   srcBE;          // 运算期
wire    [1:0]   RegSrcE;        // 写回期(delay2)
wire    [1:0]   PCSrcSel;       // 写回期(delay2)
wire    [1:0]   cmpSel;         // 运算期
wire    [0:0]   cmpSrcBSel;     // 运算期
wire    [4:0]   rs1;            // 译码期
wire    [4:0]   rs2;            // 译码期
wire    [4:0]   rd;             // 写回期(delay2)
wire            WrMem;          // 访存期(delay1)
wire            WrReg;          // 写回期(delay2)


wire            RdMem_d1;
wire            WrMem_d1;

wire    [1:0]   RegSrcE_d2;
wire    [1:0]   PCSrcSel_d2;
wire    [4:0]   rd_d2;
wire            WrReg_d2;


// RegRd
wire    [31:0]  regData1;
wire    [31:0]  regData2;       // 运算和访存期(写入内存, delay1)

wire    [31:0]  RAMWriteData;   // 由regData2打一拍获得


// ALU
wire    [31:0]  ALUsrcA;        // 操作数A
wire    [31:0]  ALUsrcB;        // 操作数B
wire    [31:0]  ALUresult;      // 访存写回期(delay0, delay1)
wire            ALUzero;
wire            ALUcarrayOut;
wire            ALUnegative;
wire            ALUoverflow;

wire    [31:0]  ALUresult_d1;      // ALU结果, 打一拍

// Comparer
wire            less;           // 小于标志位
wire            equal;          // 等于标志位

wire            cmpResult_w;    // 组合逻辑电路产生的比较结果
reg             cmpResult;      // 对cmpResult打一拍 写回期(写寄存器,写pc, delay1)
wire    [31:0]  cmpSrcA;
wire    [31:0]  cmpSrcB;

wire            cmpResult_d1;   // cmpResul打一拍


// RAM
wire    [31:0]  RAMReadData;    // 写回期


// RegWr
wire    [31:0]  RegWrData;      


// 跳转分支地址
wire    [31:0]  branchAddr;
wire    [31:0]  jumpAddr;


Adder #(32) u_Adder (
    .dataA_i     (pc        ),
    .dataB_i     (32'd4     ),
    .cin_i       (1'b0      ),

    .result_o    (pcPlus4   ),
    .cout_o      (          )
);

controlUnit u_controlUnit(
    .clk_i      (sys_clk    ), 
    .rst_i      (~sys_rst_n ), 

    .runSignal  (runSignal  )
);



/*******************************
 **          PC寄存器          **
********************************/
pcControl u_pcControl(
    .clk_i      (sys_clk                ),     // input               
    .rst_i      (~sys_rst_n             ),     // input        
    .ctrlSignal (runSignal[4]           ),
    .data_i     (pcNxtAddr              ),     // input       [31:0]  

    .pc_o       (pc                     )      // output  reg [31:0]  
);



/*******************************
 **           ROM             **
********************************/
ROM #(1024) u_ROM (
    .clk_i          (sys_clk        ),
    .ctrlSignal_i   (runSignal[0]   ),
    .addrwire_i     (pc             ),  // input [31:0] 读写地址
    .data_o         (inst           )   // output  reg [31 : 0]
);



/*******************************
 **         Decoder           **
********************************/
// 译码器
Docoder u_Decoder (
    .clk_i              (sys_clk    ),
    .rst_i              (~sys_rst_n ),

    .inst_i             (inst       ),

    .ALUControl_o       (ALUControl ),
    .imm_o              (imm        ),
    .shamt_o            (shamt      ),

    .signedFlag_o       (signedFlag ),

    .srcAE_o            (srcAE      ),
    .srcBE_o            (srcBE      ),
    .RegSrcE_o          (RegSrcE    ),
    .PCSrcSel_o         (PCSrcSel   ),
    .cmpSel_o           (cmpSel     ),

    .cmpSrcBSel_o       (cmpSrcBSel ),

    .rs1_o              (rs1        ),
    .rs2_o              (rs2        ),
    .rd_o               (rd         ),

    .WrMem_o            (WrMem      ),
    .WrReg_o            (WrReg      )
);

// Decoder_RegDelay2Cycle
RegDelay #(10, 2) u_Decoder_RegDelay2Cycle (
    .clk_i      (sys_clk                        ),
    .data_i     ({RegSrcE, PCSrcSel, rd, WrReg} ),

    .data_o     ({RegSrcE_d2, PCSrcSel_d2, 
                  rd_d2     , WrReg_d2}         )
);

// Decoder_RegDelay1Cycle
RegDelay #(1, 1) u_Decoder_RegDelay1Cycle (
    .clk_i      (sys_clk                ),
    .data_i     ({WrMem}         ),

    .data_o     ({WrMem_d1}   )
);



/*******************************
 **         寄存器读           **
********************************/
RegBlock #(32) u_RegBlock (
    .clk_i      (sys_clk                ),
    .rst_i      (~sys_rst_n             ),

    .addrA_i    (rs1                    ),
    .dataA_o    (regData1               ),

    .addrB_i    (rs2                    ),
    .dataB_o    (regData2               ),

    .wen_i      (WrReg_d2 & runSignal[4]),
    .data_i     (RegWrData              ),
    .addrWr     (rd_d2                  )
);

// Decoder_RegDelay1Cycle
RegDelay #(32, 1) u_RegBlock_RegDelay1Cycle (
    .clk_i      (sys_clk        ),
    .data_i     ({regData2}     ),

    .data_o     ({RAMWriteData} )
);


/*******************************
 **          ALU              **
********************************/
// ALUsrcAE ALU输入数据A选择器
Mux41 #(32) u_mux41_ALUsrcAE(
    .a      (regData1           ),
    .b      ({pc[31:12],{12'h0}}),
    .c      (pc                 ),
    .d      ({32'h0}            ),
    .sel    (srcAE              ),  // input  [1:0]                

    .dout   (ALUsrcA            )   // output [DataWidth - 1 : 0]  
);

// ALUsrcBE ALU输入数据B选择器
Mux41 #(32) u_mux41_ALUsrcBE(
    .a      (regData2           ),
    .b      (imm                ),
    .c      (shamt              ),
    .d      ({32'h0}            ),
    .sel    (srcBE              ),  // input  [1:0]                

    .dout   (ALUsrcB            )   // output [DataWidth - 1 : 0]  
);

// ALU
ALU #(32) u_ALU ( 
    .clk_i          (sys_clk & runSignal[2] ),
    .rst_i          (~sys_rst_n             ),

    .ALUControl_i   (ALUControl             ),
    .srcA_i         (ALUsrcA                ),
    .srcB_i         (ALUsrcB                ),

    .result_o       (ALUresult              ),
    .zero_o         (ALUzero                ),
    .carrayOut_o    (ALUcarrayOut           ),
    .negative_o     (ALUnegative            ),
    .overflow_o     (ALUoverflow            )
);


// ALU 数据延迟1周期
RegDelay #(33, 1) u_ALU_RegDelay1Cycle (
    .clk_i      (sys_clk                    ),
    .data_i     ({ALUresult, cmpResult}     ),

    .data_o     ({ALUresult_d1,cmpResult_d1})
);



/*******************************
 **         Comparer          **
********************************/
// 比较器输入1
assign  cmpSrcA =   regData1; 

// 比较器输入2
Mux21 #(32) u_mux41_cmpSrcB (
    .a      (regData2   ),
    .b      (imm        ),

    .sel    (cmpSrcBSel ),
    .dout   (cmpSrcB    )
);

// compare
comparer u_comparer (
    .A_i            (cmpSrcA    ),
    .B_i            (cmpSrcB    ),
    .signedFlag_i   (signedFlag ),

    .less_o         (less       ),
    .equal_o        (equal      )
);

// mux41_cmpResult
Mux41 #(1) u_mux41_cmp(
    .a      (equal      ),
    .b      (!equal     ),
    .c      (less       ),
    .d      (!less      ),
    .sel    (cmpSel     ),  // input  [1:0]

    .dout   (cmpResult_w)   // output [0:0]
);

// 对cmpResult打一拍
always @(posedge sys_clk) begin
    cmpResult   <=  cmpResult_w;
end



/*******************************
 **          RAM              **
********************************/
RAM #(128) u_RAM (
    .clk_i      (sys_clk                        ),  // 时钟
    .rst_i      (~sys_rst_n                     ),  // 复位
    .addr_i     (ALUresult                      ),  // 读写地址
    .data_i     (RAMWriteData                   ),  // 写数据
    .wen_i      ({4{WrMem_d1 & runSignal[3]}}   ),  // 写使能

    .data_o     (RAMReadData                    )
);


/*******************************
 **          Reg写            **
********************************/
// RegSrcE
Mux41 #(32) u_mux41_RegSrcE(
    .a      (ALUresult_d1                   ),
    .b      (RAMReadData                    ),
    .c      ({{31'h00000000}, cmpResult_d1} ),
    .d      (pcPlus4                        ),
    .sel    (RegSrcE_d2                     ),  // input  [1:0]

    .dout   (RegWrData                      )   // output [DataWidth - 1 : 0]  
);



/*******************************
 **          PC控制            **
********************************/
// 调准 分支地址
assign  branchAddr  =   cmpResult_d1 ? ALUresult_d1 : pcPlus4;
assign  jumpAddr    =   ALUresult_d1;

// PCSrcSelect
Mux41 #(32) u_mux41_PCSrcE(
    .a      (pcPlus4        ),
    .b      (branchAddr     ),
    .c      (jumpAddr       ),  // input  [1:0]       
    .d      ({32'hxxxxxxxx} ),         

    .sel    (PCSrcSel_d2    ),
    .dout   (pcNxtAddr      )   // output [DataWidth - 1 : 0]  
);


endmodule