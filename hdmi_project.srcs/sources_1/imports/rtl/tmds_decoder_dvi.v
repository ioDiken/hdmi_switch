`timescale 1ns / 1ps
`default_nettype none

module tmds_decoder_dvi (
    input i_clk,                // clock 
    input i_rst,                // reset (active high)
    input [9:0] i_data,         // input data
    output reg  i_de,           // display enable (active high)
    output reg [7:0] o_tmsd,    // decoded TMDS data
    output reg [1:0] o_ctrl     // decoded control data
    );
  
    // control data encoding
    parameter CTRL0 =10'b1101010100;
    parameter CTRL1 =10'b0010101011;
    parameter CTRL2 =10'b0101010100;
    parameter CTRL3 =10'b1010101011;

    wire [7:0] data;
    assign data = (i_data[9]) ? ~i_data[7:0] : i_data[7:0]; 

    always @ (i_clk)
    begin
        case (i_data)
            CTRL0: begin
                ctrl[0] <= 1'b0;
                ctrl[1]<= 1'b0;
                i_de <= 1'b0;
            end

            CTRL1: begin
                ctrl[0] <= 1'b1;
                ctrl[1] <= 1'b0;
                i_de <= 1'b0;
            end
               
            CTRL2: begin
                ctrl[0] <= 1'b0;
                ctrl[1] <= 1'b1;
                i_de <= 1'b0;
            end

            CTRL3: begin
                ctrl[0] <= 1'b1;
                ctrl[1] <= 1'b1;
                i_de <= 1'b0;
            end

            default: begin
                o_tmsd[0] <= data[0];
                o_tmsd[1] <= (i_data[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
                o_tmsd[2] <= (i_data[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
                o_tmsd[3] <= (i_data[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
                o_tmsd[4] <= (i_data[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
                o_tmsd[5] <= (i_data[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
                o_tmsd[6] <= (i_data[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
                o_tmsd[7] <= (i_data[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);

                i_de <= 1'b1;
            end  
        endcase
    end

endmodule
