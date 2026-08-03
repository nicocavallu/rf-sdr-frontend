/* complex_mixer_tb.v
* Testbench to test functionality and timing of complex mixer
*/

`timescale 1ns/1ps

module complex_mixer_tb;

    // inputs
    reg clk, arst_n, mixer_enable;
    reg [15:0] sdr_signal_out;
    reg [35:0] signal_out;

    // outputs
    wire signed [26:0] mixer_I, mixer_Q;
    wire out_valid;

    // UUT
    complex_mixer dut (
        .clk(clk),
        .arst_n(arst_n),
        .mixer_enable(mixer_enable),
        .sdr_signal_out(sdr_signal_out),
        .signal_out(signal_out),
        .mixer_I(mixer_I),
        .mixer_Q(mixer_Q),
        .out_valid(out_valid)
    );

    // clock period
    always begin
        #20 clk = ~clk;
    end

    initial begin

        $dumpfile("complex_mixer.vcd");
        $dumpvars(0, complex_mixer_tb);

    clk = 1'b0;
    arst_n = 1'b0;
    mixer_enable   = 1'b0;
    sdr_signal_out = 16'sd0;
    signal_out     = 36'sd0;

    repeat (2) @(negedge clk);
    arst_n = 1'b1;

    @(negedge clk)
    // Feed data
    sdr_signal_out = {8'd0, 8'd10};
    signal_out     = {18'd100, 18'd0};
    mixer_enable   = 1'b1;
    @(negedge clk);
    mixer_enable   = 1'b0;

    repeat (5) @(negedge clk)
    $display("Simulation complete");
    $finish;
end

endmodule
