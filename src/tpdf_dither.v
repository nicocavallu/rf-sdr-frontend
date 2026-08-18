/* tpdf_dither.v
* This module combines two rngs created by 12-bit Galois lfsr
* to create triangular probability density function noise
* This noise will linearize the noise from truncation
*/

module tpdf_dither(
    input clk, arst_n,
    output signed [3:0] tpdf_dither);

    wire [11:0] lfsr1, lfsr2;

    lfsr_rng_seed rng1(.clk(clk), .arst_n(arst_n), .seed(12'hACE), .q(lfsr1));
    lfsr_rng_seed rng2(.clk(clk), .arst_n(arst_n), .seed(12'h6B5), .q(lfsr2));

    assign tpdf_dither = $signed({1'b0, lfsr1[1:0]}) + $signed({1'b0, lfsr2[1:0]}) - 3'sd2;
endmodule

module lfsr_rng_seed(
    input clk, arst_n,
    input [11:0] seed,
    output reg [11:0] q);

    wire feedback = q[0];
    wire [11:0] mask = 12'hE08; // bit mask with taps at positions 11, 10, and 4
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            q <=seed; // non-zero seed
        end else begin
            q <= (q >> 1) ^ (feedback ? mask : 12'h0);
        end
    end
endmodule
