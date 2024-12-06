`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:51:19 PM
// Design Name: 
// Module Name: singlePulser
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


module singlePulser(
    output reg pulse,
    input clk,
    input signal
    );
    
    reg [1:0] stage = 0;
    always @(posedge clk) begin
        if (stage == 0) begin
            if(signal) begin
                pulse = 1;
                stage = 1; 
            end
        end
        else if (stage == 1) begin
            if(signal) stage = 2;
            else stage = 0;
            pulse = 0;
        end
        else begin
            if(!signal) stage = 0;
        end
    end
endmodule
