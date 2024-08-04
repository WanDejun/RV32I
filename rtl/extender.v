module extender (
    input   [31:0]  inst_i,

    input   [1:0]   imm0E_i,
    input   [1:0]   imm4_1E_i,
    input   [0:0]   imm10_5E_i,
    input   [1:0]   imm11E_i,
    input   [0:0]   imm19_12E_i,
    input   [0:0]   imm30_20E_i,
    
    output  [31:0]  imm_o
);
    
// imm[0]
Mux41 #(1) u_mux41_0(
    .a      ({1'b0}     ),
    .b      (inst_i[7]  ),
    .c      (inst_i[20] ),
    .d      ({1'b0}     ),
    .sel    (imm0E_i    ),      // input  [1:0]                

    .dout   (imm_o[0]   )       // output [DataWidth - 1 : 0]  
);

// imm[4:1]
Mux41 #(4) u_mux41_1(
    .a      (4'b0           ),
    .b      (inst_i[11:8]   ),
    .c      (inst_i[24:21]  ),
    .d      (4'bx           ),
    .sel    (imm4_1E_i      ),  // input  [2:0]                

    .dout   (imm_o[4:1]     )   // output [DataWidth - 1 : 0]  
);

assign  imm_o[10:5] = imm10_5E_i ? inst_i[30:25] : 6'b0;

// imm[11]
Mux41 #(1) u_mux41_2(
    .a      (1'b0),
    .b      (inst_i[7]),
    .c      (inst_i[20]),
    .d      (inst_i[31]),
    .sel    (imm11E_i),       // input  [2:0]                

    .dout   (imm_o[11])     // output [DataWidth - 1 : 0]  
);

assign  imm_o[19:12]    = imm19_12E_i ? {8{inst_i[31]}} : inst_i[19:12];

assign  imm_o[30:20]    = imm30_20E_i ? {11{inst_i[31]}} : inst_i[30:20];

assign  imm_o[31]   =   inst_i[31];

endmodule
