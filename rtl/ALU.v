module ALU #(
    DataWidth = 32
) ( 
    input                           clk_i,
    input                           rst_i,

    input       [2:0]               ALUControl_i,
    input       [DataWidth - 1:0]   srcA_i,
    input       [DataWidth - 1:0]   srcB_i,

    output reg  [DataWidth - 1:0]   result_o,
    output wire                     zero_o,
    output wire                     carrayOut_o,
    output wire                     negative_o,
    output wire                     overflow_o
);

wire    cin;
wire    cout;
wire    [DataWidth - 1:0]   AdderResult;

assign  cin =   ALUControl_i == 3'b001 ? 1'b1 : 1'b0;

Adder#(DataWidth)
u_Adder0 (
    .dataA_i            (srcA_i),
    .dataB_i            (ALUControl_i == 3'b001 ? (~srcB_i) : (srcB_i)),
    .cin_i              (cin),

    .result_o           (AdderResult),
    .cout_o             (cout)
);

always @(posedge clk_i) begin
    case (ALUControl_i)
        3'b000: result_o    <=  AdderResult;        // addition
        3'b001: result_o    <=  AdderResult;        // subtraction
        3'b010: result_o    <=  srcA_i & srcB_i;    // and
        3'b011: result_o    <=  srcA_i | srcB_i;    // or
        3'b100: result_o    <=  srcA_i ^ srcB_i;    // xor
        3'b101: result_o    <=  srcA_i << srcB_i;   // shift left
        3'b110: result_o    <=  srcA_i >> srcB_i;   // shift right logic
        3'b111: result_o    <=  ($signed(srcA_i)) >>> srcB_i; // shift right arthimetic
        default:result_o    <=  {DataWidth{1'bx}};  // ub
    endcase 
end

assign  zero_o      =   result_o == {DataWidth{1'b0}};

wire    arithmetic;
assign  arithmetic  =   ALUControl_i == 3'b000 || ALUControl_i == 3'b001;
assign  negative_o  =   result_o[DataWidth - 1];
assign  carrayOut_o =   arithmetic & cout;


// 有符号数算数溢出  
wire    aXorSum;
wire    aXorB;
assign  aXorSum     =   srcA_i[31] ^ AdderResult[31]; // 加数与结果异号
assign  aXorB       =   ~(srcA_i[31] ^ srcB_i[31] ^ ALUControl_i[0]); // 同号加|| 异号减
assign  overflow_o  =   arithmetic & aXorSum & aXorB;

endmodule
