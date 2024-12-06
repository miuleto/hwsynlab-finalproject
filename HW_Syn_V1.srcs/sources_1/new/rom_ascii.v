`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:38:03 PM
// Design Name: 
// Module Name: rom_ascii
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


module asciiRom(
	input clk, 
	input wire [11:0] addr,
	output reg [7:0] data
	);

	(* rom_style = "block" *)	// Infer ROM as Block RAM

	reg [11:0] addr_reg;
	reg [7:0] rom [4095:0];
	
	initial $readmemb("ascii.mem", rom);
	
	always @(posedge clk)
		addr_reg <= addr;
	
	always @*
		  data = rom[addr_reg];
endmodule
