module fft8_butterfly #(
    parameter int IN_WIDTH = 16,
    parameter int FRAC_BITS = 14
)(  
    input logic clk,
    input logic rst_n,
    input logic signed [IN_WIDTH-1:0] A_real,
    input logic signed [IN_WIDTH-1:0] A_imag,
    input logic signed [IN_WIDTH-1:0] B_real,
    input logic signed [IN_WIDTH-1:0] B_imag,
    input logic signed [IN_WIDTH-1:0] W_real,
    input logic signed [IN_WIDTH-1:0] W_imag,

    output logic signed [IN_WIDTH:0] Y0_real,
    output logic signed [IN_WIDTH:0] Y0_imag,
    output logic signed [IN_WIDTH:0] Y1_real,
    output logic signed [IN_WIDTH:0] Y1_imag
);

logic signed [IN_WIDTH-1:0] A_real_reg;
logic signed [IN_WIDTH-1:0] A_imag_reg;
logic signed [(2*IN_WIDTH)-1:0] P1;
logic signed [(2*IN_WIDTH)-1:0] P2;
logic signed [(2*IN_WIDTH)-1:0] P3;
logic signed [(2*IN_WIDTH)-1:0] P4;

logic signed [2*IN_WIDTH:0] T_real;
logic signed [2*IN_WIDTH:0] T_imag;
 

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        A_real_reg <= '0;
        A_imag_reg <= '0;
        P1 <= '0;
        P2 <= '0;
        P3 <= '0;
        P4 <= '0;
    end
    else begin
        A_real_reg <= A_real;
        A_imag_reg <= A_imag;
        P1 <= B_real * W_real;
        P2 <= B_imag * W_imag;
        P3 <= B_real * W_imag;
        P4 <= B_imag * W_real;
    end
end

assign T_real = P1 - P2;
assign T_imag = P3 + P4;

assign Y0_real = A_real_reg + (T_real >>> FRAC_BITS);
assign Y0_imag = A_imag_reg + (T_imag >>> FRAC_BITS);
assign Y1_real = A_real_reg - (T_real >>> FRAC_BITS);
assign Y1_imag = A_imag_reg - (T_imag >>> FRAC_BITS);

endmodule