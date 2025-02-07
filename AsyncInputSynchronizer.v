module AsyncInputSynchronizer (
    input  wire clk,    // system clock
    input  wire asyncn, // asynchronous reset or signal (active-low)
    output wire syncn
);
    reg ff1, ff2;

    always @(posedge clk or negedge asyncn) begin
        if (!asyncn) begin
            ff1 <= 1'b0;
            ff2 <= 1'b0;
        end else begin
            ff1 <= 1'b1;
            ff2 <= ff1;
        end
    end

    assign syncn = ff2;
endmodule