/* clock_domain_cross_tb.v
* Testbench to test functionality of clock domain crossing
* */

`timescale 1ns/1ps

module clock_domain_cross_tb;

    // Inputs
    reg clk, arst_n, sbc_strobe;
    reg [7:0] sdr_signal_in;

    // Outputs
    wire mixer_enable;
    wire [15:0] sdr_signal_out;

    // UUT
    clock_domain_cross dut (
        .clk(clk),
        .arst_n(arst_n),
        .sdr_signal_in(sdr_signal_in),
        .sbc_strobe(sbc_strobe),
        .mixer_enable(mixer_enable),
        .sdr_signal_out(sdr_signal_out));

    always begin
        #20 clk = ~clk;
    end

    initial begin

        $dumpfile("clock_domain_cross.vcd");
        $dumpvars(0, clock_domain_cross_tb);

        // Initalization

        clk = 1'b0;
        arst_n = 1'b0;
        sbc_strobe = 1'b0;
        sdr_signal_in = 8'h00;

        #100
        arst_n = 1'b1;
        #100

        // Simulate I byte slightly out of sync
        sdr_signal_in = 8'hA5;
        #15;
        sbc_strobe = 1'b1;
        #120;
        sbc_strobe = 1'b0;
        #200;

        // Send Q byte
        sdr_signal_in = 8'h5E;
        #5
        sbc_strobe = 1'b1;
        #160;
        sbc_strobe = 1'b0;
        #500

        // Send Next I Byte
        sdr_signal_in = 8'hBC;
        #10;
        sbc_strobe = 1;
        #120;
        sbc_strobe = 0;
        #200;

        // Next Q Byte
        sdr_signal_in = 8'hD8;
        #10;
        sbc_strobe = 1;
        #120;
        sbc_strobe = 0;

        #400;
        $display("Simulation complete. Open the VCD file to check waveforms.");
        $finish;
    end
endmodule


