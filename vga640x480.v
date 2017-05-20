`default_nettype none


module vga640x480(
	// clock and reset
   input wire clk,
	input wire clk25Mhz,
	input wire reset,

	output wire vga_hs,
   output wire vga_vs,
	output wire vga_videoon,

	output wire vga_offscreen,

	output wire [9:0] hcounter_out,
	output wire [9:0] vcounter_out
	);

// local data
reg [9:0] hcounter;
reg [9:0] vcounter;

// EdgeUp and/or EdgeDown
wire edgeUp_clk25M;


// instantiations
EdgeUp EU_Clk25M (.clk(clk), .reset(reset), .in(clk25Mhz), .out(edgeUp_clk25M));


// init if reset, else state machine
always @(posedge clk)
if (reset == 1'b1) begin
	hcounter <= 0;
	vcounter <= 0;
end else begin

	// run on 25 Mhz clock
	if (edgeUp_clk25M == 1'b1) begin
		// increase horizontal counter

		if (hcounter != 799) begin
			hcounter <= hcounter + 1;

		end else begin
			// end of line reached
			hcounter <= 0;

			if (vcounter != 520) begin
				vcounter <= vcounter + 1;
			end else begin
				vcounter <= 0;
			end // new page
			
		end // end of line
		
	end // 25 Mhz clock

end // end else (not reset)
 


// create hs, vs and videoon output
assign vga_hs = (hcounter < 96) ? 1'b0 : 1'b1;
assign vga_vs = (vcounter < 2) ? 1'b0 : 1'b1;
assign vga_videoon = ((hcounter >= 144) && (hcounter < 784) && (vcounter >= 31) && (vcounter < 510))
			? 1'b1 : 1'b0;
assign vga_offscreen = ((vcounter < 31) || (vcounter >= 511)) ? 1'b1 : 1'b0; // offscreen during front porch, vertical sync and end porch


// copy counters to output
assign hcounter_out = (hcounter >= 144)  ? (hcounter - 144) : 10'd0;
assign vcounter_out = (vcounter >= 31) ? (vcounter - 31) : 10'd0;


endmodule
