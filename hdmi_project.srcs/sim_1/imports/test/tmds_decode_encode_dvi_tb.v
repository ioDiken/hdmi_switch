`timescale 1ns / 1ps
`default_nettype none

`include "test_macros.vh"

// Display DVI TMDS Decoder + Encoder Test Bench

module tmds_encode_decode_dvi_tb();

    // common module
    reg rst;
    reg clk;
    wire [9:0] tmds;

    // encoder
    reg [7:0] i_data;
    reg [1:0] i_ctrl;
    reg i_de;

    // decoder
    wire [7:0] o_data;
    wire o_de;
    wire [1:0] o_ctrl;

    // test
    reg [8:0] cycle;
    reg [7:0] prev_data;
    reg [9:0] prev_tmds;
    reg [1:0] prev_ctrl;

    initial begin
        cycle = 0;
        clk = 0;
        i_de = 0;

        // start control tests
        #10
        i_ctrl = 2'b00;
        #20
        i_ctrl = 2'b01;
        #20
        i_ctrl = 2'b10;
        #20
        i_ctrl = 2'b11;
        #20

        // start data tests
        rst = 1;
        #10
        rst = 0;
        #10
        i_de = 1;
    end

    tmds_encoder_dvi tmds_test_e (
        .i_clk(clk),
        .i_rst(rst),
        .i_data(i_data),
        .i_ctrl(i_ctrl),
        .i_de(i_de),
        .o_tmds(tmds)
    );

    tmds_decoder_dvi tmds_test_d (
        .i_clk(clk),
        .i_rst(rst),
        .i_tmds(tmds),
        .o_de(o_de),
        .o_data(o_data),
        .o_ctrl(o_ctrl)
    );

    // control data expects
    parameter CTRL0 =10'b1101010100;
    parameter CTRL1 =10'b0010101011;
    parameter CTRL2 =10'b0101010100;
    parameter CTRL3 =10'b1010101011;

    always @ (posedge clk or posedge rst)
    begin
        // perform data tests
        if (i_de == 1)
        begin
            if (rst)
            begin
                cycle <= 0;
                i_data <= 0;
            end
            else
            begin
                // compare previous i_data with current o_data
                // skip 1st cycle as o_data is X
                if (cycle != 0)
                begin
                    prev_data <= i_data;
                    `ASSERT_EQ("cmp data", prev_data, o_data)
                end

                cycle <= cycle + 1;
                i_data <= cycle[7:0];
            end
        end

        // else perform ctrl tests
        else
        begin
            cycle <= cycle + 1;

            // skip even iterations
            if ((cycle % 2) == 0)
            begin
                case (i_ctrl)
                    2'b00:
                    begin
                        $display("ctrl0");
                        `ASSERT_EQ("ctrl0", tmds, CTRL0)
                    end

                    2'b01:
                    begin
                        $display("ctrl1");
                        `ASSERT_EQ("ctrl1", tmds, CTRL1)
                    end

                    2'b10:
                    begin
                        $display("ctrl2");
                        `ASSERT_EQ("ctrl2", tmds, CTRL2)
                    end

                    2'b11:
                    begin
                        $display("ctrl3");
                        `ASSERT_EQ("ctrl3", tmds, CTRL3)
                    end
                endcase
            end
        end
    end

    always
       #5 clk = ~clk;


endmodule
