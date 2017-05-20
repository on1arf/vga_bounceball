`default_nettype none


module vga_bounceball(
        // clock and nreset
			input wire clk,
			input wire nreset,

			output wire vga_hs,
			output wire vga_vs,

			output wire [2:0] red,
			output wire [2:0] green,
			output wire [2:0] blue,

			output wire led1, // debug
			output wire led2, // debug

			output wire [7:0] dac // debug

        );



// local data

// reset circuit
wire reset;
assign reset = ! nreset;



// debug related signals and data
reg l_led1 = 0; reg l_led2 = 0;
assign led1 = l_led1; assign led2 = l_led2;
assign dac[7:0]=xpos_ball[9:2]; // DEBUG


// vga related
wire [9:0] hc; // horizontal counter
wire [9:0] vc; // vertical counter
wire videoactive;
wire offscreen; // active during horizontal lines before and after visible area
						//	 (used to calculation of the new position of objects on screen)


// ball
reg [9:0] xpos_ball; // horizontal counter
reg [9:0] ypos_ball; // vertical counter
wire pixel_ball; // is current pixel part of the ball?
reg ball_dir_hor; // horizontal direction of ball: 0 -> to the right, 1 -> to the left
reg ball_dir_ver; // vertical direction of ball: 0 -> down, 1 -> up


// screenedge
wire pixel_edge; // is the current pixel parr of the screenedge


// state machine
reg [1:0] state;

// 25 Mhz clock
reg clk25out;
reg clk25c; // counter
reg clk25pulse;

// collision with edge - return signals from vga_screenedge module
wire coll_edge_top;
wire coll_edge_right;
wire coll_edge_bottom;
wire coll_edge_left;

// collision memory - keep track if collision has happened or not
reg collmem_top;
reg collmem_right;
reg collmem_bottom;
reg collmem_left;




// instantiations
vga640x480 vga1 (.clk(clk) , .clk25Mhz(clk25out), .reset(reset),
								.vga_hs(vga_hs), .vga_vs(vga_vs), .vga_videoon(videoactive),
								.vga_offscreen(offscreen), .hcounter_out(hc), .vcounter_out(vc));

// ball
//vga_ball  ball1 (.vidactive(videoactive),
//					.xpos_vga(hc), .ypos_vga(vc),
//					.xpos_ball(xpos_ball), .ypos_ball(ypos_ball),
//					.vidout(pixel_ball));

// Moved to top module for debug reasons
wire ball_tmp;
assign ball_tmp = (((hc - xpos_ball) <= 5) &&  ((vc - ypos_ball) <= 5)) ? 1'b1 : 1'b0;
// output is valid if video is active
assign pixel_ball = ball_tmp & videoactive;


// Edge of screen + collision-detection module
vga_screenedge egde  (.vidactive(videoactive),
					.xpos_vga(hc), .ypos_vga(vc),
					.vidout(pixel_edge),
					.collision_top(coll_edge_top), .collision_right(coll_edge_right),
					.collision_bottom(coll_edge_bottom),.collision_left(coll_edge_left));


// Red, green and blue color (3 bit)
// red: present if either ball or edge is being shown (either as red-alone or white)
assign red   = (((pixel_ball || pixel_edge)) && (videoactive == 1)) ? 3'b111: 3'b000;
// green and blue (part of white): present if either ball or either edge
//         (not if both together) are being shown
assign green = (((pixel_ball ^ pixel_edge)) && (videoactive == 1)) ? 3'b111 : 3'b000;
assign blue  = (((pixel_ball ^ pixel_edge)) && (videoactive == 1)) ? 3'b111 : 3'b000;






// clocked logic
// Part 1: create 25 Mhz clock
// Part 2: movement of the ball + process collision detection

always @(posedge clk) 
if (reset == 1) begin
// INITIALISATION

	// part 1: 25 Mhz clock
	clk25c	<= 0;
	clk25out <= 0;
	clk25pulse <= 0;

	// part 2: ball: state machine and collision detection
//	xpos_ball<=320;
//	ypos_ball<=240;
	xpos_ball<=628;
	ypos_ball<=467;

	ball_dir_hor<=0;
	ball_dir_ver<=0;

	collmem_top<=0;
	collmem_right<=0;
	collmem_bottom<=0;
	collmem_left<=0;

	state <= 0;

end else begin
// RUN

	// part 1: 25 Mhz Clock
	if (clk25c == 1) begin
		clk25out <= ! clk25out;
	end
	clk25c <= ! clk25c;

	clk25pulse <= clk25c & clk25out;


	// part 2: ball: state machine and collision detection
	// state machine
	case (state)
		0 : begin
		// state 0: wait for visible part of screen, init vars
l_led1=0; l_led2=0; // debug
				collmem_top<=0;
				collmem_right<=0;
				collmem_bottom<=0;
				collmem_left<=0;

				if (offscreen == 0) begin
					state <= 1;
				end
			end

		1 : begin
		// state 1: visible area, remember collision detection
l_led1=0; l_led2=1; // debug
			//	go to state 2 when bottom of screen is reached (offscreen)
				if (offscreen == 1) begin
					state <= 2;
				end else begin
				// a collision is detected when the ball is present in the collision-area
					if (pixel_ball == 1) begin
						if (coll_edge_top == 1) begin
							collmem_top <= 1'b1;
						end

						if (coll_edge_right == 1) begin
							collmem_right <= 1'b1;
						end

						if (coll_edge_bottom == 1) begin
							collmem_bottom <= 1'b1;
						end

						if (coll_edge_left == 1) begin
							collmem_left <= 1'b1;
						end
					end
				end
			end

		2: begin
		// state 2: part1 of "offscreen" part: change direction if needed
l_led1=1; l_led2=0; // debug
				// change direction if needed
				if ((collmem_top == 1) & (collmem_bottom == 0))begin
					ball_dir_ver <= 1; // collision coming from up, on top of object
											// -> bounce ball back up
				end

				if ((collmem_bottom == 1) & (collmem_top == 0)) begin
					ball_dir_ver <= 0; // collision coming from down -> bounce back down
				end

				if ((collmem_left == 1) & (collmem_right == 0 )) begin
					ball_dir_hor <= 1; // collision on left side of object -> bounce back to the left
				end

				if ((collmem_right == 1) & (collmem_left == 0)) begin
					ball_dir_hor <= 0; // collision on right side of object -> bounce back to the right
				end

				state <= 3;

			end		

		3: begin
		// state 3: part 2 of "offscreen" part: change direction if needed
l_led1=1; l_led2=1; // debug
				// horizontal direction (0=to_right -> increase counter, 1=to_left -> decrease counter)
				if (ball_dir_hor == 0) begin
					if (xpos_ball == 639) begin
						xpos_ball <= 0;
					end else begin
						xpos_ball <= xpos_ball + 1;
					end
				end else begin
					if (xpos_ball == 0) begin
						xpos_ball <= 639;
					end else begin
						xpos_ball <= xpos_ball - 1;
					end
				end

				// vertical direction (0=down -> increase counter, 1=up -> decrease counter)
				if (ball_dir_ver == 0) begin
					if (ypos_ball == 479) begin
						ypos_ball <= 0;
					end else begin
						ypos_ball <= ypos_ball + 1;
					end
				end else begin
					if (ypos_ball == 0) begin
						ypos_ball <= 479;
					end else begin
						ypos_ball <= ypos_ball - 1;
					end
				end


				// move back to state 0
				state <= 0;
			end
		default :
			state <= 0;
	endcase

end // end else (reset)


endmodule

