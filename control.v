module control(opcode, RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne);

input [5:0] opcode;

output reg RegDst;
output reg ALUSrc;
output reg MemtoReg;
output reg RegWrite;
output reg MemRead;
output reg MemWrite;
output reg Branch;
output reg Ne;
output reg [1:0] AluOP;

always @(opcode) begin
	case (opcode)
		6'b000000:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne}=10'b100100_0_10_x; //r
		6'b100011:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne}=10'b011110_0_00_x; //lw
		6'b101011:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne}=10'bx1x001_0_00_x; //sw
		6'b000100:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne}=10'bx0x000_1_01_0; //beq
		6'b000101:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne}=10'bx0x000_1_01_1; //bne
		6'b001000:{RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, AluOP, Ne}=10'b010100_0_00_x; //addi
		default:
	{RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,AluOP}=9'bxxx_xxx_x_xx;
	endcase
end

endmodule
