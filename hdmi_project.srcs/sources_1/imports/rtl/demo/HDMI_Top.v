module HDMI_Top(
    input RSTN,
    input CLK,
    // output HDMIR_TXEN,
    // output HDMIT_SCL,
    output HDMIR_HPA,
    input HDMIR_SCL,
    inout HDMIR_SDA,
    input HDMIR_CLK_P,
    input HDMIR_CLK_N,
    input [2:0] HDMIR_DATA_P,
    input [2:0] HDMIR_DATA_N,
    /***********************/
    // inout HDMIT_SDA,
    // input HDMIT_HPD,

    // PMOD Headers
    output wire [3:0] PM_DVI_R,
    output wire [3:0] PM_DVI_G,
    output wire [3:0] PM_DVI_B,
    output wire PM_DVI_CLK,
    output wire PM_DVI_HS,
    output wire PM_DVI_VS,
    output wire PM_DVI_DE

    // output HDMIT_CLK_P,
    // output HDMIT_CLK_N,
    // output [2:0] HDMIT_DATA_P,
    // output [2:0] HDMIT_DATA_N
    );

wire HDMI_CLK;
wire [2:0] HDMI_DATA;

wire [7:0] red;
wire [7:0] green;
wire [7:0] blue;
wire [1:0] control;
wire display_en;

// Whenever a sink is ready and wishes to announce its presence, it connects the 5V0 supply pin to the HPD pin. On
// the Nexys Video, this is done by driving the HPA (Hot Plug Assert) signal high. Note: this should only be done
// after a DDC channel slave has been implemented in the FPGA and is ready to transmit display data.
// FPGA lets the HDMI source (e.g., a PC) connected to its sink port know its presence by setting HPA signal to '1'.
// A monitor connected to the source port sets HPD signal to '0'.
assign HDMIR_HPA = 1'b1;
// assign HDMIR_HPA = ~HDMIT_HPD;

// A pull-down resistor on the TXEN signal makes sure the sink buffer's transmitter facing the FPGA is disabled by default.
// An FPGA design using the sink port needs to actively drive this pin high for the buffer to pass data through.
// assign HDMIR_TXEN = 1'b1;

// The Display Data Channel, or DDC, is a collection of protocols that enable communication between the display
// (sink) and graphics adapter (source). The DDC2B variant is based on I2C, the bus master being the source and the
// bus slave the sink. When a source detects high level on the HPD pin, it queries the sink over the DDC bus for video
// capabilities. It determines whether the sink is DVI or HDMI-capable and what resolutions are supported. Only
// afterwards will video transmission begin. Refer to VESA E-DDC specifications for more information.
edid_rom edid_rom_rx0 (.clk(CLK), .sclk_raw(HDMIR_SCL), .sdat_raw(HDMIR_SDA));

wire rst;
wire px5_clk;
wire px15_clk;
wire pll_lckd;
wire hsync;
wire vsync;
wire blue_vld;
wire green_vld;
wire red_vld;
wire blue_rdy;
wire green_rdy;
wire red_rdy;
wire psalgnerr;
wire [29:0] sdout;
wire encoding;
wire hdcp_ena;
wire [3:0] red_di;
wire [3:0] green_di;
wire [3:0] blue_di;
wire data_gb;
wire [3:0] ctl_code;
wire cv;
wire line_end;
wire [31:0] green_eye;
wire [31:0] blue_eye;
wire [31:0] red_eye;
wire [31:0] green_debug;
wire [31:0] blue_debug;
wire [31:0] red_debug;
wire hdmi_clk;

assign control = ctl_code[1:0];

