/* digital_downconvert_tb.v
* Testbench to test functionality of digital downconverter
*/

`timescale 1ns/1ps

module digital_downconvert_tb();

    // Inputs
    reg clk, arst_n, sbc_strobe, dds_enable;
    reg [7:0] sdr_signal_in;

    // Stimulus storage
    reg [7:0] sdr_signal [40000];

    // Outputs
    wire cic_out;
    wire signed [44:0] CIC_I, CIC_Q;

    digital_downconvert uut(
        .clk(clk),
        .arst_n(arst_n),
        .sbc_strobe(sbc_strobe),
        .dds_enable(dds_enable),
        .sdr_signal_in(sdr_signal_in),
        .cic_out(cic_out),
        .CIC_I(CIC_I),
        .CIC_Q(CIC_Q));

    // Clock period
    always begin
        #20 clk = ~clk;
    end

    initial begin

        $dumpfile("digital_downconvert.vcd");
        $dumpvars(0, digital_downconvert_tb);

        // Load hex file
        $readmemh("../scripts/sdr_in_hex", sdr_signal);

        // Reset
        clk = 1'b0;
        dds_enable = 1'b0;
        arst_n = 1'b0;
        #100
        arst_n = 1'b1;
        dds_enable = 1'b1;

        // Loop through stimulus array
        for (integer idx = 0; idx < 40000; idx = idx + 1) begin
            sdr_signal_in = sdr_signal[idx];
            sbc_strobe = 1'b1;
            #40;
            sbc_strobe = 1'b0;
            #160;
        end

        #1000;
        $display("Simulation complete");
        $finish;
    end
endmodule

