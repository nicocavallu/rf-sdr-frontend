/* fir_filter.v
* This module implements a Finite Impulse Response filter
* with 31 taps
* Taps are generated using a python script to create a hammign window
* The FIR filter will correct the passband sinc^3 droop induced by the CIC
*/

module fir_filter(
    input clk, arst_n, cic_out,
    input [44:0] CIC_I, CIC_Q,
    output reg fir_out,
    output reg [65:0] FIR_I, FIR_Q);

    localparam [1:0] LOAD = 0, FILT_I = 1, FILT_Q = 2, IDLE = 3;

    integer i;

    reg[1:0] state, next_state;
    reg [4:0] k;
    reg signed [44:0] history_I [31];
    reg signed [44:0] history_Q [31];
    reg signed [15:0] taps [31];
    reg signed [65:0] I_accum, Q_accum;

    // Load FIR coefficients
    initial begin
        $readmemh("../scripts/fir_coeff.mem", taps);
    end

    // State transition logic
    always_comb begin
        case (state)
            IDLE: next_state = cic_out ? LOAD : IDLE;
            LOAD: next_state = FILT_I;
            FILT_I: next_state = k == 5'd30 ? FILT_Q : FILT_I;
            FILT_Q: next_state = k == 5'd30 ? IDLE : FILT_Q;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge arst_n) begin
        if (arst_n) begin
            k <= 5'b0;
            state <= IDLE;
            I_accum <= 66'd0;
            Q_accum <= 66'd0;
            FIR_I <= 66'd0;
            FIR_Q <= 66'd0;

            for (i = 0; i < 31; i = i + 1) begin
                history_I[i] <= 45'd0;
                history_Q[i] <= 45'd0;
            end

        end else begin
            state <= next_state;

            // Load new data
            if (state == LOAD) begin
                for (i = 0; i < 31; i = i + 1) begin
                    history_I[i] <= i == 0 ? CIC_I : history_I[i - 1];
                    history_Q[i] <= i == 0 ? CIC_Q : history_I[i - 1];
                end
            end

            // Filter I
            else if (state == FILT_I) begin

                if (k == 5'd30) begin
                    k <= 5'd0;
                    FIR_I <= I_accum;
                    I_accum <= 66'd0;
                end else begin
                    k <= k + 1'b1;
                    I_accum <= I_accum + (taps[k] * history_I[k]);
                end
            end

            // Filter Q
            else if (state == FILT_Q) begin

                if (k == 5'd30) begin
                    k <= 5'd0;
                    FIR_Q <= Q_accum;
                    Q_accum <= 66'd0;
                    fir_out <= 1'b1;
                end else begin
                    k <= k + 1'b1;
                    Q_accum <= Q_accum + (taps[k] * history_Q[k]);
                end
            end

            // Idle
            else begin
                fir_out <= 1'b0;
            end
        end
    end

endmodule


