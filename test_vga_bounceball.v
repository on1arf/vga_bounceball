`timescale 1ns / 1ps


module vga_bounceball_test;

	// input
	reg clk;
   reg nreset;

	// output
   wire vga_hs;
   wire vga_vs;

   wire [2:0] red;
   wire [2:0] green;
   wire [2:0] blue;

reg xpos_ball;
reg ypos_ball;

	// Instantiate the Unit Under Test (UUT)
	vga_bounceball uut (
		.clk(clk), 
		.nreset(nreset), 
		.vga_hs(vga_hs), 
		.vga_vs(vga_vs), 
		.red(red), 
		.green(green), 
		.blue(blue)
	);

	initial begin
     $dumpfile("vga_bounceball.vcd");
     $dumpvars(0,uut);

//	$monitor("At time %t, cs %0d, clk %0d, mosi %0d, debug1 %0d, debug2 %0d", $time, spi_cs, spi_clk, spi_mosi, debug1, debug2); 
		// Initialize Inputs
		clk = 0;
		nreset = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
     // Add stimulus here
     repeat (10) begin
         #10;
			clk = ~clk;
		end

		nreset = 1;
        
     // Add stimulus here
     repeat (400000) begin
         #10;
			clk = ~clk;
		end

     repeat (40000000) begin
         #10;
			clk = ~clk;
		end

	end

//	dds_tlc5615 d1 (clk,nreset,spi_cs,spi_clk,spi_mosi,debug1,debug2);


endmodule

