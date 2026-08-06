"""
gen_sdr_hex.py
Python script to generate a LoRa wave for simulation
"""

import numpy as np

# Parameters 
sample_rate = 20e6
bandwidth = 125e3
chirp_time = 1e-3
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
with open("sdr_in_hex", "w") as f:
    for val in interweaved_bytes:
        f.write(f"{int(val) & 0xFF:02X}\n")


print(f"Generated 'sdr_in.hex' with {len(interweaved_bytes)} bytes of LoRa up-chirp data.")

