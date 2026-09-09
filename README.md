# 8-Point Fixed-Point FFT Accelerator

A SystemVerilog implementation of an 8-point radix-2 Fast Fourier Transform (FFT) accelerator with fixed-point complex arithmetic, modular butterfly RTL, self-checking verification, and FPGA timing/resource analysis.

## Overview

This project implements an 8-point radix-2 decimation-in-time FFT using a 3-stage butterfly architecture.

The design accepts 8 complex input samples in natural order, performs internal bit-reversal reordering, and produces 8 FFT outputs in natural order.

### Architecture

```text
             8 Complex Inputs
                    │
                    ▼
            Bit-Reversal Order
          [0,4,2,6,1,5,3,7]
                    │
                    ▼
          ┌───────────────────┐
          │     Stage 1       │
          │   4 Butterflies   │
          └─────────┬─────────┘
                    │
                    ▼
          ┌───────────────────┐
          │     Stage 2       │
          │   4 Butterflies   │
          └─────────┬─────────┘
                    │
                    ▼
          ┌───────────────────┐
          │     Stage 3       │
          │   4 Butterflies   │
          └─────────┬─────────┘
                    │
                    ▼
             8 FFT Outputs
