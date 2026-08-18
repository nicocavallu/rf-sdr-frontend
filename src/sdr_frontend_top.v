/* sdr_frontend_top.v
* Top module instantatiatig all
* lower level modules in /src
* Contains CDC, digital down conversion
* and final FIR filter and truncation
*/

module sdr_frontend_top(
    input clk, arst_n, sbc_strobe, dds_enable,
    input [7:0] sdr_signal_in,
    output valid_out,
    output signed [17:0] I_OUT, Q_OUT
);

    wire cic_out, fir_out;
    wire signed [3:0] tpdf_dither;
    wire signed [44:0] CIC_I, CIC_Q;
    wire signed [65:0] FIR_I, FIR_Q;

    digital_downconvert ddc(
        .clk(clk),
        .arst_n(arst_n),
        .sbc_strobe(sbc_strobe),
        .dds_enable(dds_enable),
        .sdr_signal_in(sdr_signal_in),
        .cic_out(cic_out),
        .CIC_I(CIC_I),
        .CIC_Q(CIC_Q)
    );

    fir_filter fir(
        .clk(clk),
        .arst_n(arst_n),
        .cic_out(cic_out),
        .CIC_I(CIC_I),
        .CIC_Q(CIC_Q),
        .fir_out(fir_out),
        .FIR_I(FIR_I),
        .FIR_Q(FIR_Q)
    );

    tpdf_dither tdpf(
        .clk(clk),
        .arst_n(arst_n),
        .tpdf_dither(tpdf_dither)
    );

    dither_truncate dither(
        .clk(clk),
        .arst_n(arst_n),
        .fir_out(fir_out),
        .tpdf_dither(tpdf_dither),
        .FIR_I(FIR_I),
        .FIR_Q(FIR_Q),
        .valid_out(valid_out),
        .I_OUT(I_OUT),
        .Q_OUT(Q_OUT)
    );

endmodule
