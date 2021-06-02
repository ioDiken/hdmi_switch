#------------------------------------------------------------------------------------ 
# HDMI and clock Constraints for the Digilent Nexys Video FPGA development board.
#------------------------------------------------------------------------------------ 

##Clock Signal
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { clk100 }];
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 4} [get_ports clk100]
    
##HDMI in
create_clock -add -name hdmi_clk -period 6.7 -waveform {0 5} [get_ports hdmi_rx0_clk_p]

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx0_cec }]; #IO_L13N_T2_MRCC_35 Sch=HDMI_RX_CEC
set_property -dict { PACKAGE_PIN P19   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_clk_n }]; #IO_L13N_T2_MRCC_34 Sch=HDMI_RX_CLK_N
set_property -dict { PACKAGE_PIN N18   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_clk_p }]; #IO_L13P_T2_MRCC_34 Sch=HDMI_RX_CLK_P
set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_n[0] }]; #IO_L16N_T2_34 Sch=HDMI_RX_D0_N
set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_p[0] }]; #IO_L16P_T2_34 Sch=HDMI_RX_D0_P
set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_n[1] }]; #IO_L15N_T2_DQS_34 Sch=HDMI_RX_D1_N
set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_p[1] }]; #IO_L15P_T2_DQS_34 Sch=HDMI_RX_D1_P
set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_n[2] }]; #IO_L14N_T2_SRCC_34 Sch=HDMI_RX_D2_N
set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx0_p[2] }]; #IO_L14P_T2_SRCC_34 Sch=HDMI_RX_D2_P
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx0_hpa }]; #IO_25_34 Sch=HDMI_RX_HPD
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx0_scl }]; #IO_L11P_T1_SRCC_34 Sch=HDMI_RX_SCL
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx0_sda }]; #IO_L11N_T1_SRCC_34 Sch=HDMI_RX_SDA


set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx1_cec }]; #IO_L19N_T3_VREF_35 Sch=HDMI_TX_CEC
set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_clk_n }]; #IO_L11N_T1_SRCC_35 Sch=HDMI_TX_CLK_N
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_clk_p }]; #IO_L11P_T1_SRCC_35 Sch=HDMI_TX_CLK_P
set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_n[0] }]; #IO_L12N_T1_MRCC_35 Sch=HDMI_TX_D0_N
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_p[0] }]; #IO_L12P_T1_MRCC_35 Sch=HDMI_TX_D0_P
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_n[1] }]; #IO_L10N_T1_AD11N_35 Sch=HDMI_TX_D1_N
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_p[1] }]; #IO_L10P_T1_AD11P_35 Sch=HDMI_TX_D1_P
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_n[2] }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=HDMI_TX_D2_N
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { hdmi_rx1_p[2] }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=HDMI_TX_D2_P
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx1_hpd }]; #IO_0_34 Sch=HDMI_TX_HDPN
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx1_rscl }]; #IO_L8P_T1_AD10P_35 Sch=HDMI_TX_SCL
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx1_rsda }]; #IO_L8N_T1_AD10N_35 Sch=HDMI_TX_SDA

# set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { PM_DVI_CLK }]; #IO_L8N_T1_34 Sch=JB1_N;

## Pmod Header JA
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_r[3]}];
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_r[1]}];
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_g[3]}];
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_g[1]}];
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_r[2]}];
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_r[0]}];
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_g[2]}];
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_g[0]}];

## Pmod Header JB
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_b[3]}];
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_clk}];
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_b[0]}];
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_hs}];
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_b[2]}];
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_b[1]}];
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_de}];
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {pm_dvi_vs}];

## Buttons
set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports { button0 }]; #IO_L4P_T0_35 Sch=BTN0
