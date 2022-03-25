module andm (inA, inB, out, ne);
//1 bit and for (branch & zero)
input inA, inB, ne;
output out;

assign out= (ne==0) ? inA&inB:(inA&(!inB));

endmodule
