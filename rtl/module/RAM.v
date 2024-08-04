module RAM #(
    MemSize = 1024
) (
    input                   clk_i,      // 时钟
    input                   rst_i,      // 复位

    input       [31:0]      addr_i,     // 读写地址
    input       [31:0]      data_i,     // 写数据
    input       [3:0]       wen_i,      // 写使能

    output  reg [31:0]      data_o
);

reg     [7:0]   mm[MemSize - 1 : 0];

wire    [31:0]  addr0;
wire    [31:0]  addr1;
wire    [31:0]  addr2;
wire    [31:0]  addr3;

assign  addr0   =   { addr_i[31:2], 2'b00 };
assign  addr1   =   { addr_i[31:2], 2'b01 };
assign  addr2   =   { addr_i[31:2], 2'b10 };
assign  addr3   =   { addr_i[31:2], 2'b11 };

integer n;
always @(posedge clk_i) begin
    if (rst_i) begin    
        for (n = 0; n < MemSize; n = n + 1) begin
            mm[n] <= {8{1'b0}};
        end
    end
    else begin
        { mm[addr3], mm[addr2], mm[addr1], mm[addr0] }  <= 
        {
            wen_i[0]    ?   data_i[7:0]     :   mm[addr3],
            wen_i[1]    ?   data_i[15:8]    :   mm[addr2],
            wen_i[2]    ?   data_i[23:16]   :   mm[addr1],
            wen_i[3]    ?   data_i[31:24]   :   mm[addr0]
        };
    end
end

always @(posedge clk_i) begin
    if (rst_i) 
        data_o  <=  { 32{1'b0} };
    else
        data_o  <=  { mm[addr0],  mm[addr1], mm[addr2],  mm[addr3] };
end
    
endmodule
