import random

N = 8
FRAC_BITS = 14

W = [
    (16384, 0),
    (11585, -11585),
    (0, -16384),
    (-11585, -11585)
]


def butterfly(A, B, W):
    Ar, Ai = A
    Br, Bi = B
    Wr, Wi = W

    T_real = (Br * Wr - Bi * Wi) >> FRAC_BITS
    T_imag = (Br * Wi + Bi * Wr) >> FRAC_BITS

    return (
        (Ar + T_real, Ai + T_imag),
        (Ar - T_real, Ai - T_imag)
    )


def fft8_fixed(x_real, x_imag):

    # Bit reversal
    order = [0, 4, 2, 6, 1, 5, 3, 7]

    stage0 = [
        (x_real[i], x_imag[i])
        for i in order
    ]

    # Stage 1
    stage1 = [None] * 8

    for a, b in [(0, 1), (2, 3), (4, 5), (6, 7)]:
        y0, y1 = butterfly(stage0[a], stage0[b], W[0])
        stage1[a] = y0
        stage1[b] = y1

    # Stage 2
    stage2 = [None] * 8

    pairs = [
        (0, 2, 0),
        (1, 3, 2),
        (4, 6, 0),
        (5, 7, 2)
    ]

    for a, b, w in pairs:
        y0, y1 = butterfly(stage1[a], stage1[b], W[w])
        stage2[a] = y0
        stage2[b] = y1

    # Stage 3
    output = [None] * 8

    pairs = [
        (0, 4, 0),
        (1, 5, 1),
        (2, 6, 2),
        (3, 7, 3)
    ]

    for a, b, w in pairs:
        y0, y1 = butterfly(stage2[a], stage2[b], W[w])
        output[a] = y0
        output[b] = y1

    return output


# ------------------------------------------------------------
# Generate random test vectors
# ------------------------------------------------------------

NUM_TESTS = 100

with open("fft_vectors.txt", "w") as f:

    for _ in range(NUM_TESTS):

        # Keep inputs comfortably inside the 16-bit range.
        x_real = [
            random.randint(-12000, 12000)
            for _ in range(N)
        ]

        x_imag = [
            random.randint(-12000, 12000)
            for _ in range(N)
        ]

        expected = fft8_fixed(x_real, x_imag)

        # One line per test:
        # 8 real inputs, 8 imag inputs,
        # 8 real outputs, 8 imag outputs

        values = (
            x_real +
            x_imag +
            [x[0] for x in expected] +
            [x[1] for x in expected]
        )

        f.write(" ".join(str(v) for v in values) + "\n")

print(f"Generated {NUM_TESTS} random FFT test vectors.")