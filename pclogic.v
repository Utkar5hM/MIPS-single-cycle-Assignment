module pclogic(clk, reset, ain, aout, pcsel);

input reset;
input clk;
input [31:0] ain;
//pecsel = branch & zero
input [1:0]pcsel;

output reg [31:0] aout;

always @(posedge clk ) begin
	if (reset==1)
		aout<=32'b0;
	else
		if ((pcsel==2'b00) || (pcsel==2'b10)) begin
			aout<=aout+1;
		end
		if (pcsel==2'b01) begin
			aout<=ain+aout+1; //branch
	end
		if (pcsel==2'b11) begin
			aout<=ain; //branch
	end
end


endmodule
