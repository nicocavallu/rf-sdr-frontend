/* cic_filt.v
* This module implements a cascaded-integrator comb (CIC) filter
* This filter combines a low pass FIR filter and comb filter to decimate the
* signal by a factor of R = 64
* This will save lots of energy and hardware later by decimating form 20MSPS
* to 312.5 kSPS
*/

module cic_filt(
    input clk, arst_n, out_valid,
    input signed [26:0] mixer_I, mixer_Q,
    output reg cic_out,
    output signed [44:0] CIC_I, CIC_Q);

    reg signed [44:0] I_int   [3];
    reg signed [44:0] Q_int   [3];
    reg signed [44:0] I_delay [3];
    reg signed [44:0] Q_delay [3];
    reg signed [44:0] I_comb  [3];
    reg signed [44:0] Q_comb  [3];
    reg [5:0] strobe_count;

    always @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            for (integer i = 0; i < 3; i = i + 1) begin
                I_int[i]   <= 45'sd0;
                Q_int[i]   <= 45'sd0;
                I_delay[i] <= 45'sd0;
                Q_delay[i] <= 45'sd0;
                I_comb[i]  <= 45'sd0;
                Q_comb[i]  <= 45'sd0;
            end
            strobe_count <= 6'b0;
            cic_out <= 1'b0;
        end else begin
            cic_out <= 1'b0;
            if (out_valid) begin
                I_int[0] <= I_int[0] + mixer_I;
                I_int[1] <= I_int[1] + I_int[0];
                I_int[2] <= I_int[2] + I_int[1];
                Q_int[0] <= Q_int[0] + mixer_Q;
                Q_int[1] <= Q_int[1] + Q_int[0];
                Q_int[2] <= Q_int[2] + Q_int[1];
                if (strobe_count == 6'd63) begin
                    strobe_count <= 6'b0;
                    I_delay[0] <= I_int[2];
                    I_delay[1] <= I_comb[0];
                    I_delay[2] <= I_comb[1];
                    I_comb[0] <= I_int[2] - I_delay[0];
                    I_comb[1] <= I_comb[0] - I_delay[1];
                    I_comb[2] <= I_comb[1] - I_delay[2];
                    Q_delay[0] <= Q_int[2];
                    Q_delay[1] <= Q_comb[0];
                    Q_delay[2] <= Q_comb[1];
                    Q_comb[0] <= Q_int[2] - Q_delay[0];
                    Q_comb[1] <= Q_comb[0] - Q_delay[1];
                    Q_comb[2] <= Q_comb[1] - Q_delay[2];
                    cic_out <= 1'b1;
                end else begin
                    strobe_count <= strobe_count + 1'b1;
                end
            end
        end
    end


    assign CIC_I = I_comb[2];
    assign CIC_Q = Q_comb[2];

endmodule
