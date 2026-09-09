module tb_fft8_random;

    logic clk;
    logic rst_n;
    logic in_valid;

    logic signed [15:0] in_real [0:7];
    logic signed [15:0] in_imag [0:7];

    logic out_valid;
    logic signed [18:0] out_real [0:7];
    logic signed [18:0] out_imag [0:7];

    integer fd;
    integer ret;
    integer test_num;
    integer errors;
    integer i;

    integer expected_real [0:7];
    integer expected_imag [0:7];

    integer input_real [0:7];
    integer input_imag [0:7];

    fft8_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_real(in_real),
        .in_imag(in_imag),
        .out_valid(out_valid),
        .out_real(out_real),
        .out_imag(out_imag)
    );

    // Clock
    always #5 clk = ~clk;


    // --------------------------------------------------------
    // Apply one FFT frame
    // --------------------------------------------------------
    task apply_frame;
        begin
            in_valid = 1'b1;
            @(posedge clk);
            #1;
            in_valid = 1'b0;
        end
    endtask


    // --------------------------------------------------------
    // Test
    // --------------------------------------------------------
    initial begin

        clk = 0;
        rst_n = 0;
        in_valid = 0;
        errors = 0;
        test_num = 0;

        for (i = 0; i < 8; i = i + 1) begin
            in_real[i] = 0;
            in_imag[i] = 0;
        end

        // Reset
        #20;
        rst_n = 1;

        // Open Python-generated vectors
        fd = $fopen("fft_vectors.txt", "r");

        if (fd == 0) begin
            $display("ERROR: Could not open fft_vectors.txt");
            $finish;
        end

        // ----------------------------------------------------
        // Read and execute every test vector
        // ----------------------------------------------------
        while (!$feof(fd)) begin

            // Read 32 integers:
            // 8 input real
            // 8 input imag
            // 8 expected real
            // 8 expected imag

            while (!$feof(fd)) begin

                ret = $fscanf(fd,
                    "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                    
                    input_real[0], input_real[1],
                    input_real[2], input_real[3],
                    input_real[4], input_real[5],
                    input_real[6], input_real[7],

                    input_imag[0], input_imag[1],
                    input_imag[2], input_imag[3],
                    input_imag[4], input_imag[5],
                    input_imag[6], input_imag[7],

                    expected_real[0], expected_real[1],
                    expected_real[2], expected_real[3],
                    expected_real[4], expected_real[5],
                    expected_real[6], expected_real[7],

                    expected_imag[0], expected_imag[1],
                    expected_imag[2], expected_imag[3],
                    expected_imag[4], expected_imag[5],
                    expected_imag[6], expected_imag[7]
                );

                if (ret != 32)
                    break;

                // rest of the test...

            test_num = test_num + 1;

            // Drive inputs
            for (i = 0; i < 8; i = i + 1) begin
                in_real[i] = input_real[i];
                in_imag[i] = input_imag[i];
            end

            // Start FFT
            apply_frame();

            // Wait for result
            @(posedge out_valid);
            #1;

            // Compare all outputs
            for (i = 0; i < 8; i = i + 1) begin

                if ((out_real[i] !== expected_real[i]) ||
                    (out_imag[i] !== expected_imag[i])) begin

                    $display(
                        "TEST %0d FAILED: X[%0d] = %0d + j(%0d), expected %0d + j(%0d)",
                        test_num,
                        i,
                        out_real[i],
                        out_imag[i],
                        expected_real[i],
                        expected_imag[i]
                    );

                    errors = errors + 1;
                end
            end
            end
        end
    
        

        $fclose(fd);

        // ----------------------------------------------------
        // Final result
        // ----------------------------------------------------
        $display("");
        $display("==========================================");
        $display("Random FFT Verification");
        $display("Tests executed : %0d", test_num);
        $display("Errors          : %0d", errors);

        if (errors == 0)
            $display("ALL RANDOM TESTS PASSED");
        else
            $display("RANDOM FFT VERIFICATION FAILED");

        $display("==========================================");

        $finish;
    end

endmodule