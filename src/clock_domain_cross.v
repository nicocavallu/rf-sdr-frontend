/* clock_domain_cross.v
* This module handles SDR data transfer from the SBC to the the FPGA
* to deal with the asynchronous clocks this module uses
* a two-stage-synchronizer with a single-strobe handshake
* to take alternating I and Q data stream inputs
* and output one quadrature signal to the mixer synchronized with the 25MHz clock
* */

module clock_domain_cross(
    input clk, arst_n, sbc_strobe,
    input [7:0] sdr_signal_in,
    output reg mixer_enable,
    output [15:0] sdr_signal_out);

    localparam [1:0] I_OUT = 2'd0, Q_OUT = 2'd1, RESET = 2'd2;
    reg [1:0] state, next_state;
    reg [7:0] inter_I, inter_Q, capture_I, capture_Q;
    reg strobe_sync0, strobe_sync1, strobe_sync2;

    wire strobe_state = strobe_sync1 && !strobe_sync2;

    always_comb begin
        case(state)
            I_OUT: next_state = (strobe_state) ? Q_OUT : I_OUT;
            Q_OUT: next_state = (strobe_state) ? I_OUT : Q_OUT;
            RESET: next_state = (arst_n) ? I_OUT : RESET;
            default: next_state = I_OUT;
        endcase
    end

    always @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            state <= RESET;
            inter_I <= 8'b0;
            capture_I <= 8'b0;
            inter_Q <= 8'b0;
            capture_Q <= 8'b0;
            mixer_enable <= 1'b0;
        end else begin
            state <= next_state;

            strobe_sync0 <= sbc_strobe;
            strobe_sync1<= strobe_sync0;
            strobe_sync2 <= strobe_sync1;

            mixer_enable <= 1'b0;
            if (strobe_state) begin
                if (state == I_OUT) begin
                    inter_I <= sdr_signal_in;
                end else if (state == Q_OUT) begin
                    inter_Q      <= sdr_signal_in;
                    capture_I    <= inter_I;
                    capture_Q    <= sdr_signal_in;
                    mixer_enable <= 1'b1;
                end
            end
        end
    end

    assign sdr_signal_out = {capture_Q, capture_I};
endmodule

