module sound_interface_triangle(	
    // Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic clk,
	// Avalon Reset Input
	input logic reset,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [1:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to GPIOs - make sure you export in Platform Designer)
	// output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	// output logic hs, vs						// VGA HS/VS
    output logic [4:0] GPIO
);

logic [31:0] freq_cache;
logic [11:0] freq;

always_ff @(posedge clk) begin
	if(AVL_CS) begin
		if(AVL_WRITE) begin
			if (AVL_BYTE_EN[0])
				freq_cache[7:0] <=  AVL_WRITEDATA[7:0];
			if (AVL_BYTE_EN[1])
				freq_cache[15:8] <=  AVL_WRITEDATA[15:8];
			if (AVL_BYTE_EN[2])
				freq_cache[23:16] <=  AVL_WRITEDATA[23:16];
			if (AVL_BYTE_EN[3])
				freq_cache[31:24] <=  AVL_WRITEDATA[31:24];
		end
	end
end

assign AVL_READDATA = freq_cache;

assign freq = freq_cache[11:0];

logic [11:0] higher_freq, lower_freq;

// Frequncy divider
// always_comb begin
// 	if (freq < 400) begin
// 		higher_freq = 0;
// 		lower_freq = freq;
// 	end
// 	else begin
// 		if (freq < 800) begin
// 			higher_freq = freq;
// 			lower_freq = freq;
// 		end
// 		else begin
// 			higher_freq = freq;
// 			lower_freq = 0;
// 		end
// 	end
// end

assign	higher_freq = freq << 1;


square sound_higher (.clk(clk), .freq(higher_freq), .sound(GPIO[0]));
// square sound_lower (.clk(clk), .freq(lower_freq), .sound(GPIO[1]));
triangle trisound (.clk(clk), .freq(freq), .sound(GPIO[4:1]));

endmodule