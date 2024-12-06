`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:51:19 PM
// Design Name: 
// Module Name: uartControl
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


module uartControl(
    input clk,
    input RsRx,
    input [7:0] data_in,
    input mode,
    output RsTx,
    output [7:0] data_out,
    output received
    );
    
    reg en, last_rec;
    wire sent, received, baud;
    
    wire [7:0] data;
    assign data = (mode) ? data_in : data_out;
    
    baudrate baudrate(clk, baud);
    uart_rx receiver(baud, RsRx, received, data_out);
    uart_tx transmitter(baud, data, en, sent, RsTx);
    
    //325 clocks change, 1 baud changes
    always @(posedge baud) begin
        if (en) en = 0;
        if ((~last_rec & received) || mode) begin // if received or pass enable
            //data_in = data_out;
            en = 1;
        end
        last_rec = received;
    end
    
endmodule

module uart_tx(
    input clk,
    input [7:0] data_transmit,
    input ena,
    output reg sent,
    output reg bit_out
    );
    
    reg last_ena;
    reg sending = 0;
    reg [7:0] count;
    reg [7:0] temp;
    
    always@(posedge clk) begin
        if (~sending & ~last_ena & ena) begin
            temp <= data_transmit;
            sending <= 1;
            sent <= 0;
            count <= 0;
        end
        
        last_ena <= ena;
        
        if (sending)    count <= count + 1;
        else            begin count <= 0; bit_out <= 1; end
        
        // sampling every 16 ticks
        case (count)
            8'd8: bit_out <= 0;
            8'd24: bit_out <= temp[0];  
            8'd40: bit_out <= temp[1];
            8'd56: bit_out <= temp[2];
            8'd72: bit_out <= temp[3];
            8'd88: bit_out <= temp[4];
            8'd104: bit_out <= temp[5];
            8'd120: bit_out <= temp[6];
            8'd136: bit_out <= temp[7];
            8'd152: begin sent <= 1; sending <= 0; end
        endcase
    end
endmodule

module uart_rx(
    input clk,
    input bit_in,
    output reg received,
    output reg [7:0] data_out
    );
    
    reg last_bit;
    reg receiving = 0;
    reg [7:0] count;
    
    always@(posedge clk) begin
        if (~receiving & last_bit & ~bit_in) begin
            receiving <= 1;
            received <= 0;
            count <= 0;
        end

        last_bit <= bit_in;
        count <= (receiving) ? count+1 : 0;
        
        // sampling every 16 ticks
        case (count)
            8'd24:  data_out[0] <= bit_in;
            8'd40:  data_out[1] <= bit_in;
            8'd56:  data_out[2] <= bit_in;
            8'd72:  data_out[3] <= bit_in;
            8'd88:  data_out[4] <= bit_in;
            8'd104: data_out[5] <= bit_in;
            8'd120: data_out[6] <= bit_in;
            8'd136: data_out[7] <= bit_in;
            8'd152: begin received <= 1; receiving <= 0; end
        endcase
    end
endmodule
