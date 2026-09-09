module fft8_butterfly_basic #(
    parameter int IN_WIDTH = 16,
    parameter int FRAC_BITS = 14
)(  
    input logic signed [IN_WIDTH-1:0] A_real,   //15:0
    input logic signed [IN_WIDTH-1:0] A_imag,
    input logic signed [IN_WIDTH-1:0] B_real,
    input logic signed [IN_WIDTH-1:0] B_imag,
    input logic signed [IN_WIDTH-1:0] W_real,
    input logic signed [IN_WIDTH-1:0] W_imag,

    output logic signed [IN_WIDTH:0] Y0_real,  //16:0
    output logic signed [IN_WIDTH:0] Y0_imag,
    output logic signed [IN_WIDTH:0] Y1_real,
    output logic signed [IN_WIDTH:0] Y1_imag
);

logic signed [(2*IN_WIDTH)-1:0] P1;     //31:0
logic signed [(2*IN_WIDTH)-1:0] P2;
logic signed [(2*IN_WIDTH)-1:0] P3;
logic signed [(2*IN_WIDTH)-1:0] P4;

logic signed [2*IN_WIDTH:0] T_real;     //32:0
logic signed [2*IN_WIDTH:0] T_imag;

assign P1 = B_real * W_real;
assign P2 = B_imag * W_imag;
assign P3 = B_real * W_imag;
assign P4 = B_imag * W_real;

assign T_real = P1 - P2;
assign T_imag = P3 + P4;

assign Y0_real = A_real + (T_real >>> FRAC_BITS); //18:0
assign Y0_imag = A_imag + (T_imag >>> FRAC_BITS);
assign Y1_real = A_real - (T_real >>> FRAC_BITS);
assign Y1_imag = A_imag - (T_imag >>> FRAC_BITS);

endmodule