module keyboard(input logic clk, input logic [7:0] keycode, output logic [12:0] freq);


always_comb begin

case(keycode)
    8'h04 : begin
        //A
    end
    8'h16 : begin
        //S
    end
    8'h07 : begin
        //D
    end
    8'h09 : begin
        //F
    end
    8'h0a : begin
        //G
    end
    default : begin
        nfreq = 0;
    end
endcase


end

always_ff @ (posedge clk) begin
    freq <= nfreq;
end

endmodule