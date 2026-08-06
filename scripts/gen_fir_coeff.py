#! /usr/bin/env python3
"""
gen_fir_coeff.py
Uses the SciPy library to generate fixed-point 16-bit signed FIR coefficients for LoRa DDC 
"""

import numpy as np
from scipy import signal

# Filter Parameters 
fs = 25.0e6
cutoff = 125.0e3
num_taps = 31
bits = 16

# Generate the coefficients to created desired Hamming Window 
coeff_floats = signal.firwin(num_taps, cutoff, fs=fs, window='hamming')

# Quantatize floats to 16 bit signed integers 
scale_factor = (1 << (bits-1)) - 1
coeffs_int = np.round(coeff_floats / np.max(np.abs(coeff_floats)) * scale_factor).astype(int)

# Print out verilog array syntax
print(f"// Generated 16-bit Signed Coefficients ({num_taps} Taps)")
print(f"// Cutoff: {cutoff/1e3} kHz @ Fs: {fs/1e6} MHz\n")

print(f"localparam signed [15:0] TAPS [{num_taps}] = '{{")
for i, c in enumerate(coeffs_int):
    comma = "," if i < num_taps - 1 else ""
    print(f"16'sd{c}{comma} // Tap {i}: Float = {coeff_floats[i]:.6f}")
print("};")

# Save to a .mem file for $readmemh loading
with open("sim/fir_coeffs.mem", "w") as f:
    for c in coeffs_int:
        # Convert 16-bit signed integer to two's complement hex
        hex_val = f"{c & 0xFFFF:04X}"
        f.write(f"{hex_val}\n")

print("\nSaved hex coefficients to 'sim/fir_coeffs.mem'")


