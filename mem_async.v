module mem_async(a,d);
//asynchronous memory with 256 32-bit locations
//for instruction memory
parameter S=32;
parameter L=256;

input [$clog2(L) - 1:0] a;
output [(S-1):0] d;

reg [S-1:0] memory [L-1:0];
assign d=memory[a];

initial $readmemh("D:/Studies/College/4th_Sem/EC340_comparch/MIPS-SCA/repo/MIPS-single-cycle-Assignment/meminstr.dat", memory);

endmodule
