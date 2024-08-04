module Docoder (
    input                   clk_i,
    input                   rst_i,

    input           [31:0]  inst_i,

    output  reg     [2:0]   ALUControl_o,
    output  reg     [31:0]  imm_o,
    output  reg     [31:0]  shamt_o,

    output  reg     [0:0]   signedFlag_o,
    
    output  reg     [1:0]   srcAE_o,
    output  reg     [1:0]   srcBE_o,
    output  reg     [1:0]   RegSrcE_o,
    output  reg     [1:0]   PCSrcSel_o,
    output  reg     [1:0]   cmpSel_o,

    output  reg     [0:0]   cmpSrcBSel_o,

    output  reg     [4:0]   rs1_o,
    output  reg     [4:0]   rs2_o,

    output  reg     [4:0]   rd_o,

    output  reg             WrMem_o,
    output  reg             WrReg_o
);


reg     [1:0]   imm0E;
reg     [1:0]   imm4_1E;
reg     [0:0]   imm10_5E;
reg     [1:0]   imm11E;
reg     [0:0]   imm19_12E;
reg     [0:0]   imm30_20E;


wire    [4:0]   rd;
wire    [6:0]   opcode;
assign  opcode  =   inst_i[6:0];
assign  rd      =   inst_i[11:7];

wire    [2:0]   func3;
wire    [6:0]   func7;
assign  {func3, func7}  =   { inst_i[14:12], inst_i[31:25] };

reg     [31:0]  inst;
always @(posedge clk_i) begin
    inst    <=  inst_i;
    rs1_o   <=  inst_i[19:15];
    rs2_o   <=  inst_i[24:20];
end

// 立即数扩展
extender u_extender(
    .inst_i         (inst       ),      //    input   [31:0]

    .imm0E_i        (imm0E      ),      //    input   [1:0]
    .imm4_1E_i      (imm4_1E    ),      //    input   [1:0]
    .imm10_5E_i     (imm10_5E   ),      //    input   [0:0]
    .imm11E_i       (imm11E     ),      //    input   [1:0]
    .imm19_12E_i    (imm19_12E  ),      //    input   [0:0]
    .imm30_20E_i    (imm30_20E  ),      //    input   [0:0]
    
    .imm_o          (imm_o      )        //    output  [31:0]
);

// shamt_o & rd 寄存器打拍
always @(posedge clk_i) begin
    shamt_o <=  {{27{inst_i[24]}}, inst_i[24:20]};
    rd_o    <=  rd;
end


// imm
always @(posedge clk_i) begin
    case (opcode)
        7'b1100111, // I jalr
        7'b0000011, // I lb
        7'b0010011: begin // I addi/slti/sltiu/xori/ori/andi/slli/srli/srai
            imm0E       <=  2'h2;
            imm4_1E     <=  2'h2;
            imm10_5E    <=  1'h1;
            imm11E      <=  2'h3;
            imm19_12E   <=  1'h1;
            imm30_20E   <=  1'h1;
        end
        7'b0100011: begin // S sb/sw/sh
            imm0E       <=  2'h1;
            imm4_1E     <=  2'h1;
            imm10_5E    <=  1'h1;
            imm11E      <=  2'h3;
            imm19_12E   <=  1'h1;
            imm30_20E   <=  1'h1;
        end
        7'b1100011: begin // B beq/bne/blt/bge/blut/bgeu
            imm0E       <=  2'h0;
            imm4_1E     <=  2'h1;
            imm10_5E    <=  1'h1;
            imm11E      <=  2'h1;
            imm19_12E   <=  1'h1;
            imm30_20E   <=  1'h1;
        end
        7'b0010111, // U lui auipc
        7'b0110111: begin // U lui
            imm0E       <=  2'h0;
            imm4_1E     <=  2'h0;
            imm10_5E    <=  1'h0;
            imm11E      <=  2'h0;
            imm19_12E   <=  1'h0;
            imm30_20E   <=  1'h0;
        end
        7'b1101111: begin // J jal
            imm0E       <=  2'h0;
            imm4_1E     <=  2'h2;
            imm10_5E    <=  1'h1;
            imm11E      <=  2'h2;
            imm19_12E   <=  1'h0;
            imm30_20E   <=  1'h1;
        end
        default:
        begin
            imm0E       <=  2'h0;
            imm4_1E     <=  2'h0;
            imm10_5E    <=  1'h0;
            imm11E      <=  2'h0;
            imm19_12E   <=  1'h0;
            imm30_20E   <=  1'h0;
        end
    endcase
end


