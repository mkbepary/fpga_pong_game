`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2023 01:41:00 PM
// Design Name: 
// Module Name: image_generator
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


module image_generator (
	input clk,
	input reset_im,
	input up_L,
    input down_L,
    input up_R ,
    input down_R ,
    input disp_ena,
    input [31:0] row,
    input [31:0] column,
    input v_sync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
    );
    
    reg [11:0] rgb;
    
    parameter X_MAX = 1280; //1280;
    parameter Y_MAX = 960;//960;   
    parameter PAD_HEIGHT = 300;  // 72 pixels high
    
    // PADDLE
    // paddle horizontal boundaries
    parameter X_PAD_L1 = 50;
    parameter X_PAD_R1 = 70;    // 4 pixels wide
    parameter X_PAD_L2 = X_MAX-70;
    parameter X_PAD_R2 = X_MAX-50;    // 4 pixels wide
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 50;     // change to speed up or slow down paddle movement  
        
    // square rom boundaries
    parameter BALL_SIZE = 16; 
     // positive or negative ball velocity
    parameter BALL_VELOCITY_POS = 10;
    parameter BALL_VELOCITY_NEG = -10;
        
     // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((column == Y_MAX) && (row == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    

    
    // paddle vertical boundary signals
    //parameter y_pad_t = 500;
    //parameter y_pad_b = 100;
    wire [31:0] y_pad_t_l, y_pad_b_l, y_pad_t_r, y_pad_b_r;
	wire pad_on;

    // register to track top boundary and buffer
    reg [31:0] y_pad_reg_l, y_pad_next_l, y_pad_reg_r, y_pad_next_r;

    
    
    // BALL

    // ball horizontal boundary signals
    wire [31:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [31:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [31:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [31:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [31:0] x_delta_reg, x_delta_next;
    reg [31:0] y_delta_reg, y_delta_next;

    // round ball from square image
    wire [3:0] rom_addr, rom_col;   // 4-bit rom address and rom column
    reg [15:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
   

	    // Register Control
	
    always @(posedge clk or negedge reset_im)
        if(reset_im==0) begin
            y_pad_reg_l <= X_PAD_L1;
            y_pad_reg_r <= X_PAD_L1;
            x_ball_reg <= (X_MAX-BALL_SIZE)/2;
            y_ball_reg <= (Y_MAX-BALL_SIZE)/2;
            x_delta_reg <= BALL_VELOCITY_POS;
            y_delta_reg <= BALL_VELOCITY_POS;
        end
        else begin
            y_pad_reg_l <= y_pad_next_l;
            y_pad_reg_r <= y_pad_next_r;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
       
	    // Paddle Control
    always @( *) begin
        //if(refresh_tick)
            if(up_L & (y_pad_t_l > PAD_VELOCITY))
                y_pad_next_l = y_pad_reg_l - PAD_VELOCITY;  // move up - Left
            else if(down_L & (y_pad_b_l <= (Y_MAX - PAD_VELOCITY)))
                y_pad_next_l = y_pad_reg_l + PAD_VELOCITY;  // move down - Left
                
            else if(up_R & (y_pad_t_r > PAD_VELOCITY))
                y_pad_next_r = y_pad_reg_r - PAD_VELOCITY;  // move up - Right
            else if(down_R & (y_pad_b_r <= (Y_MAX - PAD_VELOCITY)))
                y_pad_next_r = y_pad_reg_r + PAD_VELOCITY;  // move down - Right
        else begin
            y_pad_next_l = y_pad_reg_l;     // no move
            y_pad_next_r = y_pad_reg_r;     // no move              
        end
    end
    
           // ball rom
    always @*
        case(rom_addr)
            4'b0000 :    rom_data = 16'b1100000000000000; //     *  
            4'b0001 :    rom_data = 16'b1111000000000000;// 15'b000000111000000; //     **
            4'b0010 :    rom_data = 16'b1111110000000000;//15'b000001111100000; //    ****
            4'b0011 :    rom_data = 16'b1111111100000000;//15'b000011111110000; //    ****
            4'b0100 :    rom_data = 16'b1111111111000000;//15'b000111111111000; //   ******
            4'b0101 :    rom_data = 16'b1111111111110000;//15'b001111111111100; //   ****** 
            4'b0110 :    rom_data = 16'b1111111111111100;//15'b011111111111110; //  ********
            4'b0111 :    rom_data = 16'b1111111111111111; //  ********
            4'b1000 :    rom_data = 16'b1111111111111111; //  ********
            4'b1001 :    rom_data = 16'b1111111111111100;
            4'b1010 :    rom_data = 16'b1111111111110000;
            4'b1011 :    rom_data = 16'b1111111111000000;
            4'b1100 :    rom_data = 16'b1111111100000000;
            4'b1101 :    rom_data = 16'b1111110000000000;
            4'b1110 :    rom_data = 16'b1111000000000000;
            4'b1111 :    rom_data = 16'b1100000000000000;
        endcase    
       
        // OBJECT STATUS SIGNALS
    wire wall_on, pad_on_L, pad_on_R, sq_ball_on, ball_on;
	
	
	    // paddle 
    assign y_pad_t_l = y_pad_reg_l;                             // paddle top position -Left
    assign y_pad_b_l = y_pad_t_l + PAD_HEIGHT - 1;              // paddle bottom position -Left
    assign pad_on_L = (X_PAD_L1 <= row) && (row <= X_PAD_R1) &&     // pixel within paddle boundaries
                    (y_pad_t_l <= column) && (column <= y_pad_b_l);
                        
    assign y_pad_t_r = y_pad_reg_r;                             // paddle top position -Right
    assign y_pad_b_r = y_pad_t_r + PAD_HEIGHT - 1;              // paddle bottom position -Right
    assign pad_on_R = (X_PAD_L2 <= row) && (row <= X_PAD_R2) &&     // pixel within paddle boundaries
                    (y_pad_t_r <= column) && (column <= y_pad_b_r);                    
	
	
	    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= row) && (row <= x_ball_r) &&
                        (y_ball_t <= column) && (column <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = column[3:0] - y_ball_t[3:0];   // 4-bit address
    assign rom_col = row[3:0] - x_ball_l[3:0];    // 4-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
    // new ball position
    assign x_ball_next = (v_sync) ? x_ball_reg : (x_delta_reg + x_ball_reg);
    assign y_ball_next = (v_sync) ? y_ball_reg : (y_delta_reg + y_ball_reg);

        // change ball direction after collision
    always @* begin
        if(y_ball_t < 1)                                            // collide with top
            y_delta_next = BALL_VELOCITY_POS;                       // move down
        else if(y_ball_b > Y_MAX)                                   // collide with bottom
            y_delta_next = BALL_VELOCITY_NEG;                       // move up
        //else if(x_ball_l <= X_WALL_R)                               // collide with wall
        //    x_delta_next = BALL_VELOCITY_POS;                       // move right
        else if((X_PAD_L2 <= x_ball_r) && (x_ball_r <= X_PAD_R2) &&
                (y_pad_t_r <= y_ball_b) && (y_ball_t <= y_pad_b_r))     // collide with paddle
            x_delta_next = BALL_VELOCITY_NEG;                       // move left
        else begin
            x_delta_next = x_delta_reg;
            y_delta_next = x_delta_reg;
        end
    end   

	
	// rgb multiplexing circuit
    always @(*) begin
    /*
        if(disp_ena)
			if(pad_on)
                rgb <= pad_rgb;      // paddle color
            //else if(ball_on)
            //    rgb = ball_rgb;     // ball color
            else
                rgb <= bg_rgb;       // background
    */
    
        if (disp_ena) begin
            if (pad_on_L | pad_on_R)
                rgb = 12'hFFF;     // white paddle
            else if (ball_on)
                rgb = 12'hFF0;      // yellow ball
            else if (row < X_MAX & column < Y_MAX) 
                rgb = 12'h000; //Black box   
            else rgb = 12'h00F;       // Blue background 
            end
            
        else rgb = 12'h000;        // Black            
	end
	
	
	/*
    always @( disp_ena, row, column) begin
    
        if (disp_ena) begin
            if (row > X_PAD_L & row < X_PAD_R & column < y_pad_t & column > y_pad_b) begin
                rgb <= 12'hF00;     // Red
            end
            else if (row < X_MAX & column < Y_MAX) begin
                rgb <= 12'hFF0;       // Yellow   
            end 
            else rgb <= 12'h00F;    // Blue
            end
            
        else rgb <= 12'h000;        // Black
    
    end
    */

	
    assign blue = rgb[3:0];
    assign green = rgb[7:4];
    assign red = rgb[11:8];
     
endmodule
