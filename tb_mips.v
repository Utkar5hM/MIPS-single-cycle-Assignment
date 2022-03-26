module tb_mips;
//cpu testbench

reg clk;
reg res;

mips mips_DUT(clk, res);

//wire [31:0] mem [255:0]; 
//wire [31:0] registers [31:0];
//wire [31:0] PC_value;

//assign 
//assign PC_value = mips_DUT.Datapath.PC.aout;

//genvar i;
//genvar j;
//generate
//for(i=0; i<32; i=i+1) begin
//    assign registers[i] = mips_DUT.Datapath.registerfile.memory[i];
//end
//for(j=0; j<256; j=j+1) begin
//    assign mem[j] = mips_DUT.Datapath.memdata.memory[j];
//end
//endgenerate


initial
	forever #5 clk = ~clk;

initial begin
	clk = 0;
	res = 1;
	#10 res = 0;

	#100000 $finish;

end

endmodule