// alu控制信号
always @(posedge clk_i) begin
    case (opcode)
        7'b0110111: // lui
        begin
            ALUControl_o    <=  3'b000;
            srcAE_o         <=  2'b11;      // 0x00000000
            srcBE_o         <=  2'b01;      // imm
            cmpSrcBSel_o    <=  1'b0;
        end

        7'b0010111: // pc[31:12]
        begin
            ALUControl_o    <=  3'b000;
            srcAE_o         <=  2'b01;      // pc[31:12]
            srcBE_o         <=  2'b01;      // imm
            cmpSrcBSel_o    <=  1'b0;
        end

        7'b1101111,         // jal
        7'b1100011: begin   // B beq, bne, blt, bge, bltu, bgeu
            ALUControl_o    <=  3'b000;
            srcAE_o         <=  2'b10;      // pc
            srcBE_o         <=  2'b01;      // imm
            cmpSrcBSel_o    <=  1'b0;
        end

        7'b1100111, // J jalr
        7'b0000011, // I lb, lh, lw, lbu, lhu
        7'b0100011: // S sb, sh, sw
        begin
            ALUControl_o    <=  3'b000;
            srcAE_o         <=  2'b00;      // regA
            srcBE_o         <=  2'b01;      // imm
            cmpSrcBSel_o    <=  1'b0;
        end

        7'b0010011, // I add/sub...
        7'b0110011: // R add/sub...
        begin
            srcAE_o         <=  2'b00;      // regA
            if (opcode[5]) begin    // R
                srcBE_o     <=  2'b00;
                cmpSrcBSel_o<=  1'b0;
            end
            else begin              // I
                srcBE_o     <=  2'b01;      // imm
                cmpSrcBSel_o<=  1'b1;
            end

            case(func3)
                3'b000: begin       // sub & add
                    if (opcode[5])      // R
                        ALUControl_o    <=  {{2{1'b0}}, func7[5]}; 
                    else                // J(只有加)
                        ALUControl_o    <=  3'b000;
                end

                3'b001:             // shift left
                    ALUControl_o    <=  3'b101;

                3'b010,             // slt
                3'b011:             // sltu  
                    ALUControl_o    <=  3'b001; // 做减法

                3'b100:             // xor
                    ALUControl_o    <=  3'b100;

                3'b101: begin       // shift right
                    if (func7[5])   // sra
                        ALUControl_o    <=  3'b111; 
                    else            // srl
                        ALUControl_o    <=  3'b110;
                end

                3'b110:             // or
                    ALUControl_o    <=  3'b011;
                
                3'b111:             // and
                    ALUControl_o    <=  3'b010;

                default:
                    ALUControl_o    <=  3'bxxx;
            endcase
        end

        default:
        begin
            ALUControl_o    <=  3'bxxx;
            srcAE_o         <=  2'bxx;
            srcBE_o         <=  2'bxx;
            cmpSrcBSel_o    <=  1'b0;
        end
    endcase
end


// RdMem_o     
// WrMem_o     
// WrReg_o     
// RegSrcE_o   
// PCSrcSel_o  
// cmpSel_o    
// signedFlag_o
always @(posedge clk_i) begin
    case (opcode)
        7'b1100111,         // I jalr
        7'b1101111: begin   // J jal
            WrMem_o         <=  1'b0;
            WrReg_o         <=  1'b1;
            RegSrcE_o       <=  2'b11;  // pcPlus4
            PCSrcSel_o      <=  2'b10;
            cmpSel_o        <=  2'b0;
            signedFlag_o    <=  1'b0;
        end

        7'b1100011: begin   // B
            WrMem_o         <=  1'b0;
            WrReg_o         <=  1'b0;
            RegSrcE_o       <=  2'b00;
            PCSrcSel_o      <=  2'b01;
            case (func3)
                3'b000: cmpSel_o    <=  2'b00; // beq
                3'b001: cmpSel_o    <=  2'b01; // bne
                3'b100: cmpSel_o    <=  2'b10; // blt
                3'b101: cmpSel_o    <=  2'b11; // bge
                3'b110: cmpSel_o    <=  2'b10; // bltu
                3'b111: cmpSel_o    <=  2'b11; // bgeu
            endcase
            if (func3[2])               // 无符号比较
                signedFlag_o    <=  1'b0; 
            else                        // 有符号比较
                signedFlag_o    <=  1'b1;
        end


        7'b0000011: begin // I ld/lw/lh
            WrMem_o         <=  1'b0;
            WrReg_o         <=  1'b1;
            RegSrcE_o       <=  2'b01;
            PCSrcSel_o      <=  2'b00;
            cmpSel_o        <=  2'b0;
            signedFlag_o    <=  1'b0;
        end
        7'b0100011: begin // S sb, sw, sh
            WrMem_o         <=  1'b1;
            WrReg_o         <=  1'b0;
            RegSrcE_o       <=  2'b00;
            PCSrcSel_o      <=  2'b00;
            cmpSel_o        <=  2'b0;
            signedFlag_o    <=  1'b0;
        end

        7'b0010011,         // I 运算
        7'b0110011: begin   // R 运算
            WrMem_o         <=  1'b0;
            WrReg_o         <=  1'b1;
            PCSrcSel_o      <=  2'b00;
            if (func3 == 3'b011 || func3 == 3'b010) begin// slt & stlu
                RegSrcE_o       <=  2'b10; // 寄存器输入源为比较器
                cmpSel_o        <=  2'b10; // 比较器选择小于
            end
            else begin
                RegSrcE_o       <=  2'b00; // 寄存器输入源为alu
                cmpSel_o        <=  2'b00;
            end

            if (func3 == 3'b011)
                signedFlag_o    <=  1'b1;
            else
                signedFlag_o    <=  1'b0;
        end

        7'b0010111,         // U lui
        7'b0110111: begin   // U auipc
            WrMem_o         <=  1'b0;
            WrReg_o         <=  1'b1;
            PCSrcSel_o      <=  2'b00;
            if (func3 == 3'b001 || func3 == 3'b010)
                RegSrcE_o       <=  2'b10;
            else
                RegSrcE_o       <=  2'b00;
            cmpSel_o        <=  2'b0;
        end

        default: begin
            WrMem_o         <=  1'b0;
            WrReg_o         <=  1'b0;
            RegSrcE_o       <=  2'b00;
            PCSrcSel_o      <=  2'b00;
            cmpSel_o        <=  2'b0;
            signedFlag_o    <=  1'b0;
        end
    endcase
end


endmodule