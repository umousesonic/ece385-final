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
	input  logic [7:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data

    input logic [8:0] sw,
    input logic [1:0] keys,
    output logic [7:0] sound, 
    output logic [7:0] leds,
    output logic [2:0] idx
	
	// Exported Conduit (mapped to GPIOs - make sure you export in Platform Designer)
	// output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	// output logic hs, vs						// VGA HS/VS
);

logic [31:0] write_data;
logic [7:0] bpm;
logic myreset;


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
            if (myreset == 0)
                myreset <= 1;
            else
                myreset <= 0;
		end
	end
end

assign bpm = write_data[7:0];

logic [31:0] divider;
logic irq, local_cnt, beat, silent;
logic [2:0] counter;

logic [7:0] memory [8];

enum logic {up, down} btn_state0, btn_state1;

big_timer mytimer(.clk(clk), .divider(divider), .irq(irq));

// calculate divider
always_comb begin
    // make it twice the freq to toggle
    divider = 750000000 / bpm;

    // sound = ~sw[counter] & local_cnt;
    leds = 8'b0;
    if (~silent) begin
        sound[0] = ~memory[0][counter]& local_cnt;
        sound[1] = ~memory[1][counter]& local_cnt;
        sound[2] = ~memory[2][counter]& local_cnt;
        sound[3] = ~memory[3][counter]& local_cnt;
        sound[4] = ~memory[4][counter]& local_cnt;
        sound[5] = ~memory[5][counter]& local_cnt;
        sound[6] = ~memory[6][counter]& local_cnt;
        sound[7] = ~memory[7][counter]& local_cnt;
        leds[counter] = 1'b1;
    end
    else 
        sound[7:0] = 8'b0;
        
    
end

always_ff @ (posedge clk) begin
    if (myreset) begin
        memory[0] <= 8'b0;
        memory[1] <= 8'b0;
        memory[2] <= 8'b0;
        memory[3] <= 8'b0;
        memory[4] <= 8'b0;
        memory[5] <= 8'b0;
        memory[6] <= 8'b0;
        memory[7] <= 8'b0;
    end

    else 
        memory[idx] <= sw;

    if (myreset) begin
        local_cnt <= 0;
    end
    else begin
        if (irq) begin
            local_cnt <= local_cnt + 1;
            if (local_cnt && ~silent) 
                counter <= counter + 1;     
        end
    end

    if (irq) begin
        if (local_cnt && counter == 3'b111 && silent == 1'b0 && ~sw[8])
            silent <= 1'b1;
        
        if (local_cnt && silent && counter != 3'b111)
            silent <= 1'b0;
    end
end

always_ff @ (posedge clk) begin
    if (~keys[0] && btn_state0 == up) begin
        btn_state0 <= down;
        if (~idx)
            idx <= idx + 1;
    end

    if (keys[0] && btn_state0 == down) begin
        btn_state0 <= up;
    end

    if (~keys[1] && btn_state1 == up) begin
        btn_state1 <= down;
        if (idx)
            idx <= idx - 1;
    end

    if (keys[1] && btn_state1 == down) begin
        btn_state1 <= up;
    end

end




endmodule