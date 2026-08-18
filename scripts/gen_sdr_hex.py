"""
gen_sdr_hex.py
Python script to generate a LoRa wave for simulation
"""

import numpy as np

def generate_sdr_hex(chirp_time, filename):
    # Parameters 
    sample_rate = 20e6
    bandwidth = 125e3
    center_freq = 1e6

    # Generate Samples 
    num_iq_pairs = int(sample_rate * chirp_time);
    t = np.arange(num_iq_pairs) / sample_rate;

    # Frequency Ramp
    k = bandwidth / chirp_time;

    # Phase equation of linear chirp up 
    f_start = center_freq - (bandwidth/2)
    phase = 2 * np.pi * (f_start * t + .5 * k * (t**2))

    # Generate I/Q pair from phase 
    i_signal = (127 * np.cos(phase)).astype(np.int8);
    q_signal = (127 * np.sin(phase)).astype(np.int8);

    # Interweave I and Q signals 
    interweaved_bytes = np.empty((num_iq_pairs * 2,), dtype=np.int8);
    interweaved_bytes[0::2] = i_signal;
    interweaved_bytes[1::2] = q_signal;

    # Export as hex file
    with open(filename, "w") as f:
        for val in interweaved_bytes:
            f.write(f"{int(val) & 0xFF:02X}\n")

    print(f"Generated 'sdr_in.hex' with {len(interweaved_bytes)} bytes of LoRa up-chirp data.")

# Generate 40k dataset (1 ms chirp) and 80k dataset (2 ms chirp)
generate_sdr_hex(1e-3, "sdr_in_40k.hex")
generate_sdr_hex(2e-3, "sdr_in_80k.hex")
