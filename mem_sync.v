module mem_sync(clk,a,dout, din, mread, mwrite);
//synchronous memory with 256 32-bit locations
//for data memory
parameter S=32; //size
parameter L=256; //length

input [$clog2(L) - 1:0] a;
input [S-1:0] din;
input clk;
input mwrite;
input mread;
output [(S-1):0] dout;

reg [S-1:0] memory [L-1:0];

assign dout=memory[a];

always @(posedge clk) begin
	if (mwrite==1) begin
		memory[a]<=din;
	end
end


initial $readmemh("D:/Studies/College/4th_Sem/EC340_comparch/MIPS-SCA/repo/MIPS-single-cycle-Assignment/memdata.dat", memory);

endmodule
