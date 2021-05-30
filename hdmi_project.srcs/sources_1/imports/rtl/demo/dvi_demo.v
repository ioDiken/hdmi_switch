`timescale 1 ns / 1 ps

//`define DIRECTPASS

module dvi_demo (
  input wire        RSTN,    //The reset button
  input wire        clk100,      //100 MHz osicallator
  input wire [3:0]  HDMI_RX0_DATA_P,
  input wire [3:0]  HDMI_RX0_DATA_N,
  input wire [3:0]  RX1_TMDS,
  input wire [3:0]  RX1_TMDSB,

  input  wire SW, // what is

  // These will be used to show status data using the multicolored LED's
  // on the SoC
  // output wire [7:0] LED
);

  ////////////////////////////////////////////////////
  // 25 MHz and switch debouncers
  ////////////////////////////////////////////////////
  wire clk25, clk25m;

  BUFIO2 #(.DIVIDE_BYPASS("FALSE"), .DIVIDE(5))
  sysclk_div (.DIVCLK(clk25m), .IOCLK(), .SERDESSTROBE(), .I(clk100));

  BUFG clk25_buf (.I(clk25m), .O(clk25));

  wire sws;

  synchro #(.INITIALIZE("LOGIC0"))
  synchro_sws_0 (.async(SW),.sync(sws),.clk(clk25));

  // wire select = sws;
  wire select = 1'b0;

  reg select_q = 1'b0;
  reg switch = 1'b0;
  always @ (posedge clk25) begin
    select_q <= select;

    switch = select ^ select_q;
  end

  /////////////////////////
  //
  // Input Port 0
  //
  /////////////////////////
  wire rx0_pclk, rx0_pclkx2, rx0_pclkx10, rx0_pllclk0;
  wire rx0_plllckd;
  wire rx0_reset;
  wire rx0_serdesstrobe;
  wire rx0_hsync;          // hsync data
  wire rx0_vsync;          // vsync data
  wire rx0_de;             // data enable
  wire rx0_psalgnerr;      // channel phase alignment error
  wire [7:0] rx0_red;      // pixel data out
  wire [7:0] rx0_green;    // pixel data out
  wire [7:0] rx0_blue;     // pixel data out
  wire [29:0] rx0_sdata;
  wire rx0_blue_vld;
  wire rx0_green_vld;
  wire rx0_red_vld;
  wire rx0_blue_rdy;
  wire rx0_green_rdy;
  wire rx0_red_rdy;

  dvi_decoder dvi_rx0 (
    //These are input ports
    .tmdsclk_p   (HDMI_RX0_DATA_P[3]),
    .tmdsclk_n   (HDMI_RX0_DATA_N[3]),
    .blue_p      (HDMI_RX0_DATA_P[0]),
    .green_p     (HDMI_RX0_DATA_P[1]),
    .red_p       (HDMI_RX0_DATA_P[2]),
    .blue_n      (HDMI_RX0_DATA_N[0]),
    .green_n     (HDMI_RX0_DATA_N[1]),
    .red_n       (HDMI_RX0_DATA_N[2]),
    .exrst       (~RSTN),

    //These are output ports
    .reset       (rx0_reset),
    .pclk        (rx0_pclk),
    .pclkx2      (rx0_pclkx2),
    .pclkx10     (rx0_pclkx10),
    .pllclk0     (rx0_pllclk0), // PLL x10 output
    .pllclk1     (rx0_pllclk1), // PLL x1 output
    .pllclk2     (rx0_pllclk2), // PLL x2 output
    .pll_lckd    (rx0_plllckd),
    .tmdsclk     (rx0_tmdsclk),
    .serdesstrobe(rx0_serdesstrobe),
    .hsync       (rx0_hsync),
    .vsync       (rx0_vsync),
    .de          (rx0_de),

    .blue_vld    (rx0_blue_vld),
    .green_vld   (rx0_green_vld),
    .red_vld     (rx0_red_vld),
    .blue_rdy    (rx0_blue_rdy),
    .green_rdy   (rx0_green_rdy),
    .red_rdy     (rx0_red_rdy),

    .psalgnerr   (rx0_psalgnerr),

    .sdout       (rx0_sdata),
    .red         (rx0_red),
    .green       (rx0_green),
    .blue        (rx0_blue));

  /////////////////////////
  //
  // Input Port 1
  //
  /////////////////////////
  wire rx1_pclk, rx1_pclkx2, rx1_pclkx10, rx1_pllclk0;
  wire rx1_plllckd;
  wire rx1_reset;
  wire rx1_serdesstrobe;
  wire rx1_hsync;          // hsync data
  wire rx1_vsync;          // vsync data
  wire rx1_de;             // data enable
  wire rx1_psalgnerr;      // channel phase alignment error
  wire [7:0] rx1_red;      // pixel data out
  wire [7:0] rx1_green;    // pixel data out
  wire [7:0] rx1_blue;     // pixel data out
  wire [29:0] rx1_sdata;
  wire rx1_blue_vld;
  wire rx1_green_vld;
  wire rx1_red_vld;
  wire rx1_blue_rdy;
  wire rx1_green_rdy;
  wire rx1_red_rdy;

  dvi_decoder dvi_rx1 (
    //These are input ports
    .tmdsclk_p   (RX1_TMDS[3]),
    .tmdsclk_n   (RX1_TMDSB[3]),
    .blue_p      (RX1_TMDS[0]),
    .green_p     (RX1_TMDS[1]),
    .red_p       (RX1_TMDS[2]),
    .blue_n      (RX1_TMDSB[0]),
    .green_n     (RX1_TMDSB[1]),
    .red_n       (RX1_TMDSB[2]),
    .exrst       (~RSTN),

    //These are output ports
    .reset       (rx1_reset),
    .pclk        (rx1_pclk),
    .pclkx2      (rx1_pclkx2),
    .pclkx10     (rx1_pclkx10),
    .pllclk0     (rx1_pllclk0), // PLL x10 outptu
    .pllclk1     (rx1_pllclk1), // PLL x1 output
    .pllclk2     (rx1_pllclk2), // PLL x2 output
    .pll_lckd    (rx1_plllckd),
    .tmdsclk     (rx1_tmdsclk),
    .serdesstrobe(rx1_serdesstrobe),
    .hsync       (rx1_hsync),
    .vsync       (rx1_vsync),
    .de          (rx1_de),

    .blue_vld    (rx1_blue_vld),
    .green_vld   (rx1_green_vld),
    .red_vld     (rx1_red_vld),
    .blue_rdy    (rx1_blue_rdy),
    .green_rdy   (rx1_green_rdy),
    .red_rdy     (rx1_red_rdy),

    .psalgnerr   (rx1_psalgnerr),

    .sdout       (rx1_sdata),
    .red         (rx1_red),
    .green       (rx1_green),
    .blue        (rx1_blue)); 

  /////////////////
  //
  // Output Port 0
  //
  /////////////////
  wire         tx0_de;
  wire         tx0_pclk;
  wire         tx0_pclkx2;
  wire         tx0_pclkx10;
  wire         tx0_serdesstrobe;
  wire         tx0_reset;
  wire [7:0]   tx0_blue;
  wire [7:0]   tx0_green;
  wire [7:0]   tx0_red;
  wire         tx0_hsync;
  wire         tx0_vsync;
  wire [1:0]   tx0_ctrl;
  wire         tx0_pll_reset;

  assign tx0_de           = (select) ? rx1_de    : rx0_de;
  assign tx0_blue         = (select) ? rx1_blue  : rx0_blue;
  assign tx0_green        = (select) ? rx1_green : rx0_green;
  assign tx0_red          = (select) ? rx1_red   : rx0_red;
  assign tx0_hsync        = (select) ? rx1_hsync : rx0_hsync;
  assign tx0_vsync        = (select) ? rx1_vsync : rx0_vsync;
  assign tx0_ctrl = {tx0_hsync, tx0_vsync};
  assign tx0_pll_reset    =  switch | ((select) ? rx1_reset : rx0_reset);

  //////////////////////////////////////////////////////////////////
  // Instantiate a dedicate PLL for output port
  //////////////////////////////////////////////////////////////////
  wire tx0_clkfbout, tx0_clkfbin, tx0_plllckd;
  wire tx0_pllclk0, tx0_pllclk2;

  PLL_BASE # (
    .CLKIN_PERIOD(10),
    .CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("SOURCE_SYNCHRONOUS")
  ) PLL_OSERDES_0 (
    .CLKFBOUT(tx0_clkfbout),
    .CLKOUT0(tx0_pllclk0),
    .CLKOUT1(),
    .CLKOUT2(tx0_pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(tx0_plllckd),
    .CLKFBIN(tx0_clkfbin),
    .CLKIN(tx0_pclk),
    .RST(tx0_pll_reset)
  );

  //
  // This BUFGMUX directly selects between two RX PLL pclk outputs
  // This way we have a matched skew between the RX pclk clocks and the TX pclk
  //
  BUFGMUX tx0_bufg_pclk (.S(select), .I1(rx1_pllclk1), .I0(rx0_pllclk1), .O(tx0_pclk));

  //
  // This BUFG is needed in order to deskew between PLL clkin and clkout
  // So the tx0 pclkx2 and pclkx10 will have the same phase as the pclk input
  //
  BUFG tx0_clkfb_buf (.I(tx0_clkfbout), .O(tx0_clkfbin));

  //
  // regenerate pclkx2 for TX
  //
  BUFG tx0_pclkx2_buf (.I(tx0_pllclk2), .O(tx0_pclkx2));

  //
  // regenerate pclkx10 for TX
  //
  wire tx0_bufpll_lock;
  BUFPLL #(.DIVIDE(5)) tx0_ioclk_buf (.PLLIN(tx0_pllclk0), .GCLK(tx0_pclkx2), .LOCKED(tx0_plllckd),
           .IOCLK(tx0_pclkx10), .SERDESSTROBE(tx0_serdesstrobe), .LOCK(tx0_bufpll_lock));

  assign tx0_reset = ~tx0_bufpll_lock;

  pmod_headers tx_pmod (
    .i_red(tx0_red),
    .i_green(tx0_green),
    .i_blue(tx0_blue),
    .i_ctrl(tx0_ctrl),
    .i_clk(tx0_pclk),
    .i_de(tx0_de),

    .o_pm_r(PM_DVI_R),
    .o_pm_g(PM_DVI_G),
    .o_pm_b(PM_DVI_B),
    .o_pm_clk(PM_DVI_CLK),
    .o_pm_hs(PM_DVI_HS),
    .o_pm_vs(PM_DVI_VS),
    .o_pm_de(PM_DVI_DE)
  );

  //////////////////////////////////////
  // Status LED
  //////////////////////////////////////
  // assign LED = {rx0_red_rdy, rx0_green_rdy, rx0_blue_rdy, rx1_red_rdy, rx1_green_rdy, rx1_blue_rdy,
  //               rx0_de, rx1_de};

endmodule
