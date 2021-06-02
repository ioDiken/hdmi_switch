library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity hdmi_io is
    port (
        clk100        : in STD_LOGIC;
        -------------------------------
        -- Control signals
        -------------------------------
        clock_locked   : out std_logic;
        data_synced    : out std_logic;
        debug          : out std_logic_vector(7 downto 0);        
        
        -------------------------------
        --HDMI input signals
        -------------------------------
        hdmi_rx_cec   : inout std_logic;
        hdmi_rx_hpa   : out   std_logic;
        hdmi_rx_scl   : in    std_logic;
        hdmi_rx_sda   : inout std_logic;
        hdmi_rx_txen  : out   std_logic;
        hdmi_rx_clk_n : in    std_logic;
        hdmi_rx_clk_p : in    std_logic;
        hdmi_rx_n     : in    std_logic_vector(2 downto 0);
        hdmi_rx_p     : in    std_logic_vector(2 downto 0);

        -------------------------------
        -- Pixel Clock Out
        -------------------------------
        pixel_clk     : out std_logic;

        -------------------------------
        -- VGA data recovered from HDMI
        -------------------------------
        in_hdmi_detected : out std_logic;
        in_blank  : out std_logic;
        in_hsync  : out std_logic;
        in_vsync  : out std_logic;
        in_red    : out std_logic_vector(7 downto 0);
        in_green  : out std_logic_vector(7 downto 0);
        in_blue   : out std_logic_vector(7 downto 0);
        is_interlaced   : out std_logic;
        is_second_field : out std_logic;
        
        -----------------------------------
        -- VGA data to be converted to HDMI
        -----------------------------------
        out_blank : in  std_logic;
        out_hsync : in  std_logic;
        out_vsync : in  std_logic;
        out_red   : in  std_logic_vector(7 downto 0);
        out_green : in  std_logic_vector(7 downto 0);
        out_blue  : in  std_logic_vector(7 downto 0);
       -------------------------------------
        -- Audio Levels
        -------------------------------------
        audio_channel : out std_logic_vector(2 downto 0);
        audio_de      : out std_logic;
        audio_sample  : out std_logic_vector(23 downto 0);
        
        -----------------------------------
        -- For symbol dump or retransmit
        -----------------------------------
        symbol_sync  : out std_logic; -- indicates a fixed reference point in the frame.
        symbol_ch0   : out std_logic_vector(9 downto 0);
        symbol_ch1   : out std_logic_vector(9 downto 0);
        symbol_ch2   : out std_logic_vector(9 downto 0)
    );
end entity;

