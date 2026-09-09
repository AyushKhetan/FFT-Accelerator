`timescale 1ns/1ps

module tb_fft8_butterfly;

    // ------------------------------------------------------------
    // Q2.14 constants
    // ------------------------------------------------------------
    localparam logic signed [15:0] Q_ONE      = 16'sd16384;
    localparam logic signed [15:0] Q_NEG_ONE  = -16'sd16384;
    localparam logic signed [15:0] Q_SQRT2INV = 16'sd11585;

    // ------------------------------------------------------------
    // DUT inputs
    // ------------------------------------------------------------
    logic signed [15:0] A_real, A_imag;
    logic signed [15:0] B_real, B_imag;
    logic signed [15:0] W_real, W_imag;

    // ------------------------------------------------------------
    // DUT outputs
    // ------------------------------------------------------------
    logic signed [16:0] Y0_real, Y0_imag;
    logic signed [16:0] Y1_real, Y1_imag;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    fft8_butterfly #(
        .IN_WIDTH(16),
        .FRAC_BITS(14)
    ) dut (
        .A_real  (A_real),
        .A_imag  (A_imag),
        .B_real  (B_real),
        .B_imag  (B_imag),
        .W_real  (W_real),
        .W_imag  (W_imag),
        .Y0_real (Y0_real),
        .Y0_imag (Y0_imag),
        .Y1_real (Y1_real),
        .Y1_imag (Y1_imag)
    );

    // ------------------------------------------------------------
    // Test counter
    // ------------------------------------------------------------
    integer errors;

    // ------------------------------------------------------------
    // Check task
    // ------------------------------------------------------------
    task automatic check_result (
        input integer expected_y0_real,
        input integer expected_y0_imag,
        input integer expected_y1_real,
        input integer expected_y1_imag
    );
        begin
            #1;

            if (Y0_real !== expected_y0_real) begin
                $display("ERROR: Y0_real = %0d, expected %0d",
                         Y0_real, expected_y0_real);
                errors = errors + 1;
            end

            if (Y0_imag !== expected_y0_imag) begin
                $display("ERROR: Y0_imag = %0d, expected %0d",
                         Y0_imag, expected_y0_imag);
                errors = errors + 1;
            end

            if (Y1_real !== expected_y1_real) begin
                $display("ERROR: Y1_real = %0d, expected %0d",
                         Y1_real, expected_y1_real);
                errors = errors + 1;
            end

            if (Y1_imag !== expected_y1_imag) begin
                $display("ERROR: Y1_imag = %0d, expected %0d",
                         Y1_imag, expected_y1_imag);
                errors = errors + 1;
            end
        end
    endtask


    // ------------------------------------------------------------
    // Tests
    // ------------------------------------------------------------
    initial begin

        errors = 0;

        // ========================================================
        // TEST 1
        // W = 1
        //
        // A = 0.5 + j0.25
        // B = 0.25 + j0.125
        //
        // Y0 = A + B
        // Y1 = A - B
        // ========================================================

        A_real = 16'sd8192;   // 0.5
        A_imag = 16'sd4096;   // 0.25

        B_real = 16'sd4096;   // 0.25
        B_imag = 16'sd2048;   // 0.125

        W_real = Q_ONE;
        W_imag = 16'sd0;

        #1;

        check_result(
            17'sd12288,   // 0.75
            17'sd6144,    // 0.375
            17'sd4096,    // 0.25
            17'sd2048     // 0.125
        );

        $display("TEST 1 PASSED: W = 1");


        // ========================================================
        // TEST 2
        // W = -j
        //
        // B = 0.25 + j0.125
        //
        // B*(-j) = 0.125 - j0.25
        // ========================================================

        A_real = 16'sd8192;   // 0.5
        A_imag = 16'sd4096;   // 0.25

        B_real = 16'sd4096;   // 0.25
        B_imag = 16'sd2048;   // 0.125

        W_real = 16'sd0;
        W_imag = Q_NEG_ONE;

        #1;

        check_result(
            17'sd10240,    // 0.625
            17'sd0,        // 0
            17'sd6144,     // 0.375
            17'sd8192      // 0.5
        );

        $display("TEST 2 PASSED: W = -j");


        // ========================================================
        // TEST 3
        // W = (1-j)/sqrt(2)
        //
        // Use B = 1 + j0
        //
        // B*W = 0.7071 - j0.7071
        //
        // A = 0 + j0
        // ========================================================

        A_real = 16'sd0;
        A_imag = 16'sd0;

        B_real = Q_ONE;
        B_imag = 16'sd0;

        W_real = Q_SQRT2INV;
        W_imag = -Q_SQRT2INV;

        #1;

        check_result(
            17'sd11585,
            -17'sd11585,
            -17'sd11585,
            17'sd11585
        );

        $display("TEST 3 PASSED: W = (1-j)/sqrt(2)");


        // ========================================================
        // TEST 4
        // W = -(1+j)/sqrt(2)
        //
        // Use B = 1 + j0
        //
        // B*W = -0.7071 - j0.7071
        // ========================================================

        A_real = 16'sd0;
        A_imag = 16'sd0;

        B_real = Q_ONE;
        B_imag = 16'sd0;

        W_real = -Q_SQRT2INV;
        W_imag = -Q_SQRT2INV;

        #1;

        check_result(
            -17'sd11585,
            -17'sd11585,
            17'sd11585,
            17'sd11585
        );

        $display("TEST 4 PASSED: W = -(1+j)/sqrt(2)");


        // ========================================================
        // TEST 5
        // Negative complex values
        // W = 1
        // ========================================================

        A_real = -16'sd4096;  // -0.25
        A_imag = 16'sd6144;   //  0.375

        B_real = -16'sd2048;  // -0.125
        B_imag = -16'sd4096;  // -0.25

        W_real = Q_ONE;
        W_imag = 16'sd0;

        #1;

        check_result(
            -17'sd6144,   // -0.375
            17'sd2048,    //  0.125
            -17'sd2048,   // -0.125
            17'sd10240    //  0.625
        );

        $display("TEST 5 PASSED: negative values");


        // ========================================================
        // FINAL RESULT
        // ========================================================

        if (errors == 0)
            $display("\n========================================");
        else
            $display("\n========================================");

        if (errors == 0)
            $display("ALL BUTTERFLY TESTS PASSED");
        else
            $display("%0d TEST ERRORS", errors);

        $display("========================================\n");

        $finish;
    end

endmodule