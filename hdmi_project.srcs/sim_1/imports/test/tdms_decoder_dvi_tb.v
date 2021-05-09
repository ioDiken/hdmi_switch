`timescale 1ns / 1ps
`default_nettype none

// assert will display a failure if the values are unequal
`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: sig(%d) != val(%d)", signal, value); \
        end


module tmds_decode_dvi_tb();

    // control data encoding
    parameter CTRL0 =10'b1101010100;
    parameter CTRL1 =10'b0010101011;
    parameter CTRL2 =10'b0101010100;
    parameter CTRL3 =10'b1010101011;

    reg rst;
    reg clk;

    reg [7:0] data;
    reg [1:0] ctrl;
    reg de;
    reg [9:0] i_tmds;
    reg [8:0] cycle;

    initial begin
        $display("\t               1s    B   O");
        clk = 1;
        rst = 1;
        de = 0;
        ctrl = 2'b00;

        #10
        rst = 0;

        #10
        de = 1;
    end

//    tmds_encoder_dvi tmds_test (
//        .i_clk(clk),
//        .i_rst(rst),
//        .i_data(data),
//        .i_ctrl(ctrl),
//        .i_de(de),
//        .o_tmds(tmds)
//    );

    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            cycle <= 0;
            data <= 0;
        end
        else
        begin
            cycle <= cycle + 1;
            data <= cycle[7:0];
        end
    end

    always
       #5 clk = ~clk;

endmodule
