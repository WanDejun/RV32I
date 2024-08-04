module controlUnit (
    input               clk_i,
    input               rst_i,

    output  reg [4:0]   runSignal
);

always @(posedge clk_i) begin
    if (rst_i)
        runSignal   <= 5'b00001;
    else
        runSignal   <=  { runSignal[3:0], runSignal[4] };
end
    
endmodule