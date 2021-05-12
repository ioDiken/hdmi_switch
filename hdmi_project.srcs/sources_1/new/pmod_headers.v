`timescale 1ns / 1ps
module pmod_headers(
    // JA PMOD header
    input wire R3,
    input wire R1,
    input wire G3,
    input wire G1,
    input wire R2,
    input wire R0,
    input wire G2,
    input wire G0,
    //JB PMOD header
    input wire B3,
    input wire CK,
    input wire B0,
    input wire HS,
    input wire B2,
    input wire B1,
    input wire DE,
    input wire VS,
    //Outputs
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
    output wire [1:0] ctrl,
    output wire clk,
    output wire de
    );
    assign red = {4'b0000, R3, R2, R1, R0};
    assign green = {4'b0000, G3, G2, G1, G0};
    assign blue = {4'b0000, B3, B2, B1, B0};
    assign ctrl = {VS, HS};
    assign clk = CK;
    assign de = DE;
endmodule
