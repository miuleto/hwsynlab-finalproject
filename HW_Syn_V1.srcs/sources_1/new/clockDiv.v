`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:51:19 PM
// Design Name: 
// Module Name: clockDiv
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

module clockDiv(
    output reg clkDiv,
    input clk
    );
    
    integer counter;
    always @(posedge clk) begin
        counter = counter + 1;
        // 2 to the power of 18
        if (counter == 262143) begin counter = 0; clkDiv = ~clkDiv; end 
    end
endmodule
