module Mux41 #(DataWidth = 32) (
    input  [DataWidth - 1 : 0]  a,
    input  [DataWidth - 1 : 0]  b,
    input  [DataWidth - 1 : 0]  c,
    input  [DataWidth - 1 : 0]  d,
    input  [1:0]                sel,

    output [DataWidth - 1 : 0]  dout
);

    // 通过MuxKeyWithDefault实现如下always代码
    // always @(*) begin
    //  case (sel)
    //    2'b00: dout = a[0];
    //    2'b01: dout = a[1];
    //    2'b10: dout = a[2];
    //    2'b11: dout = a[3];
    //    default: dout = 1'b0;
    //  endcase
    // end
    MuxKeyWithDefault #(4, 2, DataWidth) 
    i0 (
        dout, 
        sel, 
        {DataWidth{1'b0}},
        {
            2'b00, a,
            2'b01, b,
            2'b10, c,
            2'b11, d
        }
    );
endmodule

module Mux21 #(DataWidth = 32) (
    input  [DataWidth - 1 : 0]  a,
    input  [DataWidth - 1 : 0]  b,
    input  [0:0]                sel,

    output [DataWidth - 1 : 0]  dout
);
    MuxKeyWithDefault #(2, 1, DataWidth) 
    i0 (
        dout, 
        sel, 
        {DataWidth{1'b0}},
        {
            1'b0, a,
            1'b1, b
        }
    );
endmodule

module Mux81 #(DataWidth = 32) (
    input  [DataWidth - 1 : 0]  a[7:0],
    input  [2:0]                sel,

    output [DataWidth - 1 : 0]  dout
);
    MuxKeyWithDefault #(8, 3, DataWidth) 
    i0 (
        dout, 
        sel, 
        {DataWidth{1'b0}},
        {
            3'b000, a[0],
            3'b001, a[1],
            3'b010, a[2],
            3'b011, a[3],
            3'b100, a[4],
            3'b101, a[5],
            3'b110, a[6],
            3'b111, a[7]
        }
    );
endmodule