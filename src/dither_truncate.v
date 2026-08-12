/* dither_truncate.v
* This module truncates the 66-bit output of FIR filter
* additionaly it adds tpdf noise to linearize any distortian from truncation
*/

module dither_truncate(
    input clk, arst_n, fir_out,
    input signed [2:0] tpdf_dither,
    input signed [65:0] FIR_I, FIR_Q,
    output reg valid_out,
    output reg signed [17:0] I_OUT, Q_OUT);

    wire signed [65:0] dither_noise;

    // Sign extend and bit align
    assign dither_noise = $signed({{63{tpdf_dither[2]}}, tpdf_dither}) <<< 32;

    wire signed [65:0] sum_I = FIR_I + dither_noise;
    wire signed [65:0] sum_Q = FIR_Q + dither_noise;

    always @ (posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            I_OUT <= 18'd0;
            Q_OUT <= 18'd0;
            valid_out <= 1'b0;
        end else begin
            if (fir_out) begin
                I_OUT <= sum_I[49:32];
                Q_OUT <= sum_Q[49:32];
                valid_out <= 1'b1;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end
endmodule
