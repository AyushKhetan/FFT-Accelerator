module fft8_top(
    input logic clk,
    input logic rst_n,

    input logic in_valid,
    input logic signed [15:0] in_real [0:7],
    input logic signed [15:0] in_imag [0:7],

    output logic out_valid,
    output logic signed [18:0] out_real [0:7],
    output logic signed [18:0] out_imag [0:7]
);


logic valid_stage1;
logic valid_stage2;
logic valid_stage3;

logic signed [15:0] stage0_real [0:7];
logic signed [15:0] stage0_imag [0:7];

logic signed [16:0] stage1_real [0:7];
logic signed [16:0] stage1_imag [0:7];
/*logic signed [16:0] stage1_real_reg [0:7];
logic signed [16:0] stage1_imag_reg [0:7];*/

logic signed [17:0] stage2_real [0:7];
logic signed [17:0] stage2_imag [0:7];
/*logic signed [17:0] stage2_real_reg [0:7];
logic signed [17:0] stage2_imag_reg [0:7];*/

logic signed [18:0] out_real_wire [0:7];
logic signed [18:0] out_imag_wire [0:7];


integer  i;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       for (i = 0; i < 8; i = i + 1) begin
            /*stage1_real_reg[i] <= '0;
            stage1_imag_reg[i] <= '0;
            stage2_real_reg[i] <= '0;
            stage2_imag_reg[i] <= '0;*/
            out_real[i]        <= '0;
            out_imag[i]        <= '0;
       end

       valid_stage1       <= '0;
       valid_stage2       <= '0;
       valid_stage3       <= '0;
       out_valid          <= '0;
    end
    else begin
        for (i = 0; i < 8; i = i + 1) begin
            out_real[i] <= out_real_wire[i];
            out_imag[i] <= out_imag_wire[i];
        end

        valid_stage1 <= in_valid;
        valid_stage2 <= valid_stage1;
        valid_stage3 <= valid_stage2;
        out_valid    <= valid_stage3;
    end
end
        

assign stage0_real[0] = in_real[0];
assign stage0_real[1] = in_real[4];
assign stage0_real[2] = in_real[2];
assign stage0_real[3] = in_real[6];
assign stage0_real[4] = in_real[1];
assign stage0_real[5] = in_real[5];
assign stage0_real[6] = in_real[3];
assign stage0_real[7] = in_real[7];

assign stage0_imag[0] = in_imag[0];
assign stage0_imag[1] = in_imag[4];
assign stage0_imag[2] = in_imag[2];
assign stage0_imag[3] = in_imag[6];
assign stage0_imag[4] = in_imag[1];
assign stage0_imag[5] = in_imag[5];
assign stage0_imag[6] = in_imag[3];
assign stage0_imag[7] = in_imag[7];


fft8_butterfly #(
    .IN_WIDTH(16),
    .FRAC_BITS(14)
) butterfly00(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage0_real[0]),
    .A_imag(stage0_imag[0]),
    .B_real(stage0_real[1]),
    .B_imag(stage0_imag[1]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(stage1_real[0]),
    .Y0_imag(stage1_imag[0]),
    .Y1_real(stage1_real[1]),
    .Y1_imag(stage1_imag[1])
);

fft8_butterfly #(
    .IN_WIDTH(16),
    .FRAC_BITS(14)
) butterfly01(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage0_real[2]),
    .A_imag(stage0_imag[2]),
    .B_real(stage0_real[3]),
    .B_imag(stage0_imag[3]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(stage1_real[2]),
    .Y0_imag(stage1_imag[2]),
    .Y1_real(stage1_real[3]),
    .Y1_imag(stage1_imag[3])
);

fft8_butterfly #(
    .IN_WIDTH(16),
    .FRAC_BITS(14)
) butterfly02(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage0_real[4]),
    .A_imag(stage0_imag[4]),
    .B_real(stage0_real[5]),
    .B_imag(stage0_imag[5]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(stage1_real[4]),
    .Y0_imag(stage1_imag[4]),
    .Y1_real(stage1_real[5]),
    .Y1_imag(stage1_imag[5])
);

fft8_butterfly #(
    .IN_WIDTH(16),
    .FRAC_BITS(14)
) butterfly03(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage0_real[6]),
    .A_imag(stage0_imag[6]),
    .B_real(stage0_real[7]),
    .B_imag(stage0_imag[7]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(stage1_real[6]),
    .Y0_imag(stage1_imag[6]),
    .Y1_real(stage1_real[7]),
    .Y1_imag(stage1_imag[7])
);


