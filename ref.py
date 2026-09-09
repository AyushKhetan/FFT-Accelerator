import math

# ============================================================
# 8-POINT FIXED-POINT FFT REFERENCE MODEL
# ============================================================

N = 8
FRAC_BITS = 14
SCALE = 1 << FRAC_BITS

# Quantized twiddle factors used by the RTL
W = [
    (16384, 0),        # W8^0 = 1
    (11585, -11585),   # W8^1 = (1-j)/sqrt(2)
    (0, -16384),       # W8^2 = -j
    (-11585, -11585)   # W8^3 = -(1+j)/sqrt(2)
]


def butterfly(A, B, W):
    """
    Fixed-point radix-2 butterfly.

    A, B, W are (real, imag) integer tuples.
    All values use 14 fractional bits.
    """

    Ar, Ai = A
    Br, Bi = B
    Wr, Wi = W

    # Complex multiplication: B * W
    P1 = Br * Wr
    P2 = Bi * Wi
    P3 = Br * Wi
    P4 = Bi * Wr

    T_real = P1 - P2
    T_imag = P3 + P4

    # Match RTL arithmetic right shift >>> 14
    T_real = T_real >> FRAC_BITS
    T_imag = T_imag >> FRAC_BITS

    Y0 = (
        Ar + T_real,
        Ai + T_imag
    )

    Y1 = (
        Ar - T_real,
        Ai - T_imag
    )

    return Y0, Y1


def fft8_fixed(x_real, x_imag):
    """
    8-point radix-2 DIT FFT matching the RTL architecture.

    Input:
        8 natural-order complex samples in Q2.14.

    Output:
        8 complex fixed-point FFT samples.
    """

    # --------------------------------------------------------
    # Stage 0: bit reversal
    # RTL ordering:
    # 0, 4, 2, 6, 1, 5, 3, 7
    # --------------------------------------------------------

    bit_reverse = [0, 4, 2, 6, 1, 5, 3, 7]

    stage0 = [
        (x_real[i], x_imag[i])
        for i in bit_reverse
    ]

    # --------------------------------------------------------
    # Stage 1
    #
    # Pairings:
    # (0,1), (2,3), (4,5), (6,7)
    #
    # All twiddles = W8^0
    # --------------------------------------------------------

    stage1 = [None] * 8

    y0, y1 = butterfly(stage0[0], stage0[1], W[0])
    stage1[0], stage1[1] = y0, y1

    y0, y1 = butterfly(stage0[2], stage0[3], W[0])
    stage1[2], stage1[3] = y0, y1

    y0, y1 = butterfly(stage0[4], stage0[5], W[0])
    stage1[4], stage1[5] = y0, y1

    y0, y1 = butterfly(stage0[6], stage0[7], W[0])
    stage1[6], stage1[7] = y0, y1

    # --------------------------------------------------------
    # Stage 2
    #
    # Pairings:
    # (0,2) -> W8^0
    # (1,3) -> W8^2
    # (4,6) -> W8^0
    # (5,7) -> W8^2
    # --------------------------------------------------------

    stage2 = [None] * 8

    y0, y1 = butterfly(stage1[0], stage1[2], W[0])
    stage2[0], stage2[2] = y0, y1

    y0, y1 = butterfly(stage1[1], stage1[3], W[2])
    stage2[1], stage2[3] = y0, y1

    y0, y1 = butterfly(stage1[4], stage1[6], W[0])
    stage2[4], stage2[6] = y0, y1

    y0, y1 = butterfly(stage1[5], stage1[7], W[2])
    stage2[5], stage2[7] = y0, y1

    # --------------------------------------------------------
    # Stage 3
    #
    # Pairings:
    # (0,4) -> W8^0
    # (1,5) -> W8^1
    # (2,6) -> W8^2
    # (3,7) -> W8^3
    # --------------------------------------------------------

    output = [None] * 8

    y0, y1 = butterfly(stage2[0], stage2[4], W[0])
    output[0], output[4] = y0, y1

    y0, y1 = butterfly(stage2[1], stage2[5], W[1])
    output[1], output[5] = y0, y1

    y0, y1 = butterfly(stage2[2], stage2[6], W[2])
    output[2], output[6] = y0, y1

    y0, y1 = butterfly(stage2[3], stage2[7], W[3])
    output[3], output[7] = y0, y1

    return output


# ============================================================
# TESTING
# ============================================================

def run_test(name, x_real, x_imag, expected, tolerance=0):
    print("\n" + "=" * 60)
    print(name)
    print("=" * 60)

    result = fft8_fixed(x_real, x_imag)

    errors = 0

    for i, ((rr, ri), (er, ei)) in enumerate(zip(result, expected)):

        real_error = abs(rr - er)
        imag_error = abs(ri - ei)

        print(
            f"X[{i}] = {rr:7d} + j({ri:7d})   "
            f"expected = {er:7d} + j({ei:7d})"
        )

        if real_error > tolerance or imag_error > tolerance:
            errors += 1

    if errors == 0:
        print("PASS")
    else:
        print(f"FAIL: {errors} output samples outside tolerance")

    return errors


# ============================================================
# TEST 1: impulse at x[0]
# ============================================================

x_real = [16384, 0, 0, 0, 0, 0, 0, 0]
x_imag = [0] * 8

expected = [(16384, 0)] * 8

run_test(
    "TEST 1: impulse at x[0]",
    x_real,
    x_imag,
    expected
)


# ============================================================
# TEST 2: impulse at x[1]
# ============================================================

x_real = [0, 16384, 0, 0, 0, 0, 0, 0]
x_imag = [0] * 8

expected = [
    (16384, 0),
    (11585, -11585),
    (0, -16384),
    (-11585, -11585),
    (-16384, 0),
    (-11585, 11585),
    (0, 16384),
    (11585, 11585)
]

run_test(
    "TEST 2: impulse at x[1]",
    x_real,
    x_imag,
    expected
)


# ============================================================
# TEST 3: general input
# [0.125, 0.25, ..., 1.0]
# ============================================================

x_real = [
    2048,
    4096,
    6144,
    8192,
    10240,
    12288,
    14336,
    16384
]

x_imag = [0] * 8

# These are the expected fixed-point FFT values.
#
# For the nontrivial outputs, allow a small fixed-point
# tolerance because the RTL quantizes after each butterfly.
expected = [
    (73728, 0),
    (-8192, 19777),
    (-8192, 8192),
    (-8192, 3393),
    (-8192, 0),
    (-8192, -3393),
    (-8192, -8192),
    (-8192, -19777)
]

run_test(
    "TEST 3: general input",
    x_real,
    x_imag,
    expected,
    tolerance=2
)