architecture Behavioral of hdmi_io is
    component edid_rom is
    port ( clk      : in    std_logic;
           sclk_raw : in    std_logic;
           sdat_raw : inout std_logic;
           edid_debug : out std_logic_vector(2 downto 0));
    end component;

    component hdmi_input is 
    port (
        system_clk      : in  std_logic;

        debug           : out std_logic_vector(5 downto 0);        
        hdmi_detected : out std_logic;
        
        pixel_clk       : out std_logic;  -- Driven by BUFG
        pixel_io_clk_x1 : out std_logic;  -- Driven by BUFFIO
        pixel_io_clk_x5 : out std_logic;  -- Driven by BUFFIO
    
        -- HDMI input signals
        hdmi_in_clk   : in    std_logic;
        hdmi_in_ch0   : in    std_logic;
        hdmi_in_ch1   : in    std_logic;
        hdmi_in_ch2   : in    std_logic;
    
        -- Status
        pll_locked   : out std_logic;
        symbol_sync  : out std_logic;
    
        -- Raw data signals
        raw_blank : out std_logic;
        raw_hsync : out std_logic;
        raw_vsync : out std_logic;
        raw_ch0   : out std_logic_vector(7 downto 0);
        raw_ch1   : out std_logic_vector(7 downto 0);
        raw_ch2   : out std_logic_vector(7 downto 0);
        -- ADP data
        adp_data_valid      : out std_logic;
        adp_header_bit      : out std_logic;
        adp_frame_bit       : out std_logic;
        adp_subpacket0_bits : out std_logic_vector(1 downto 0);
        adp_subpacket1_bits : out std_logic_vector(1 downto 0);
        adp_subpacket2_bits : out std_logic_vector(1 downto 0);
        adp_subpacket3_bits : out std_logic_vector(1 downto 0);
        -- For later reuse
        symbol_ch0   : out std_logic_vector(9 downto 0);
        symbol_ch1   : out std_logic_vector(9 downto 0);
        symbol_ch2   : out std_logic_vector(9 downto 0)
        
    );
    end component;
    
    -----------------------------------------------------
    -- This is a half-baked solution to extracting data
    -- from ADP packets - just pipe the data thorugh and 
    -- extract bits on the fly. A 'real' solution would
    -- first verify the ECC codes and recover any errors
    ------------------------------------------------------
    component extract_video_infopacket_data is 
    port (
        clk                 : in  std_logic;
        -- ADP data
        adp_data_valid      : in  std_logic;
        adp_header_bit      : in  std_logic;
        adp_frame_bit       : in  std_logic;
        adp_subpacket0_bits : in  std_logic_vector(1 downto 0);
        adp_subpacket1_bits : in  std_logic_vector(1 downto 0);
        adp_subpacket2_bits : in  std_logic_vector(1 downto 0);
        adp_subpacket3_bits : in  std_logic_vector(1 downto 0);
        -- The stuff we need
        input_is_YCbCr      : out std_Logic;
        input_is_422        : out std_logic;
        input_is_sRGB       : out std_Logic        
    );
    end component;
    
    signal adp_data_valid      : std_logic;
    signal adp_header_bit      : std_logic;
    signal adp_frame_bit       : std_logic;
    signal adp_subpacket0_bits : std_logic_vector(1 downto 0);
    signal adp_subpacket1_bits : std_logic_vector(1 downto 0);
    signal adp_subpacket2_bits : std_logic_vector(1 downto 0);
    signal adp_subpacket3_bits : std_logic_vector(1 downto 0);
    signal is_interlaced_i     : std_logic;
    signal is_second_field_i   : std_logic;

    component extract_audio_samples is
    Port ( clk                 : in STD_LOGIC;
           adp_data_valid      : in STD_LOGIC;
           adp_header_bit      : in STD_LOGIC;
           adp_frame_bit       : in STD_LOGIC;
           adp_subpacket0_bits : in STD_LOGIC_VECTOR (1 downto 0);
           adp_subpacket1_bits : in STD_LOGIC_VECTOR (1 downto 0);
           adp_subpacket2_bits : in STD_LOGIC_VECTOR (1 downto 0);
           adp_subpacket3_bits : in STD_LOGIC_VECTOR (1 downto 0);
           audio_de            : out STD_LOGIC;
           audio_channel       : out STD_LOGIC_VECTOR (2 downto 0);
           audio_sample        : out STD_LOGIC_VECTOR (23 downto 0));
    end component;


    signal input_is_YCbCr      : std_Logic;
    signal input_is_422        : std_logic;
    signal input_is_sRGB       : std_Logic;

    signal raw_blank : std_logic;
    signal raw_hsync : std_logic;
    signal raw_vsync : std_logic;
    signal raw_ch2   : std_logic_vector(7 downto 0);  -- B or Cb
    signal raw_ch1   : std_logic_vector(7 downto 0);  -- G or Y
    signal raw_ch0   : std_logic_vector(7 downto 0);   -- R or Cr

    component detect_interlace is
        Port ( clk : in STD_LOGIC;
               hsync           : in  std_logic;
               vsync           : in  std_logic;
               is_interlaced   : out std_logic;
               is_second_field : out std_logic);
    end component;

    component expand_422_to_444 is
    Port ( clk : in STD_LOGIC;
        input_is_422 : in std_logic;
        ------------------
        -- Incoming pixels
        ------------------
        in_blank  : in std_logic;
        in_hsync  : in std_logic;
        in_vsync  : in std_logic;
        in_ch2    : in std_logic_vector(7 downto 0);
        in_ch1    : in std_logic_vector(7 downto 0);
        in_ch0    : in std_logic_vector(7 downto 0);
    
        -------------------
        -- Processed pixels
        -------------------
        out_blank : out std_logic;
        out_hsync : out std_logic;
        out_vsync : out std_logic;
        out_U     : out std_logic_vector(11 downto 0);  -- B or Cb
        out_V     : out std_logic_vector(11 downto 0);  -- G or Y
        out_W     : out std_logic_vector(11 downto 0)   -- R or Cr
    );
    end component;

    signal fourfourfour_blank : std_logic;
    signal fourfourfour_hsync : std_logic;
    signal fourfourfour_vsync : std_logic;
    signal fourfourfour_U     : std_logic_vector(11 downto 0);  
    signal fourfourfour_V     : std_logic_vector(11 downto 0);  
    signal fourfourfour_W     : std_logic_vector(11 downto 0);  

    component conversion_to_RGB is
        port ( clk            : in std_Logic;
               input_is_YCbCr : in std_Logic;
               input_is_sRGB  : in std_Logic;
               ------------------------
               in_blank       : in std_logic;
               in_hsync       : in std_logic;
               in_vsync       : in std_logic;
               in_U           : in std_logic_vector(11 downto 0);
               in_V           : in std_logic_vector(11 downto 0);
               in_W           : in std_logic_vector(11 downto 0);
               ------------------------
               out_blank      : out std_logic;
               out_hsync      : out std_logic;
               out_vsync      : out std_logic;
               out_R          : out std_logic_vector(11 downto 0);
               out_G          : out std_logic_vector(11 downto 0);
               out_B          : out std_logic_vector(11 downto 0)
          );
    end component;
    
    signal rgb_blank : std_logic;
    signal rgb_hsync : std_logic;
    signal rgb_vsync : std_logic;
    signal rgb_R     : std_logic_vector(11 downto 0);
    signal rgb_G     : std_logic_vector(11 downto 0);  -- G or Y
    signal rgb_B     : std_logic_vector(11 downto 0);   -- R or Cr

  
    -- Clocks for the pixel clock domain
    signal pixel_clk_i     : std_logic;
    signal pixel_io_clk_x1 : std_logic;
    signal pixel_io_clk_x5 : std_logic;

    -- The serial data
    signal tmds_in_clk  : std_logic;
    signal tmds_in_ch0  : std_logic;
    signal tmds_in_ch1  : std_logic;
    signal tmds_in_ch2  : std_logic;

    signal detect_sr : std_logic_vector(7 downto 0) := (others => '0');
