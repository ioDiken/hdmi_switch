module HDMI_Top(
    input RSTN,
    input CLK,
    // output HDMIR_TXEN,
    output HDMIR_HPA,
    input HDMIT_HPD, 
    input HDMIR_SCL,
    inout HDMIR_SDA,
    // output HDMIT_SCL,
    inout HDMIT_SDA,
    input HDMIR_CLK_P,
    input HDMIR_CLK_N,
    input [2:0] HDMIR_DATA_P,
    input [2:0] HDMIR_DATA_N,
    output HDMIT_CLK_P,
    output HDMIT_CLK_N,
    output [2:0] HDMIT_DATA_P,
    output [2:0] HDMIT_DATA_N
    );

wire HDMI_CLK;
wire [2:0] HDMI_DATA;

// Whenever a sink is ready and wishes to announce its presence, it connects the 5V0 supply pin to the HPD pin. On
// the Nexys Video, this is done by driving the HPA (Hot Plug Assert) signal high. Note: this should only be done
// after a DDC channel slave has been implemented in the FPGA and is ready to transmit display data.
// FPGA lets the HDMI source (e.g., a PC) connected to its sink port know its presence by setting HPA signal to '1'.
// A monitor connected to the source port sets HPD signal to '0'.
// assign HDMIR_HPA = 1'b1;
assign HDMIR_HPA = ~HDMIT_HPD;

// A pull-down resistor on the TXEN signal makes sure the sink buffer's transmitter facing the FPGA is disabled by default.
// An FPGA design using the sink port needs to actively drive this pin high for the buffer to pass data through.
// assign HDMIR_TXEN = 1'b1;

// The Display Data Channel, or DDC, is a collection of protocols that enable communication between the display
// (sink) and graphics adapter (source). The DDC2B variant is based on I2C, the bus master being the source and the
// bus slave the sink. When a source detects high level on the HPD pin, it queries the sink over the DDC bus for video
// capabilities. It determines whether the sink is DVI or HDMI-capable and what resolutions are supported. Only
// afterwards will video transmission begin. Refer to VESA E-DDC specifications for more information.
edid_rom edid_rom_rx0 (.clk(CLK), .sclk_raw(HDMIR_SCL), .sdat_raw(HDMIR_SDA));
    
// IBUFDS: Differential Input Buffer
IBUFDS #(
    .DIFF_TERM("FALSE"), // Differential Termination
    .IOSTANDARD("DEFAULT") // Specify the input I/O standard
) IBUFDS_hdmir_clk (
    .O(HDMI_CLK), // Buffer output
    .I(HDMIR_CLK_P), // Diff_p buffer input (connect directly to top-level port)
    .IB(HDMIR_CLK_N) // Diff_n buffer input (connect directly to top-level port)
);

OBUFDS #(
    .IOSTANDARD("DEFAULT") // Specify the output I/O standard
) OBUFDS_hdmit_clk (
    .O(HDMIT_CLK_P), // Diff_p output (connect directly to top-level port)
    .OB(HDMIT_CLK_N), // Diff_n output (connect directly to top-level port)
    .I(HDMI_CLK) // Buffer input
);

// IBUFDS: Differential Input Buffer
IBUFDS #(
    .DIFF_TERM("FALSE"), // Differential Termination
    .IOSTANDARD("DEFAULT") // Specify the input I/O standard
) IBUFDS_hdmir_data [2:0] (
    .O(HDMI_DATA), // Buffer output
    .I(HDMIR_DATA_P), // Diff_p buffer input (connect directly to top-level port)
    .IB(HDMIR_DATA_N) // Diff_n buffer input (connect directly to top-level port)
);

OBUFDS #(
    .IOSTANDARD("DEFAULT") // Specify the output I/O standard
) OBUFDS_hdmit_data [2:0] (
    .O(HDMIT_DATA_P), // Diff_p output (connect directly to top-level port)
    .OB(HDMIT_DATA_N), // Diff_n output (connect directly to top-level port)
    .I(HDMI_DATA) // Buffer input
); endmodule