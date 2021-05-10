`timescale 1ns / 1ps
`default_nettype none

module tmds_decoder_dvi (
    input wire i_clk,                // clock 
    input wire i_rst,                // reset (active high)
    input wire [9:0] i_tmds,         // input TMDS data
    output reg  o_de,           // display enable (active high)
    output reg [7:0] o_data,    // decoded TMDS data
    output reg [1:0] o_ctrl     // decoded control data
    );
  
    // control data encoding
    parameter CTRL0 =10'b1101010100;
    parameter CTRL1 =10'b0010101011;
    parameter CTRL2 =10'b0101010100;
    parameter CTRL3 =10'b1010101011;

    wire [7:0] data;
    assign data = (i_tmds[9]) ? ~i_tmds[7:0] : i_tmds[7:0]; 

    always @ (i_clk)
    begin
        case (i_tmds)
            CTRL0: begin
                o_ctrl[0] <= 1'b0;
                o_ctrl[1]<= 1'b0;
                o_de <= 1'b0;
            end

            CTRL1: begin
                o_ctrl[0] <= 1'b1;
                o_ctrl[1] <= 1'b0;
                o_de <= 1'b0;
            end
               
            CTRL2: begin
                o_ctrl[0] <= 1'b0;
                o_ctrl[1] <= 1'b1;
                o_de <= 1'b0;
            end

            CTRL3: begin
                o_ctrl[0] <= 1'b1;
                o_ctrl[1] <= 1'b1;
                o_de <= 1'b0;
            end

            default: begin
                o_data[0] <= data[0];
                o_data[1] <= (i_tmds[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
                o_data[2] <= (i_tmds[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
                o_data[3] <= (i_tmds[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
                o_data[4] <= (i_tmds[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
                o_data[5] <= (i_tmds[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
                o_data[6] <= (i_tmds[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
                o_data[7] <= (i_tmds[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);

                o_de <= 1'b1;
            end  
        endcase
    end

endmodule
