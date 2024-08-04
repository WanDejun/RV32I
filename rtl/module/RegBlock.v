module RegBlock #(
    DataWidth = 32
) (
    input                           clk_i,
    input                           rst_i,

    input       [4:0]               addrA_i,
    output      [DataWidth - 1 : 0] dataA_o,

    input       [4:0]               addrB_i,
    output      [DataWidth - 1 : 0] dataB_o,

    input                           wen_i,
    input       [DataWidth - 1 : 0] data_i,
    input       [4:0]               addrWr
);

reg     [DataWidth - 1 : 0]     regBlock[31 : 0];

integer n;
always @(posedge clk_i) begin
    if (rst_i) 
        for (n = 0; n < 32; n = n + 1) begin
            regBlock[n]     <=  {32{1'b0}};
        end
    else if (wen_i && addrWr!= 5'b00000)
        regBlock[addrWr]    <=  data_i;
    else
        regBlock[addrWr]    <=  regBlock[addrWr];
end

assign dataA_o =  regBlock[addrA_i];
assign dataB_o =  regBlock[addrB_i];

endmodule
