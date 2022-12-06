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
	input  logic [15:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data

    output logic sound
	
	// Exported Conduit (mapped to GPIOs - make sure you export in Platform Designer)
	// output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	// output logic hs, vs						// VGA HS/VS
);

logic [31:0] write_data;
logic [22:0] acc, acc2;
logic [15:0] delay;


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
		end
	end
end


assign AVL_READDATA = delay;

always_ff @ (posedge clk) begin
    if (AVL_CS && AVL_WRITE) begin
        acc <= 1;
        delay <= 0;
    end
    else begin
        if (acc % 50000 == 0 && delay != write_data[15:0]) begin
            // Delay increase every 1ms
            delay <= delay + 1;
        end

        if (delay != write_data[15:0]) begin
            // Increment accumalator by 1 when not reached the given delay
            acc <= acc + 1;
        end

        else begin
            // We have delayed given amount
            if (acc2 != 5000000)
                acc2 <= acc2 + 1;
            else begin
                // Reset
                acc <= 1;
                acc2 <= 0;
                delay <= 0;
            end
        end
        
    end
end

always_comb begin
    if (delay == write_data[15:0])
		sound = 1;
    else 
        sound = 0;

end



endmodule