fft8_butterfly #(
    .IN_WIDTH(17),
    .FRAC_BITS(14)
) butterfly10(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage1_real[0]),
    .A_imag(stage1_imag[0]),
    .B_real(stage1_real[2]),
    .B_imag(stage1_imag[2]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(stage2_real[0]),
    .Y0_imag(stage2_imag[0]),
    .Y1_real(stage2_real[2]),
    .Y1_imag(stage2_imag[2])
);

fft8_butterfly #(
    .IN_WIDTH(17),
    .FRAC_BITS(14)
) butterfly11(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage1_real[1]),
    .A_imag(stage1_imag[1]),
    .B_real(stage1_real[3]),
    .B_imag(stage1_imag[3]),
    .W_real(16'sd0), // W = -j
    .W_imag(-16'sd16384),
    .Y0_real(stage2_real[1]),
    .Y0_imag(stage2_imag[1]),
    .Y1_real(stage2_real[3]),
    .Y1_imag(stage2_imag[3])
);

fft8_butterfly #(
    .IN_WIDTH(17),
    .FRAC_BITS(14)
) butterfly12(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage1_real[4]),
    .A_imag(stage1_imag[4]),
    .B_real(stage1_real[6]),
    .B_imag(stage1_imag[6]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(stage2_real[4]),
    .Y0_imag(stage2_imag[4]),
    .Y1_real(stage2_real[6]),
    .Y1_imag(stage2_imag[6])
);

fft8_butterfly #(
    .IN_WIDTH(17),
    .FRAC_BITS(14)
) butterfly13(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage1_real[5]),
    .A_imag(stage1_imag[5]),
    .B_real(stage1_real[7]),
    .B_imag(stage1_imag[7]),
    .W_real(-16'sd0), // W = -j
    .W_imag(-16'sd16384),
    .Y0_real(stage2_real[5]),
    .Y0_imag(stage2_imag[5]),
    .Y1_real(stage2_real[7]),
    .Y1_imag(stage2_imag[7])
);

fft8_butterfly #(
    .IN_WIDTH(18),
    .FRAC_BITS(14)
) butterfly20(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage2_real[0]),
    .A_imag(stage2_imag[0]),
    .B_real(stage2_real[4]),
    .B_imag(stage2_imag[4]),
    .W_real(16'sd16384), // W = 1
    .W_imag(16'sd0),
    .Y0_real(out_real_wire[0]),
    .Y0_imag(out_imag_wire[0]),
    .Y1_real(out_real_wire[4]),
    .Y1_imag(out_imag_wire[4])
);

fft8_butterfly #(
    .IN_WIDTH(18),
    .FRAC_BITS(14)
) butterfly21(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage2_real[1]),
    .A_imag(stage2_imag[1]),
    .B_real(stage2_real[5]),
    .B_imag(stage2_imag[5]),
    .W_real(16'sd11585), // W = exp(-j*pi/4)
    .W_imag(-16'sd11585),
    .Y0_real(out_real_wire[1]),
    .Y0_imag(out_imag_wire[1]),
    .Y1_real(out_real_wire[5]),
    .Y1_imag(out_imag_wire[5])
);

fft8_butterfly #(
    .IN_WIDTH(18),
    .FRAC_BITS(14)
) butterfly22(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage2_real[2]),
    .A_imag(stage2_imag[2]),
    .B_real(stage2_real[6]),
    .B_imag(stage2_imag[6]),
    .W_real(16'sd0), // W = -j
    .W_imag(-16'sd16384),
    .Y0_real(out_real_wire[2]),
    .Y0_imag(out_imag_wire[2]),
    .Y1_real(out_real_wire[6]),
    .Y1_imag(out_imag_wire[6])
);

fft8_butterfly #(
    .IN_WIDTH(18),
    .FRAC_BITS(14)
) butterfly23(
    .clk(clk),
    .rst_n(rst_n),
    .A_real(stage2_real[3]),
    .A_imag(stage2_imag[3]),
    .B_real(stage2_real[7]),
    .B_imag(stage2_imag[7]),
    .W_real(-16'sd11585), // W = exp(-j*3*pi/4)
    .W_imag(-16'sd11585),
    .Y0_real(out_real_wire[3]),
    .Y0_imag(out_imag_wire[3]),
    .Y1_real(out_real_wire[7]),
    .Y1_imag(out_imag_wire[7])
);

endmodule