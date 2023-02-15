`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2023 10:19:36 PM
// Design Name: 
// Module Name: tb_pong_top
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


module tb_pong_top();
 reg clk;
 reg reset_monitor_n;
 //input clear_score,
 reg reset_im;
 reg up_L;
 reg down_L;
 reg up_R ;
 reg down_R ;
 wire   [3:0] red;
 wire  [3:0] green;
 wire  [3:0] blue;
 wire h_sync;
 wire v_sync ;

top pong_top(
  .pixel_clk (clk),
 .reset_monitor_n (reset_monitor_n),
  .reset_im(reset_im),
 .up_L (up_L),
 .down_L (down_L),
 .up_R (up_R),
 .down_R (down_R),
 .red (red),
 .green (green),
 .blue (blue),
 .h_sync (h_sync),
 .v_sync (v_sync) 
    );

always #5 clk = ~clk;

initial begin

	clk = 0;
	reset_monitor_n =0;
	reset_im =0;
	#50 
	reset_monitor_n =1;
	reset_im =1;	
	#50
	#10000000
	$finish;
end

    
endmodule
