module square(input logic [11:0] freq, clk, output logic sound);
logic [22:0] divider;
logic irq, on;

timer mytimer(.clk(clk), .divider(divider), .irq(irq));

// calculate divider
always_comb begin
    // make it twice the freq to toggle
    divider = 25000000 / freq;

    if (freq == 12'b0)
        on = 1'b0;
    else   
        on = 1'b1;
end

always_ff @ (posedge clk) begin
    if (on) begin
        if (irq) begin
            if (sound)
                sound <= 1'b0;
            else
                sound <= 1'b1;
        end
    end
    else 
        sound <= 1'b0;
end

endmodule

module triangle (input logic [11:0] freq, clk, output logic [3:0] sound);
// This module uses 4 output to drive the R-2R DAC
logic [22:0] divider;
logic irq, rev, on;

timer mytimer(.clk(clk), .divider(divider), .irq(irq));

// calculate divider
always_comb begin
    // make it 1/16 the freq to toggle
    divider = 3125000 / freq;
    if (freq == 12'b0)
        on = 1'b0;
    else   
        on = 1'b1;
end

always_ff @ (posedge clk) begin
    if (on) begin
        if (irq) begin
            if (rev)
                sound <= sound - 1;
            else
                sound <= sound + 1;
        end
    end
    else 
        sound <= 1'b0;

    if (sound == 4'b1111) begin
        rev <= 1;
    end

    if (sound == 4'b0) begin
        rev <= 0;
    end
end

endmodule

module drum(input logic beat, input logic on, output logic sound);
    assign sound = beat & on;
endmodule