begin
    pixel_clk <= pixel_clk_i;
    hdmi_rx_hpa  <= '1';
    hdmi_rx_txen <= '1';
    hdmi_rx_cec  <= 'Z';

    debug(7)          <= raw_hsync;
    debug(6)          <= raw_vsync;
    debug(5)          <= is_second_field_i;  
    debug(4)          <= is_interlaced_i;      
    debug(3 downto 0) <= (others => '0');

i_edid_rom: edid_rom  port map (
             clk      => clk100,
             sclk_raw => hdmi_rx_scl,
             sdat_raw => hdmi_rx_sda,
             edid_debug => open);

    ---------------------
    -- Input buffers
    ---------------------
in_clk_buf: IBUFDS generic map ( IOSTANDARD => "TMDS_33")
 port map ( I  => hdmi_rx_clk_p, IB => hdmi_rx_clk_n, O => tmds_in_clk);
 
in_rx0_buf: IBUFDS generic map ( IOSTANDARD => "TMDS_33")
 port map ( I  => hdmi_rx_p(0),  IB => hdmi_rx_n(0),  O  => tmds_in_ch0);

in_rx1_buf: IBUFDS generic map ( IOSTANDARD => "TMDS_33")
 port map ( I  => hdmi_rx_p(1),  IB => hdmi_rx_n(1),  O  => tmds_in_ch1);

in_rx2_buf: IBUFDS generic map ( IOSTANDARD => "TMDS_33")
 port map ( I  => hdmi_rx_p(2),  IB => hdmi_rx_n(2),  O  => tmds_in_ch2);

i_hdmi_input : hdmi_input port map (
        system_clk      => clk100,
        debug           => open,
        -- Pixel and serializer clocks 
        pixel_clk       => pixel_clk_i,
        pixel_io_clk_x1 => pixel_io_clk_x1,
        pixel_io_clk_x5 => pixel_io_clk_x5,    
        --- HDMI input signals
        hdmi_in_clk   => tmds_in_clk,
        hdmi_in_ch0   => tmds_in_ch0,
        hdmi_in_ch1   => tmds_in_ch1,
        hdmi_in_ch2   => tmds_in_ch2,
        -- are the HDMI symbols in sync? 
        symbol_sync   => data_synced,
        pll_locked    => clock_locked, 
        -- VGA internal Signals
        hdmi_detected => in_hdmi_detected,
        raw_blank     => raw_blank,
        raw_hsync     => raw_hsync,
        raw_vsync     => raw_vsync,
        raw_ch2       => raw_ch2,
        raw_ch1       => raw_ch1,
        raw_ch0       => raw_ch0,    
        -- ADP data
        adp_data_valid      => adp_data_valid,
        adp_header_bit      => adp_header_bit,
        adp_frame_bit       => adp_frame_bit,
        adp_subpacket0_bits => adp_subpacket0_bits,
        adp_subpacket1_bits => adp_subpacket1_bits,
        adp_subpacket2_bits => adp_subpacket2_bits,
        adp_subpacket3_bits => adp_subpacket3_bits,
        -- For later reuse
        symbol_ch0 => symbol_ch0,
        symbol_ch1 => symbol_ch1,
        symbol_ch2 => symbol_ch2
    );

    -------------------------------------
    -- If the input data is in 422 format 
    -- then convert it to 12-bit 444 data
    -------------------------------------
