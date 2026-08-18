#!/bin/bash

set -e

echo "Generating SDR Top-Level Test Script" 
python3 gen_sdr_hex.py
python3 gen_fir_coeff.py
python3 ../modules/rf-dds-lo/scripts/gen_sin_table.py

iverilog -g2012 -o sdr_top_sim.vvp ../sim/sdr_frontend_top_tb.v ../src/*.v ../modules/rf-dds-lo/src/*.v

vvp sdr_top_sim.vvp
gtkwave sdr_frontend_top.vcd
