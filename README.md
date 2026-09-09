# 8-Point Fixed-Point FFT Accelerator

A SystemVerilog implementation of an 8-point radix-2 Fast Fourier Transform (FFT) accelerator with fixed-point complex arithmetic, modular butterfly RTL, self-checking verification, and FPGA timing/resource analysis.

## Overview

This project implements an 8-point radix-2 decimation-in-time FFT using a 3-stage butterfly architecture.

The design accepts 8 complex input samples in natural order, performs internal bit-reversal reordering, and produces 8 FFT outputs in natural order.

### Architecture

8 Complex Inputs
       |
       v
Bit-Reversal Reordering
[0, 4, 2, 6, 1, 5, 3, 7]
       |
       v
Stage 1: 4 Radix-2 Butterflies
       |
       v
Stage 2: 4 Radix-2 Butterflies
       |
       v
Stage 3: 4 Radix-2 Butterflies
       |
       v
8 FFT Outputs

Each radix-2 butterfly computes:

T  = B x W
Y0 = A + T
Y1 = A - T

where A and B are complex inputs and W is the corresponding twiddle factor.

The FFT uses three radix-2 stages because log2(8) = 3.

## Fixed-Point Representation

Inputs and twiddle coefficients use signed Q2.14 fixed-point representation with 14 fractional bits.

The conversion between real values and stored integers is:

Real value = Stored integer / 2^14

Therefore:

| Value | Q2.14 Representation |
|-------|-----------------------|
| 1.0   | 16384                 |
| 0.5   | 8192                  |
| 0.25  | 4096                  |
| 0.125 | 2048                  |

The unique 8-point FFT twiddle coefficients used by the design are:

W0 =  16384 + j0
W1 =  11585 - j11585
W2 =      0 - j16384
W3 = -11585 - j11585

For complex multiplication:

T_real = B_real * W_real - B_imag * W_imag
T_imag = B_real * W_imag + B_imag * W_real

Multiplication of two Q2.14 values produces a result with 28 fractional bits. The result is arithmetically shifted right by 14 bits to restore the Q2.14 scaling.

The datapath allows one bit of growth at each butterfly stage:

Input   : 16 bits
Stage 1 : 17 bits
Stage 2 : 18 bits
Output  : 19 bits

## RTL Design

The design is organized around a parameterized radix-2 butterfly module and a top-level FFT module.

The butterfly implements the complex multiplication followed by the sum/difference operations:

A ---------------------> (+) -----> Y0
                          ^
                          |
B -----> Complex x W ----+

A ---------------------> (-) -----> Y1
                          ^
                          |
B -----> Complex x W ----+

The top-level module instantiates four butterflies per stage for a total of twelve radix-2 butterflies.

The baseline architecture contains pipeline registers between FFT stages, with a valid signal propagated alongside the data.

## Verification

A Python fixed-point reference model was developed as a golden reference for the RTL.

The reference model reproduces the relevant fixed-point behavior of the hardware, including:

- Bit-reversal ordering
- Radix-2 butterfly operations
- Precomputed quantized twiddle coefficients
- Complex fixed-point multiplication
- Arithmetic right shifting
- Stage-by-stage datapath width growth

Verification was performed using both directed and randomized tests.

Directed tests included:

- Impulse input at x[0]
- Impulse input at x[1]
- General non-trivial input sequence

A self-checking SystemVerilog testbench automatically compares RTL outputs against the Python-generated golden vectors.

### Randomized Verification Result

Tests executed : 100
Errors          : 0

ALL RANDOM TESTS PASSED

## PPA and Timing Experiment

The baseline FFT architecture was synthesized and implemented using AMD/Xilinx Vivado with a 100 MHz clock constraint.

A second architecture explored deeper pipelining inside the butterfly datapath by registering the multiplier products and corresponding input operands.

### Post-Implementation Comparison

| Metric | Baseline | Pipelined Butterfly |
|--------|----------|---------------------|
| LUTs | 984 | 1633 |
| FFs | 867 | 730 |
| DSPs | 7 | 48 |
| BRAM | 0 | 0 |
| Slices | 294 | 471 |
| WNS | +1.613 ns | +1.648 ns |
| Fmax | ~119.2 MHz | ~119.7 MHz |
| Latency | 3 cycles | 4 cycles |
| Throughput | 1 frame/cycle | 1 frame/cycle |

The deeper butterfly-level pipelining produced only a marginal timing improvement. The baseline already met the 100 MHz timing target comfortably.

However, the pipelined version increased LUT utilization, DSP utilization and slice usage, while adding one cycle of latency. Throughput remained one complete FFT frame per clock once the pipeline was full.

This experiment demonstrates the importance of evaluating RTL optimizations using actual synthesis and implementation results rather than assuming that additional pipelining will necessarily improve overall PPA.

## Project Structure

FFT-Accelerator/
|
+-- rtl/
|   +-- fft8_top.sv
|   +-- fft8_butterfly.sv
|
+-- tb/
|   +-- tb_fft8.sv
|   +-- tb_fft8_random.sv
|
+-- python/
|   +-- fft_reference.py
|
+-- vectors/
|   +-- fft_vectors.txt
|
+-- README.md

## Tools

- SystemVerilog
- Python
- AMD/Xilinx Vivado
- Icarus Verilog
- GTKWave

## Key Takeaways

- Implemented an 8-point radix-2 FFT accelerator in synthesizable SystemVerilog.
- Designed a modular radix-2 butterfly with fixed-point complex arithmetic.
- Used Q2.14 representation with controlled datapath width growth.
- Developed a Python fixed-point reference model.
- Built directed and randomized self-checking RTL verification.
- Verified 100 randomized FFT vectors with zero errors.
- Explored butterfly-level pipelining as a timing/PPA optimization.
- Performed FPGA synthesis, implementation and timing/resource analysis.
- Evaluated the trade-off between timing, latency, throughput and FPGA resources.
