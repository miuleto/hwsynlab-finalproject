`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:51:19 PM
// Design Name: 
// Module Name: system
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


module system(
    input clk,              
    input reset, // SW8
    input flip, // SW9          
    input set,              
    input [7:0] sw,        
    input ja1,          
    output ja2,         
    output wire RsTx, 
    input wire RsRx,
    output hsync, vsync,   
    output [11:0] rgb,       
    output [6:0] seg,
    output [3:0] an
    );
    
    // signals
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [7:0] data_in, data_fk;
    wire en1, en2, setSig;
    
    singlePulser setSignal(.signal(set),.clk(clk),.pulse(setSig));
    
    // instantiate vga controller
    vgaController vgaCtrl(.clk(clk), .reset(), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), 
                       .x(w_x), .y(w_y));
    
    // instantiate text generation circuit
    textScreenGenerate textGen(.clk(clk), .flip(flip),.reset(reset), .video_on(w_vid_on), .set(setSig),
                        .sw(sw), .x(w_x), .y(w_y), .rgb(rgb_next), .data_displayed(data_in), .en(en1));
                     
     
    uartControl boardToVgaUART(.clk(clk), .RsRx(ja1), .RsTx(RsTx), .data_in(0), .data_out(data_in), .received(en1), .mode(1'b0));
    uartControl crossBoardUART(.clk(clk), .RsRx(RsRx), .RsTx(ja2), .data_in(sw), .data_out(data_fk), .received(en2), .mode(set));
    
    reg [7:0] display_out;
    
    always@(posedge setSig or posedge en2) begin
        if(setSig) display_out = sw;
        else if(en2) display_out = data_fk; 
    end
    
    wire targetClk;
    wire an0,an1,an2,an3;

    assign an = {an3,an2,an1,an0};
    sevenSeg segmentCtrl(.segments(seg),.an0(an0),.an1(an1),.an2(an2),.an3(an3), .received1(data_in[3:0]), .received2(data_in[7:4]), .sendout1(display_out[3:0]), .sendout2(display_out[7:4]), .clk(clk));
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
          rgb_reg <= rgb_next;
     
            
    // output
    assign rgb = rgb_reg;
    
endmodule