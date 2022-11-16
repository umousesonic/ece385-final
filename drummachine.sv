module drummachine (input logic clk, input logic [7:0] sw, bpm, output logic sound);
    logic [31:0] divider;
    logic irq, local_cnt, beat;
    logic [2:0] counter;

    big_timer mytimer(.clk(clk), .divider(divider), .irq(irq));

    // calculate divider
    always_comb begin
        // make it twice the freq to toggle
        divider = 325000000 / bpm;

        sound = ~sw[counter] & local_cnt;
    end

    always_ff @ (posedge clk) begin
        // if (on) begin
        //     if (irq) begin
        //         if (sound)
        //             sound <= 1'b0;
        //         else
        //             sound <= 1'b1;
        //     end
        // end
        // else 
        //     sound <= 1'b0;
        if (irq) begin
            local_cnt <= local_cnt + 1;

            if (local_cnt) 
                counter <= counter + 1;
        end
    end

endmodule