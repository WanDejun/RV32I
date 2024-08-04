module RegDelay #(
    DataWidth = 32,
    DelayCycle = 1
) (
    input   clk_i,
    input   [DataWidth - 1:0] data_i,

    output  [DataWidth - 1:0] data_o
);

reg [DataWidth - 1:0]   Reg[DelayCycle - 1:0];

assign  data_o  =  Reg[DelayCycle - 1];

integer n;
always @(posedge clk_i) begin
    Reg[0]  <=  data_i; 
    for (n = 1; n < DelayCycle; n=n+1) begin: copy
        Reg[n]  <=  Reg[n - 1];
    end 
end
    
endmodule
