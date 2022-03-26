`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2022 06:23:58
// Design Name: Utkarsh M
// Module Name: Jaddress
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Jaddress(
    input [25:0] in,
    input [3:0] pc_in,
    output [31:0] out
    );
    assign out ={pc_in,in,{2'b00}};
endmodule
