`include "define.v"
module comparer (
    input   [31:0]  A_i,
    input   [31:0]  B_i,
    input           signedFlag_i,

    output  wire    less_o,
    output  wire    equal_o
);
wire    [31:1]  A;
wire    [31:1]  B;

wire    [31:0]  G1;
wire    [31:0]  L1;
wire    [15:0]  G2;
wire    [15:0]  L2;
wire    [7:0]   G4;
wire    [7:0]   L4;
wire    [3:0]   G8;
wire    [3:0]   L8;
wire    [1:0]   G16;
wire    [1:0]   L16;

wire            L32;
wire            G32;

assign  A  = {{signedFlag_i ? 1'b0 : A_i[31]}, A_i[30:0]};
assign  B  = {{signedFlag_i ? 1'b0 : B_i[31]}, B_i[30:0]};

assign  G1 = ( A) & (~B);
assign  L1 = (~A) & ( B);

genvar  i;

generate 
    for(i = 0; i < 16; i = i + 1) begin: level1
        assign G2[i] = (G1[i * 2] | G1[i * 2 + 1]) & (!L1[i * 2 + 1]);
        assign L2[i] = (L1[i * 2] | L1[i * 2 + 1]) & (!G1[i * 2 + 1]);  
    end
endgenerate

generate 
    for(i = 0; i < 8; i = i + 1) begin: level2
        assign G4[i] = (G2[i * 2] | G2[i * 2 + 1]) & (!L2[i * 2 + 1]);
        assign L4[i] = (L2[i * 2] | L2[i * 2 + 1]) & (!G2[i * 2 + 1]);
    end
endgenerate

generate 
    for(i = 0; i < 4; i = i + 1) begin: level3
        assign G8[i] = (G4[i * 2] | G4[i * 2 + 1]) & (!L4[i * 2 + 1]);
        assign L8[i] = (L4[i * 2] | L4[i * 2 + 1]) & (!G4[i * 2 + 1]);
    end
endgenerate

generate 
    for(i = 0; i < 2; i = i + 1) begin: level4
        assign G16[i] = (G8[i * 2] | G8[i * 2 + 1]) & (!L8[i * 2 + 1]);
        assign L16[i] = (L8[i * 2] | L8[i * 2 + 1]) & (!G8[i * 2 + 1]);
    end
endgenerate

assign L32 = (L16[0] | L16[1]) & (!G16[1]);
assign G32 = (G16[0] | G16[1]) & (!L16[1]);

wire AxorB;
assign  AxorB = A_i[31] ^ B_i[31];
assign  less_o = signedFlag_i ?             // ·ûºÅÊý
                    (AxorB ? A_i[31]            // ÒìºÅ        
                           : A_i[31] ^ L32)    // Í¬ºÅ
                  : (L32);                 // ÎÞ·ûºÅÊý

assign  equal_o =   (!L32) & (!G32);

endmodule