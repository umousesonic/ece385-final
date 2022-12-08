// Timer module creates an interrupt at given interval.
// Designed using clock frequency of 50 MHz.

module timer(input logic clk, input logic [22:0] divider, output logic irq);

logic [22:0] acc;

always_ff @ (posedge clk) begin
    if (acc % divider != 0)
        acc <= acc + 1;
    else
        acc <= 23'b1;
end

always_comb begin
    if (acc % divider == 0) begin
        irq = 1'b1;
    end
    else begin
        irq = 1'b0;
    end
end

endmodule

module big_timer(input logic clk, input logic [31:0] divider, output logic irq);

logic [31:0] acc;

always_ff @ (posedge clk) begin
    if (acc % divider != 0)
        acc <= acc + 1;
    else
        acc <= 23'b1;
end

always_comb begin
    if (acc % divider == 0) begin
        irq = 1'b1;
    end
    else begin
        irq = 1'b0;
    end
end

endmodule