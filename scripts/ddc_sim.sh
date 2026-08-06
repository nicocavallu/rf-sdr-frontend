#! /bin/bash

set -e

echo "Generating DDC Script" 
python3 gen_sdr_hex.py
python3 ../modules/rf-dds-lo/scripts/gen_sin_table.py

iverilog -g2012 -o ddc_sim.vvp \
  ../sim/digital_downconvert_tb.v \
  ../src/digital_downconvert.v \
  ../src/clock_domain_cross.v \
  ../src/complex_mixer.v \
  ../src/cic_filt.v \
  ../modules/rf-dds-lo/src/*.v

vvp ddc_sim.vvp
gtkwave digital_downconvert.vcd
