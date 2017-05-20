`default_nettype none

module EdgeUp (clk, reset, in, out);
input clk, reset, in;
output out;
reg last = 1'b1; // init to "1" not to create false positive the first time the module is used

reg l_out;

always @(posedge clk)
if (reset == 1'b1) begin
	last <= 1'b1;
	l_out <= 1'b0;
end else begin
	if ((last == 1'b0) && (in == 1'b1))
		l_out <= 1'b1;
	else
		l_out <= 1'b0;

	last <= in;
end // end if (reset)

// copy latch to output
assign out = l_out;

endmodule
