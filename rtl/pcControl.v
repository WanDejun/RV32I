module pcControl (
    input               clk_i,
    input               rst_i,
    input               ctrlSignal,
    input       [31:0]  data_i,

    output  reg [31:0]  pc_o
);

always @(posedge clk_i) begin
    if (rst_i) 
        pc_o    <=  32'h0;
    else if (ctrlSignal)
        pc_o    <=  data_i;
    else 
        pc_o    <=  pc_o;
end
    
endmodule