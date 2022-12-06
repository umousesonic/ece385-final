module drum_module(	
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
    output logic [1:0] GPIO
);

logic [31:0] write_data;
logic [15:0] delay;
logic [22:0] acc, acc2;
logic [11:0] freq;
logic just_wrote;

logic [1:0] mode;

always_ff @(posedge clk) begin
	if(AVL_CS) begin
		if(AVL_WRITE) begin
			if (AVL_BYTE_EN[0])
				write_data[7:0] <=  AVL_WRITEDATA[7:0];
			if (AVL_BYTE_EN[1])
				write_data[15:8] <=  AVL_WRITEDATA[15:8];
			if (AVL_BYTE_EN[2])
				write_data[23:16] <=  AVL_WRITEDATA[23:16];
			if (AVL_BYTE_EN[3])
				write_data[31:24] <=  AVL_WRITEDATA[31:24];
            just_wrote <= 1'b1;
		end
	end
end


always_ff @(posedge clk) begin
    // Instant mode: write with LSB 1.
    if (just_wrote && write_data[0] == 1) begin
        GPIO[0] <= 1;
        just_wrote <= 0;
        mode <= 1;
    end

    // Loop mode: write with LSB 0.
    if (just_wrote && write_data[0] == 0) begin
        just_wrote <= 0;
        mode <= 0;
    end

    // Each drum strike
    if (GPIO[0] == 1) begin
        acc <= acc + 1;
    end

    if (acc == 40) begin
        GPIO[0] <= 0;
    end

    // Loop counter
   
    
        
end

always_ff @ (posedge clk) begin
    acc <= acc + 1;
    if (acc % 1000 == 0) begin
        if (delay != freq_cache[31:16])
            delay <= delay + 1;
        acc <= 1;
    end
end
endmodule