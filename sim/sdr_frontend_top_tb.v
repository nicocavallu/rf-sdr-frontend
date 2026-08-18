/* sdr_frontend_top_tb.v
* Testbench to test functionality of sdr frontend project
*/

`timescale 1ns/1ps

module sdr_frontend_top_tb();

    // Inputs
    reg clk, arst_n, sbc_strobe, dds_enable;
    reg [7:0] sdr_signal_in;

    // Stimulus storage
    reg [7:0] sdr_signal [80000];

    // Outputs
    wire valid_out;
    wire signed [17:0] I_OUT, Q_OUT;

    sdr_frontend_top uut(
        .clk(clk),
        .arst_n(arst_n),
        .sbc_strobe(sbc_strobe),
        .dds_enable(dds_enable),
        .sdr_signal_in(sdr_signal_in),
        .valid_out(valid_out),
        .I_OUT(I_OUT),
        .Q_OUT(Q_OUT)
    );

    // Clock period
    always begin
        #20 clk = ~clk;
    end

    initial begin

        $dumpfile("sdr_frontend_top.vcd");
        $dumpvars(0, sdr_frontend_top_tb);

        // Load hex file
        $readmemh("../scripts/sdr_in_80k.hex", sdr_signal);

        // Reset
        clk = 1'b0;
        dds_enable = 1'b0;
        arst_n = 1'b0;
        #100
        arst_n = 1'b1;
        dds_enable = 1'b1;

        // Loop through stimulus array
        for (integer idx = 0; idx < 80000; idx = idx + 1) begin
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

