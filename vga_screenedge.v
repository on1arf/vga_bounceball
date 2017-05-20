`default_nettype none



// module vga_screen_edge: give a "1" when 5 pixels from the edge of a vga 640x480 screen
module vga_screenedge(
		input wire vidactive,

		input wire[9:0] xpos_vga,
		input wire[9:0] ypos_vga,

		output wire vidout,

// note: top, right, bottom, left indicated the movement of the ball hitting the edge of the screen
// 		so "left" means that the ball comes from the left, hiting the edge of the screen on the right side of the display
		output wire collision_top, 
		output wire collision_right,
		output wire collision_bottom,
		output wire collision_left
);
`include "defines.v"

// local (tempory data)
wire edge_of_screen;
wire coll_top;
wire coll_right;
wire coll_bottom;
wire coll_left;

// tempory data
assign edge_of_screen = ((xpos_vga < EDGE ) || (xpos_vga >= 640-EDGE) || (ypos_vga < EDGE ) || (ypos_vga >= 480-EDGE)) ? 1'b1 : 1'b0;
assign coll_right = (xpos_vga == EDGE) ? 1'b1 : 1'b0; // collision with ball comming from the right (edge-frame on left side of the screen)
assign coll_left = (xpos_vga == 640-EDGE+1) ? 1'b1 : 1'b0; // collision with ball comming from the left (edge-frame on right side of the screen)
assign coll_bottom = (ypos_vga == EDGE) ? 1'b1 : 1'b0; // collision with ball coming from down (to edge-frame on top of the screen)
assign coll_top = (ypos_vga == 480-EDGE+1) ? 1'b1 : 1'b0; // collision with ball coming from higher up (to edge-frame on the bottom of the screen) 

// output is valid if video is active
assign vidout = edge_of_screen & vidactive;
assign collision_top = coll_top & vidactive;
assign collision_right = coll_right & vidactive;
assign collision_bottom = coll_bottom & vidactive;
assign collision_left = coll_left & vidactive;
 
endmodule