i_expand_422_to_444: expand_422_to_444 Port map ( 
        clk          => pixel_clk_i,
        input_is_422 => input_is_422,
        ------------------
        -- Incoming raw data
        ------------------
        in_blank  => raw_blank,
        in_hsync  => raw_hsync,
        in_vsync  => raw_vsync,
        in_ch2    => raw_ch2,
        in_ch1    => raw_ch1,
        in_ch0    => raw_ch0,
    
        -------------------
        -- Processed pixels
        -------------------
        out_blank => fourfourfour_blank,
        out_hsync => fourfourfour_hsync,
        out_vsync => fourfourfour_vsync,
        out_U     => fourfourfour_U,
        out_V     => fourfourfour_V,
        out_W     => fourfourfour_W
    );

    is_interlaced   <= is_interlaced_i;
    is_second_field <= is_second_field_i; 
i_detect_interlace: detect_interlace Port map ( 
    clk             => pixel_clk_i,
    hsync           => raw_hsync,
    vsync           => raw_vsync,
    is_interlaced   => is_interlaced_i,
    is_second_field => is_second_field_i);

i_conversion_to_RGB: conversion_to_RGB 
    port map (
           clk              => pixel_clk_i,
           ------------------------
           input_is_YCbCr   => input_is_YCbCr,
           input_is_sRGB    => input_is_sRGB,
           in_blank         => fourfourfour_blank,
           in_hsync         => fourfourfour_hsync,
           in_vsync         => fourfourfour_vsync,
           in_U             => fourfourfour_U,
           in_V             => fourfourfour_V,
           in_W             => fourfourfour_W,
           ------------------------
           out_blank        => rgb_blank,
           out_hsync        => rgb_hsync,
           out_vsync        => rgb_vsync,
           out_R            => rgb_R,
           out_G            => rgb_G,
           out_B            => rgb_B
    );

    -----------------------------------------
    -- Color space conversion yet to be done
    -----------------------------------------
    in_blank <= rgb_blank;
    in_hsync <= rgb_hsync;
    in_vsync <= rgb_vsync;
    in_blue  <= rgb_B(11 downto 4);
    in_green <= rgb_G(11 downto 4);
    in_red   <= rgb_R(11 downto 4);

    ------------------------------------------------
    -- Processing the non-video data #1
    -- Extracting the Video Infopacket data we need
    -- to correctly convert the video data
    ------------------------------------------------
i_extract_video_infopacket_data: extract_video_infopacket_data port map (
    clk                 => pixel_clk_i,
    -- ADP data
    adp_data_valid      => adp_data_valid,
    adp_header_bit      => adp_header_bit,
    adp_frame_bit       => adp_frame_bit,
    adp_subpacket0_bits => adp_subpacket0_bits,
    adp_subpacket1_bits => adp_subpacket1_bits,
    adp_subpacket2_bits => adp_subpacket2_bits,
    adp_subpacket3_bits => adp_subpacket3_bits,
    -- The stuff we need
    input_is_YCbCr      => input_is_YCbCr,
    input_is_422        => input_is_422,
    input_is_sRGB       => input_is_sRGB 
);
    ------------------------------------------------
    -- Processing the non-video data #2
    -- Extracting the Audio samples so we can display
    -- level menters on the screen
    ------------------------------------------------
i_extract_audio_samples: extract_audio_samples PORT MAP (
       clk                 => pixel_clk_i,
       -- ADP data
       adp_data_valid      => adp_data_valid,
       adp_header_bit      => adp_header_bit,
       adp_frame_bit       => adp_frame_bit,
       adp_subpacket0_bits => adp_subpacket0_bits,
       adp_subpacket1_bits => adp_subpacket1_bits,
       adp_subpacket2_bits => adp_subpacket2_bits,
       adp_subpacket3_bits => adp_subpacket3_bits,
       -- The stuff we need
       audio_de            => audio_de,
       audio_channel       => audio_channel,
       audio_sample        => audio_sample);

end Behavioral;
