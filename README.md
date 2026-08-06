# RF-SDR-Frontend

## Overview
The goal of this project is to implement an RF Software Defined Radio (SDR) Frontend to interface with FPGA signal processing blocks. This frontend handles initial signal acquisition, mixing, filtering, and decimation, serving as a critical upstream component of the overarching project to analyze LoRa data using the ULX3S FPGA. The frontend uses the [rf-dds-lo](https://github.com/nicocavallu/rf-dds-lo) sister repository as a local oscillator for mixing to feed filtered baseband data into Fourier processing blocks.

## System
![System](rf_frontend.png)

The DSP pipeline consists of the following hardware blocks:
1. **SDR Interface:** Receives a 16-bit `[15:0]` digital stream from the physical SDR platform.
2. **SBC Data Formatting:** Formats SDR data into two 8-bit `[7:0]` streams.
3. **Clock Domain Crossing Block:** Send asynchronous data from the SBC to downstream mixer as Quadrature signals.
4. **Mixer & DDS-LO:** Mixes Quadrature signals with local oscillator, producing a 27-bit `[26:0]` intermediate signal.
5. **Finite Impulse Response Filter:** Provides sharp anti-aliasing baseband filtering and final stage shaping.
6. **RNG Mixer and Truncation:** Truncates filtered signal to 16-bit `[15:0]` stream for decoding and applies RNG dithering to reduce noise caused by truncation. 

## Hardware Requirements 

### FPGA Platform:
[Radiona ULX3S](https://radiona.org/ulx3s/) (Lattice ECP5 LFE5U-85F)

### SDR Platform:
[HackRF Pro](https://greatscottgadgets.com/hackrf/pro/) 

## Decoding Specifications:  
Assuming a standard US 915 MHz LoRa signal, the ULX3S 25MHz clock, and target IF processing:

* **Target Center Frequency:** 915 MHz  
* **ADC Sampling Rate:** 20MSPS  
* **Digital Down-Conversion Bandwidth:** 125kHz  
* **Output Word Size:** 16 bits `[15:0]`


## Software Environment and Requirements

### Operating System:   
This project was developed in an Arch Linux environment using open-source hardware toolchain dependencies. 

### Dependencies:  
* iverilog  
* gtkwave  
* yosys 
* nextpnr-ecp5  
* fujprog
* python3
* numpy

## Quick Start:


This repository includes a .lpf file for hardware integration of the ULX3S FPGA board.

## Reference:  
[HackRF Course](https://www.greatscottgadgets.com/sdr/)  
[Dithering](https://en.wikipedia.org/wiki/Dither)
[FIR Filters](https://www.elprocus.com/fir-filter-for-digital-signal-processing/)
