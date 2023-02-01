`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2023 12:12:17 PM
// Design Name:
// Module Name: top
// Project Name: Pong game on FPGA
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


module top(

 input pixel_clk,
 input reset_n,
 input reset_im,
 input up_L,
 input down_L,
 input up_R ,
 input down_R ,
 output   [3:0] red,
 output  [3:0] green,
 output  [3:0] blue,
 output h_sync,
 output v_sync 
    );
    
    wire disp_ena;
    wire [31:0] row, column; 
    wire n_blank, n_sync;
    wire w_up_L, w_down_L, w_up_R, w_down_R;
    wire w_v_sync;
    
    assign v_sync = w_v_sync;
    
    
    vga_controller vga_cont0
 (
    .pixel_clk (pixel_clk),
    .reset_n (reset_n),
    .h_sync (h_sync),
    .v_sync  (w_v_sync),
    .disp_ena (disp_ena),
    .column  (column) , 
    .row    (row),   
    .n_blank (n_blank),  
    .n_sync (n_sync)
    );  
    
 image_generator im_gen0(
	.clk (pixel_clk),
	.reset_im (reset_im),
	.up_L (w_up_L),
	.down_L (w_down_L),
	.up_R (w_up_R),
	.down_R (w_down_R),	
    .disp_ena (disp_ena),
    .row    (column)  ,
    .column   (row),
    .v_sync (w_v_sync),
    .red   (red),   
    .green (green),  
    .blue (blue)
    );    
    
    push_button_delay pb_up_L(.clk(pixel_clk), .btn_in(up_L), .btn_out(w_up_L));
    push_button_delay pb_down_L(.clk(pixel_clk), .btn_in(down_L), .btn_out(w_down_L));
    push_button_delay pb_up_R(.clk(pixel_clk), .btn_in(up_R), .btn_out(w_up_R));
    push_button_delay pb_down_R(.clk(pixel_clk), .btn_in(down_R), .btn_out(w_down_R));    
    


endmodule
