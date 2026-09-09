`timescale 1ns/1ps

module tb_fft8;

    logic clk;
    logic rst_n;
    logic in_valid;

    logic signed [15:0] in_real [0:7];
    logic signed [15:0] in_imag [0:7];

    logic out_valid;

    logic signed [18:0] out_real [0:7];
    logic signed [18:0] out_imag [0:7];

    integer i;
    integer errors;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    fft8_top dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .in_real   (in_real),
        .in_imag   (in_imag),
        .out_valid (out_valid),
        .out_real  (out_real),
        .out_imag  (out_imag)
    );

    // ------------------------------------------------------------
    // Clock: 10 ns period
    // ------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // Apply one FFT frame
    // ------------------------------------------------------------

    task automatic apply_frame;
        begin
            in_valid = 1'b1;
            @(posedge clk);
            #1;
            in_valid = 1'b0;
        end
    endtask

    // ------------------------------------------------------------
    // Wait for output and check impulse response
    //
    // x = [1,0,0,0,0,0,0,0]
    //
    // X = [1,1,1,1,1,1,1,1]
    //
    // Q2.14:
    // 1.0 = 16384
    // ------------------------------------------------------------

    task automatic check_impulse;
        begin
            repeat (5) begin
                @(posedge clk);
                #1;

                $display("time=%0t valid=%b | S1[0]=%0d S2[0]=%0d OUT[0]=%0d",
                        $time,
                        out_valid,
                        dut.stage1_real_reg[0],
                        dut.stage2_real_reg[0],
                        out_real[0]);
            end

            
            for (i = 0; i < 8; i = i + 1) begin

                if (out_real[i] !== 19'sd16384) begin
                    $display("ERROR: impulse X[%0d].real = %0d, expected 16384",
                             i, out_real[i]);
                    errors = errors + 1;
                end

                if (out_imag[i] !== 19'sd0) begin
                    $display("ERROR: impulse X[%0d].imag = %0d, expected 0",
                             i, out_imag[i]);
                    errors = errors + 1;
                end

            end

            if (errors == 0)
                $display("TEST 1 PASSED: impulse response");
        end
    endtask

    // ------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------

    initial begin

        errors   = 0;
        rst_n    = 1'b0;
        in_valid = 1'b0;

        // Initialize inputs
        for (i = 0; i < 8; i = i + 1) begin
            in_real[i] = 16'sd0;
            in_imag[i] = 16'sd0;
        end

        // Reset
        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        // --------------------------------------------------------
        // TEST 1: impulse
        // --------------------------------------------------------

        in_real[0] = 16'sd16384;     // 1.0
        in_imag[0] = 16'sd0;

        for (i = 1; i < 8; i = i + 1) begin
            in_real[i] = 16'sd0;
            in_imag[i] = 16'sd0;
        end

        apply_frame();

        check_impulse();


        // --------------------------------------------------------
        // TEST 2: x[1] = 1, all other samples = 0
        //
        // Expected FFT:
        //
        // X[0] =  1       + j0
        // X[1] =  0.7071  - j0.7071
        // X[2] =  0       - j1
        // X[3] = -0.7071  - j0.7071
        // X[4] = -1       + j0
        // X[5] = -0.7071  + j0.7071
        // X[6] =  0       + j1
        // X[7] =  0.7071  + j0.7071
        //
        // Q2.14:
        // 1      = 16384
        // 1/sqrt2 ≈ 11585
        // --------------------------------------------------------

        $display("\nTEST 2: single impulse at x[1]");

        for (i = 0; i < 8; i = i + 1) begin
            in_real[i] = 16'sd0;
            in_imag[i] = 16'sd0;
        end

        in_real[1] = 16'sd16384;

        apply_frame();

        wait(out_valid == 1'b1);
        #1;

        if (out_real[0] !== 19'sd16384 ||
            out_imag[0] !== 19'sd0) begin
            $display("ERROR: X[0] = %0d + j%0d",
                    out_real[0], out_imag[0]);
            errors = errors + 1;
        end

        if (out_real[1] !== 19'sd11585 ||
            out_imag[1] !== -19'sd11585) begin
            $display("ERROR: X[1] = %0d + j%0d",
                    out_real[1], out_imag[1]);
            errors = errors + 1;
        end

        if (out_real[2] !== 19'sd0 ||
            out_imag[2] !== -19'sd16384) begin
            $display("ERROR: X[2] = %0d + j%0d",
                    out_real[2], out_imag[2]);
            errors = errors + 1;
        end

        if (out_real[3] !== -19'sd11585 ||
            out_imag[3] !== -19'sd11585) begin
            $display("ERROR: X[3] = %0d + j%0d",
                    out_real[3], out_imag[3]);
            errors = errors + 1;
        end

        if (out_real[4] !== -19'sd16384 ||
            out_imag[4] !== 19'sd0) begin
            $display("ERROR: X[4] = %0d + j%0d",
                    out_real[4], out_imag[4]);
            errors = errors + 1;
        end

        if (out_real[5] !== -19'sd11585 ||
            out_imag[5] !== 19'sd11585) begin
            $display("ERROR: X[5] = %0d + j%0d",
                    out_real[5], out_imag[5]);
            errors = errors + 1;
        end

        if (out_real[6] !== 19'sd0 ||
            out_imag[6] !== 19'sd16384) begin
            $display("ERROR: X[6] = %0d + j%0d",
                    out_real[6], out_imag[6]);
            errors = errors + 1;
        end

        if (out_real[7] !== 19'sd11585 ||
            out_imag[7] !== 19'sd11585) begin
            $display("ERROR: X[7] = %0d + j%0d",
                    out_real[7], out_imag[7]);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("TEST 2 PASSED: impulse at x[1]");



        // ---------------------------------------------------------
        // TEST 3: general input [0.125, 0.25, ..., 1.0]
        // ---------------------------------------------------------
        $display("TEST 3: general input [0.125,0.25,0.375,0.5,0.625,0.75,0.875,1.0]");

        // Input in Q2.14 format
        in_real[0] = 16'sd2048;   // 0.125
        in_real[1] = 16'sd4096;   // 0.25
        in_real[2] = 16'sd6144;   // 0.375
        in_real[3] = 16'sd8192;   // 0.5
        in_real[4] = 16'sd10240;  // 0.625
        in_real[5] = 16'sd12288;  // 0.75
        in_real[6] = 16'sd14336;  // 0.875
        in_real[7] = 16'sd16384;  // 1.0

        for (i = 0; i < 8; i = i + 1)
            in_imag[i] = 16'sd0;

        apply_frame();

        wait(out_valid == 1'b1);
        #1;

        // Expected FFT output
        if ((out_real[0] !== 19'sd73728)  || (out_imag[0] !== 19'sd0)      ||
            (out_real[1] !== -19'sd8192)  || (out_imag[1] !== 19'sd19731)  ||
            (out_real[2] !== -19'sd8192)  || (out_imag[2] !== 19'sd8192)   ||
            (out_real[3] !== -19'sd8192)  || (out_imag[3] !== 19'sd3387)   ||
            (out_real[4] !== -19'sd8192)  || (out_imag[4] !== 19'sd0)      ||
            (out_real[5] !== -19'sd8192)  || (out_imag[5] !== -19'sd3387)  ||
            (out_real[6] !== -19'sd8192)  || (out_imag[6] !== -19'sd8192)  ||
            (out_real[7] !== -19'sd8192)  || (out_imag[7] !== -19'sd19731)) begin

            $display("TEST 3 FAILED");
            errors = errors + 1;
        end
        else begin
            $display("TEST 3 PASSED: general input");
        end

        // --------------------------------------------------------
        // End
        // --------------------------------------------------------

        if (errors == 0)
            $display("\nALL FFT TESTS PASSED");
        else
            $display("\nFFT TEST FAILED: %0d errors", errors);
            $display("FFT output:");
            for (int i = 0; i < 8; i++)
                $display("X[%0d] = %0d + j(%0d)", i, out_real[i], out_imag[i]);

        $finish;
    end


    
endmodule