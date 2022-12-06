module drummachine (input logic clk, 
                    input logic [8:0] sw,
                    input logic [7:0] bpm, 
                    input logic [1:0] keys,
                    output logic [7:0] sound, 
                    output logic [7:0] leds,
                    output logic [2:0] idx);
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
        memory[idx] <= sw;
        if (irq) begin
            local_cnt <= local_cnt + 1;

            if (local_cnt && ~silent) 
                counter <= counter + 1;
            
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