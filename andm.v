module andm (inA, inB, out, ne);
//1 bit and for (branch & zero)
input inA, inB;
input [1:0] ne;
output [1:0]out;

assign out= (ne==0) ? inA&inB:((ne==2'b01) ? (inA&(!inB)):((ne==2'b10) ? ({{1'b1},inA}):0));

endmodule
