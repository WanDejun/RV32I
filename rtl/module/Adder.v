module Adder #(
    DataWidth = 32
) (
    input       [31:0]  dataA_i,
    input       [31:0]  dataB_i,
    input       [0:0]   cin_i,

    output  wire[31:0]  result_o,
    output  wire        cout_o
);
    
assign {cout_o, result_o} = {1'b0, dataA_i[31:0]} + {1'b0, dataB_i[31:0]} + {{DataWidth{1'b0}}, cin_i};

endmodule
