### ALU����ѡ����  

ALUSrcA:  
00:reg1-�Ĵ���,  
01:pc[31:12], pc��λ,  
10:pc[31:0]
11:0x00000000  

ALUSrB:  
00:reg2-�Ĵ���,  
01:imm-������,  
10:shamt-��λλ��������  
11:0x00000004 (����pc+4 jal[r]ָ��)  

RegWrSrcE:  
00:ALUresult  
01:RAMReadData  
10:compare result
11:pcPlus4

compareSel:
00:equal
01:not equal
10:less than
11:great than

PCSrcSelect:
00:pcPlus4
01:branch inst
10:jump inst

cmpSrcBSel:
0:Reg2
1:imm