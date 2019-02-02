`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/26 09:52:51
// Design Name: 
// Module Name: lab7
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

module clock_divider_N(
    input clkin,
    output reg clkout
    );
    parameter N = 100000000;

    integer i;
    always @ (posedge clkin) begin
        i = i + 1;
        if (i == N/2) begin  i = 0; clkout = ~clkout;end
        else clkout = clkout;
    end
endmodule


module select_num (
    input [15:0]number,
    input clock,
    output reg [3:0] AN=4'b0111, //decides which LED to light
    output reg [3:0] num //decides number to show
); 
    always @(posedge clock) begin
        if (AN == 4'b1110) begin 
            AN <= 4'b1101;
            num <= number[3:0];
        end
        else if (AN == 4'b1101) begin 
            AN <= 4'b1011;
            num <= number[7:4];
        end
        else if (AN == 4'b1011) begin 
            AN <= 4'b0111;
            num <= number[11:8];
        end
        else if (AN == 4'b0111) begin 
            AN <= 4'b1110;
            num <= number[15:12];
        end
        else AN <= 4'b1111;        
     end    
endmodule


module SSR_drive(
  input[3:0] number,
  output reg [6:0]display
  );
  
  always @ (number) begin
   if(number==4'b0000) display <= 7'b1000000;
   else if(number==4'b0001) display <= 7'b1111001;
   else if(number==4'b0010) display <= 7'b0100100;
   else if(number==4'b0011) display <= 7'b0110000;
   else if(number==4'b0100) display <= 7'b0011001;
   else if(number==4'b0101) display <= 7'b0010010;
   else if(number==4'b0110) display <= 7'b0000010;
   else if(number==4'b0111) display <= 7'b1111000;
   else if(number==4'b1000) display <= 7'b0000000;
   else if(number==4'b1001) display <= 7'b0010000; 
   else if(number==4'b1010) display <= 7'b0001000;
   else if(number==4'b1011) display <= 7'b0000011;
   else if(number==4'b1100) display <= 7'b1000110;
   else if(number==4'b1101) display <= 7'b0100001;
   else if(number==4'b1110) display <= 7'b0000110;
   else if(number==4'b1111) display <= 7'b0001110;
   else display <= 7'b1111111; 
  end
endmodule

module show(
    input reset,
    input clock,
    input [15:0]number,
    output [6:0]led
    );

    wire [3:0]AN, show_bit;
    wire clk_led;
    wire [15:0] reg_num;

    clock_divider_N #(10000) clock_led(clock, clk_led);
    select_num slct(number, clk_led, AN, show_bit); 
    SSR_drive ssr(show_bit, led);
    
    always @ (posedge clock) begin
        if (reset==1) led_num <=4'b1100;   // display nothing
    end
    
endmodule