dvi_decoder dvi_dec (
    .rx_clk(HDMI_CLK),
    .blue_p(HDMIR_DATA_P[0]),
    .blue_n(HDMIR_DATA_N[0]),
    .green_p(HDMIR_DATA_P[1]),
    .green_n(HDMIR_DATA_N[1]),
    .red_p(HDMIR_DATA_P[2]),
    .red_n(HDMIR_DATA_N[2]),

    .ex_reset(RSTN),

    .mhz200_clk(CLK), //? is it 200mhz? Guess we'll find out?
    .reset(rst), // whats the point of this?
    .p_clk(hdmi_clk),
    // .p_clk(HDMI_CLK),

    // wadu?
    .px5_clk(px5_clk),
    .px1p25_dbg_clk(px15_clk),

    // pll locked?
    .pll_lckd(pll_lckd),

    // sync bullshit?
    .hsync(hsync),
    .vsync(vsync),
    .de(display_en),

    .blue_vld(blue_vld),
    .green_vld(green_vld),
    .red_vld(red_vld),
    .blue_rdy(blue_rdy),
    .green_rdy(green_rdy),
    .red_rdy(red_rdy),

    .psalgnerr(psalgnerr),

    .sdout(sdout),
    .red(red),
    .green(green),
    .blue(blue),

    .encoding(encoding),
    .hdcp_ena(hdcp_ena),
    .red_di(red_di),
    .green_di(green_di),
    .blue_di(blue_di),
    .data_gb(data_gb),
    .ctl_code(ctl_code),
    .cv(cv),
    .line_end(line_end),
    
    .green_eye(green_eye),
    .blue_eye(blue_eye),
    .red_eye(red_eye),
    .green_debug(green_debug),
    .blue_debug(blue_debug),
    .red_debug(red_debug)
);
    
// IBUFDS: Differential Input Buffer
IBUFDS #(
    .DIFF_TERM("FALSE"), // Differential Termination
    .IOSTANDARD("DEFAULT") // Specify the input I/O standard
) IBUFDS_hdmir_clk (
    .O(HDMI_CLK), // Buffer output
    .I(HDMIR_CLK_P), // Diff_p buffer input (connect directly to top-level port)
    .IB(HDMIR_CLK_N) // Diff_n buffer input (connect directly to top-level port)
);

// OBUFDS #(
//     .IOSTANDARD("DEFAULT") // Specify the output I/O standard
// ) OBUFDS_hdmit_clk (
//     .O(HDMIT_CLK_P), // Diff_p output (connect directly to top-level port)
//     .OB(HDMIT_CLK_N), // Diff_n output (connect directly to top-level port)
//     .I(HDMI_CLK) // Buffer input
// );

// IBUFDS: Differential Input Buffer
// IBUFDS #(
//     .DIFF_TERM("FALSE"), // Differential Termination
//     .IOSTANDARD("DEFAULT") // Specify the input I/O standard
// ) IBUFDS_hdmir_data [2:0] (
//     .O(HDMI_DATA), // Buffer output
//     .I(HDMIR_DATA_P), // Diff_p buffer input (connect directly to top-level port)
//     .IB(HDMIR_DATA_N) // Diff_n buffer input (connect directly to top-level port)
// );

pmod_headers pmh (
    .i_red(red),
    .i_green(green),
    .i_blue(blue),
    .i_ctrl(control),
    .i_de(display_en),
    .o_pm_r(PM_DVI_R),
    .o_pm_g(PM_DVI_G),
    .o_pm_b(PM_DVI_B),
    .o_pm_clk(PM_DVI_CLK),
    .o_pm_hs(PM_DVI_HS),
    .o_pm_vs(PM_DVI_VS),
    .o_pm_de(PM_DVI_DE)
);

// OBUFDS #(
//     .IOSTANDARD("DEFAULT") // Specify the output I/O standard
// ) OBUFDS_hdmit_data [2:0] (
//     .O(HDMIT_DATA_P), // Diff_p output (connect directly to top-level port)
//     .OB(HDMIT_DATA_N), // Diff_n output (connect directly to top-level port)
//     .I(HDMI_DATA) // Buffer input
//); 
endmodule