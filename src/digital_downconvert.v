/* digital_downconvert.v
* This module is a intermediate submodule that encapsulates the digital
* downconverter of the sdr frontend for a simpler UUT in sim
* This module includes clock domain crossing, complex mixing, and the CIC
* filter
*/

module digital_downconvert(
    input clk, arst_n, sbc_strobe, dds_enable,
    input [7:0] sdr_signal_in,
    output cic_out,
    output signed [44:0] CIC_I, CIC_Q);

    wire mixer_enable, out_valid;
    wire [15:0] sdr_signal_out;
    wire signed [26:0] mixer_I, mixer_Q;
    wire [35:0] signal_out;

    clock_domain_cross cdc (.clk(clk), .arst_n(arst_n), .sbc_strobe(sbc_strobe),
        .sdr_signal_in(sdr_signal_in), .mixer_enable(mixer_enable),
        .sdr_signal_out(sdr_signal_out));
    dds_top dds (.clk(clk), .arst_n(arst_n), .enable(dds_enable), .signal_out(signal_out));
    complex_mixer mix (.clk(clk), .arst_n(arst_n), .mixer_enable(mixer_enable),
        .sdr_signal_out(sdr_signal_out), .signal_out(signal_out),
        .mixer_I(mixer_I), .mixer_Q(mixer_Q), .out_valid(out_valid));
    cic_filt cic (.clk(clk), .arst_n(arst_n), .out_valid(out_valid),
        .mixer_I(mixer_I), .mixer_Q(mixer_Q), .cic_out(cic_out), .CIC_I(CIC_I), .CIC_Q(CIC_Q));

endmodule



