`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:51:19 PM
// Design Name: 
// Module Name: textScreenGen
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


module textScreenGenerate
    #(
    // tile map
    parameter MAX_X = 48,
    parameter MAX_Y = 20,
    parameter INIT_X = 32,
    parameter INIT_Y = 10,
    parameter BACKGRND = 12'h000,
    parameter TEXT_COLOR = 12'hFA0  
    )
    (
    input clk, 
    input reset,
    input flip,
    input video_on,
    input set,
    input [7:0] sw,
    input [9:0] x, y,
    output reg [11:0] rgb,
    input [7:0] data_displayed,
    input en
    );
    
    // signal declaration
    // ascii ROM
    wire [11:0] rom_addr;
    wire [7:0] col_addr;
    wire [3:0] row_addr;
    wire [2:0] bit_addr;
    wire [7:0] font_word;
    wire ascii_bit;
    // tile RAM
    wire we;                    // write enable
    wire [11:0] addr_r, addr_w;
    wire [7:0] data_out;
   
    // cursor
    reg [6:0] cur_x_reg;
    wire [6:0] cur_x_next;
    reg [4:0] cur_y_reg;
    wire [4:0] cur_y_next;
    wire cursor_on;
    // delayed pixel count
    reg [9:0] pix_x1_reg, pix_y1_reg;
    reg [9:0] pix_x2_reg, pix_y2_reg;
    // object output signals
    wire [11:0] text_rgb, text_rev_rgb;
    wire en, move_xr, enable;
    
    singlePulser rightMoveSignal(.pulse(enable),.clk(clk),.signal(en));
    
    // instantiate the ascii / font rom
    asciiRom rom(.clk(clk), .addr(rom_addr), .data(font_word));
    
    dualPortRam ram(.clk(clk), .we(enable), .addr_a(addr_w), .addr_b(addr_r),
                         .din_a(data_displayed), .dout_b(data_out));
                         
    // registers
    reg [4:0] last_row = INIT_Y; 
    reg [6:0] max_row[63:0];
    always @(posedge clk or posedge reset)
        if(reset) begin
            cur_x_reg <= INIT_X;
            cur_y_reg <= INIT_Y;
            last_row <= INIT_Y;
            pix_x1_reg <= 0;
            pix_x2_reg <= 0;
            pix_y1_reg <= 0;
            pix_y2_reg <= 0;
            max_row[INIT_X] <= INIT_X;
        end    
        else begin
            if(cur_y_reg > last_row) last_row = cur_y_reg;
            cur_x_reg <= cur_x_next;
            cur_y_reg <= cur_y_next;
            pix_x1_reg <= x;
            pix_x2_reg <= pix_x1_reg;
            pix_y1_reg <= y;
            pix_y2_reg <= pix_y1_reg;
            max_row[cur_y_reg] <= cur_x_reg;
        end
        
    wire [6:0] current_max_row;
    wire not_show;
    
    assign current_max_row = max_row[pix_y2_reg[8:4]];
    assign not_show = (current_max_row < pix_x2_reg[9:3]) || (pix_y2_reg[8:4] > last_row);
    
    // tile RAM write
    assign addr_w = {cur_y_reg, cur_x_reg};
    assign we = set;
    
    // tile RAM read
    assign addr_r = {y[8:4], x[9:3]};
    assign col_addr = data_out;
    
    // font ROM
    assign row_addr = y[3:0];
    assign rom_addr = {col_addr, row_addr};
    
    // use delayed coordinate to select a bit
    assign bit_addr = pix_x2_reg[2:0];
    //assign ascii_bit = font_word[~bit_addr];
    assign ascii_bit = (flip) ? font_word[bit_addr] : font_word[~bit_addr];
    
    // new cursor position
    assign cur_x_next = (enable && cur_x_reg == MAX_X - 1) ? INIT_X : (enable && data_displayed == 8'b00001101) ? INIT_X : (enable) ? cur_x_reg + 1 : cur_x_reg;
    assign cur_y_next = (cur_y_reg == MAX_Y - 1) ? INIT_Y : ((enable && cur_x_reg == MAX_X - 1) || (enable && data_displayed == 8'b00001101)) ? cur_y_reg + 1 : cur_y_reg;
   
    // object signals
    assign text_rgb = (ascii_bit) ? TEXT_COLOR : BACKGRND;
    assign text_rev_rgb = (ascii_bit) ? BACKGRND : TEXT_COLOR;
    // use delayed coordinates for comparison
    assign cursor_on = (pix_y2_reg[8:4] == cur_y_reg) && (pix_x2_reg[9:3] == cur_x_reg);
                      
    // rgb multiplexing circuit
    always @*
        if(reset || not_show)
            rgb = BACKGRND;
        else
            if(cursor_on) // show color of cursor w/o characters
                rgb = TEXT_COLOR;
            else // show text with color
                rgb = text_rgb;
endmodule