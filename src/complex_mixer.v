/* complex_mixer.v
* This module mixes the SDR LoRa signal with a local oscillator wave
* the mixer will de-chirp the wave so it can be decoded
* */

module complex_mixer(
    input clk, arst_n, mixer_enable,
    input signed [15:0] sdr_signal_out,
    input signed [35:0] signal_out,
    output reg signed [26:0] mixer_I, mixer_Q,
    output reg out_valid);

    reg stage1_valid;
    reg signed [25:0] Icos, Qsin, Qcos, Isin;

    always @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            Icos <= 26'b0;
            Qsin <= 26'b0;
            Qcos <= 26'b0;
            Isin <= 26'b0;
            out_valid <= 1'b0;
            stage1_valid <= 1'b0;
            mixer_I <= 27'b0;
            mixer_Q <= 27'b0;
        end else begin

            // Stage 1
            stage1_valid <= mixer_enable;
            Icos <= $signed(sdr_signal_out[7:0]) *  $signed(signal_out[35:18]);
            Qsin <= $signed(sdr_signal_out[15:8]) *  $signed(signal_out[17:0]);
            Qcos <= $signed(sdr_signal_out[15:8]) *  $signed(signal_out[35:18]);
            Isin <= $signed(sdr_signal_out[7:0]) *  $signed(signal_out[17:0]);

            // Stage 2
            out_valid <= stage1_valid;
            if (stage1_valid) begin
                mixer_I <= Icos + Qsin;
                mixer_Q <= Qcos - Isin;
            end else begin
                mixer_I <= 27'sd0;
                mixer_Q <= 27'sd0;
            end
        end
    end

    endmodule

