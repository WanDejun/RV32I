#-*- coding:utf-8 -*-
insts_test = [
    "32'b000100010001_00000_000_00101_0010011",     # addi r5 r0 0x111      0       r5<=0x111
    "32'b000000001111_00000_000_00110_0010011",     # addi r6 r0 0x00f      4       r6<=0x00f
    "32'b0000000_00101_00110_000_00111_0110011",    # add  r7 r5 r6         8       r7<=0x120
    "32'b0000000_00111_00000_100_00100_0100011",    # sw   r7 r0 4          c       mm[4] <= 0x120
    
    "32'b000000000100_00000_100_00111_0000011",     # lw   r0 4  r7         10      r7<=mm[4] = 0x120
    "32'b0000000_00111_00000_010_00000_0110011",    # slt  r0 r7 r0         14      r0<=1 (r0���ƷǷ�)
    "32'b0000000_00000_00111_001_01000_1100011",    # bne  r7 r0 8          18      pc<=20
    "32'b1111111_00000_00111_001_00101_1100011",    # bne  r7 r0 -28        1c      
    
    "32'b111111111111_00000_000_00111_0010011",     # addi r7 r0 0xfff(-1)  20      r7<=-1     
    "32'b0000000_00000_00111_111_01000_1100011" ,   # bgeu r7 r0 8          24      pc<=2c
    "32'b0000000_00000_00111_111_01000_1100011",    # bgeu r7 r0 8          28
    "32'b00000000100000000000_00100_1101111",       # jal  8  r4            2c      pc<=34 r4<=30
    
    "32'b1111111_00000_00000_000_11101_1100011",    # beq  r7 r0 -4         30      pc<=2a
    "32'b000000000000_00100_000_00000_1100111"      # jalr r4 0 r0          34      pc<=r4=30
    ]

insts_fib = [
    "32'b000000000001_00000_000_00011_0010011",     # addi r3 r0 0x001      00
    "32'b000000000001_00000_000_00100_0010011",     # addi r4 r0 0x001      04
    "32'b000000000010_00000_000_00101_0010011",     # addi r5 r0 0x002      08
    "32'b000000110010_00000_000_00110_0010011",     # addi r6 r0 0x032      0c
    "32'b111111111101_00110_000_00110_0010011",     # addi r6 r6 -3         10
    
    "32'b000000000000_00100_000_00011_0010011",     # addi r3 r4 0          14
    "32'b000000000000_00101_000_00100_0010011",     # addi r4 r5 0          18
    "32'b0000000_00100_00011_000_00101_0110011",    # add  r5 r3 r4         1c
    "32'b111111111111_00110_000_00110_0010011",     # addi r6 r6 -1         20
    
    "32'b1111111_00110_00000_100_10001_1100011",    # blt  r6 r0 -16        24
    "32'b0000000_00101_00000_100_00100_0100011",    # sw   r5 r0 4          28
    "32'b000000000100_00000_100_00111_0000011",     # lw   r0 4  r7         2c
    
    "32'b00000000100000000000_00100_1101111",       # jal  8  r4            30
    "32'b1111111_00000_00000_000_11101_1100011",    # beq  r0 r0 -4         34
    "32'b000000000000_00100_000_00000_1100111"      # jalr r4 0 r0          38
]

insts = insts_fib

with open("insts.data", "w") as file:
    for i in range(len(insts)):
        print("\t{ mm[%2d], mm[%2d], mm[%2d], mm[%2d] } = %s;" 
              % (i * 4 + 3, i * 4 + 2, i * 4 + 1, i * 4, insts[i]), end='\n', file=file)