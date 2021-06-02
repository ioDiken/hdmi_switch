library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity hdmi_design is
    Port ( 
        clk100    : in STD_LOGIC;

        -- Button
        button0       : in std_logic;

        -- PMOD Outputs
        pm_dvi_r      : out std_logic_vector(3 downto 0);
        pm_dvi_g      : out std_logic_vector(3 downto 0);
        pm_dvi_b      : out std_logic_vector(3 downto 0);
        pm_dvi_clk    : out std_logic;
        pm_dvi_hs     : out std_logic;
        pm_dvi_vs     : out std_logic;
        pm_dvi_de     : out std_logic;

        --HDMI input 0 signals
        hdmi_rx0_cec   : inout std_logic;
        hdmi_rx0_hpa   : inout   std_logic;
        hdmi_rx0_scl   : in    std_logic;
        hdmi_rx0_sda   : inout std_logic;
        hdmi_rx0_clk_n : in    std_logic;
        hdmi_rx0_clk_p : in    std_logic;
        hdmi_rx0_n     : in    std_logic_vector(2 downto 0);
        hdmi_rx0_p     : in    std_logic_vector(2 downto 0);

        --- HDMI input 1 signals
        hdmi_rx1_cec   : inout std_logic;
        hdmi_rx1_hpa   : inout   std_logic;
        hdmi_rx1_scl   : in    std_logic;
        hdmi_rx1_sda   : inout std_logic;
        hdmi_rx1_clk_n : in    std_logic;
        hdmi_rx1_clk_p : in    std_logic;
        hdmi_rx1_n     : in    std_logic_vector(2 downto 0);
        hdmi_rx1_p     : in    std_logic_vector(2 downto 0)
    );
end hdmi_design;

architecture Behavioral of hdmi_design is
    component hdmi_io is
    Port ( 
        clk100    : in STD_LOGIC;
        -------------------------------
        -- Control signals
        -------------------------------
        clock_locked  : out std_logic;
        data_synced   : out std_logic;
        debug         : out std_logic_vector(7 downto 0);   
     
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
        in_blank        : out std_logic;
        in_hsync        : out std_logic;
        in_vsync        : out std_logic;
        in_red          : out std_logic_vector(7 downto 0);
        in_green        : out std_logic_vector(7 downto 0);
        in_blue         : out std_logic_vector(7 downto 0);
        is_interlaced   : out std_logic;
        is_second_field : out std_logic;
            
        -------------------------------------
        -- Audio Levels
        -------------------------------------
        audio_channel : out std_logic_vector(2 downto 0);
        audio_de      : out std_logic;
        audio_sample  : out std_logic_vector(23 downto 0);
        
        -----------------------------------
        -- VGA data to be converted to HDMI
        -----------------------------------
        out_blank     : in  std_logic;
        out_hsync     : in  std_logic;
        out_vsync     : in  std_logic;
        out_red       : in  std_logic_vector(7 downto 0);
        out_green     : in  std_logic_vector(7 downto 0);
        out_blue      : in  std_logic_vector(7 downto 0);

        -- For symbol dump
        -----------------------------------
        symbol_sync  : out std_logic; -- indicates a fixed reference point in the frame.
        symbol_ch0   : out std_logic_vector(9 downto 0);
        symbol_ch1   : out std_logic_vector(9 downto 0);
        symbol_ch2   : out std_logic_vector(9 downto 0)
    );
    end component;

    signal hdmi_rx_cec      : std_logic;
    signal hdmi_rx_hpa      : std_logic;
    signal hdmi_rx_scl      : std_logic;
    signal hdmi_rx_sda      : std_logic;
    signal hdmi_rx_txen     : std_logic;
    signal hdmi_rx_clk_n    : std_logic;
    signal hdmi_rx_clk_p    : std_logic;
    signal hdmi_rx_p        : std_logic_vector(2 downto 0);
    signal hdmi_rx_n        : std_logic_vector(2 downto 0);

    signal symbol_sync  : std_logic;
    signal symbol_ch0   : std_logic_vector(9 downto 0);
    signal symbol_ch1   : std_logic_vector(9 downto 0);
    signal symbol_ch2   : std_logic_vector(9 downto 0);

    signal sw : std_logic_vector(7 downto 0)  :=(others => '0');
    
    component pixel_processing is
        Port ( clk : in STD_LOGIC;
            switches  : in std_logic_vector(7 downto 0);
            ------------------
            -- Incoming pixels
            ------------------
            in_blank  : in std_logic;
            in_hsync  : in std_logic;
            in_vsync  : in std_logic;
            in_red    : in std_logic_vector(7 downto 0);
            in_green  : in std_logic_vector(7 downto 0);
            in_blue   : in std_logic_vector(7 downto 0);
            is_interlaced   : in  std_logic;
            is_second_field : in  std_logic;
        
            -------------------
            -- Processed pixels
            -------------------
            out_blank : out std_logic;
            out_hsync : out std_logic;
            out_vsync : out std_logic;
            out_red   : out std_logic_vector(7 downto 0);
            out_green : out std_logic_vector(7 downto 0);
            out_blue  : out std_logic_vector(7 downto 0);
                       
            -------------------------------------
            -- Audio samples for metering
            -------------------------------------
            audio_channel : in std_logic_vector(2 downto 0);
            audio_de      : in std_logic;
            audio_sample  : in std_logic_vector(23 downto 0)
    );
    end component;

    component display_timings is
        port (
            i_pix_clk   : in std_logic;          -- pixel clock
            i_rst       : in std_logic;          -- reset: restarts frame (active high)
            o_de        : out std_logic);        -- display enable: high during active video
    end component;

    signal pixel_clk : std_logic;
    signal in_blank  : std_logic;
    signal in_hsync  : std_logic;
    signal in_vsync  : std_logic;
    signal in_red    : std_logic_vector(7 downto 0);
    signal in_green  : std_logic_vector(7 downto 0);
    signal in_blue   : std_logic_vector(7 downto 0);
    signal is_interlaced   : std_logic;
    signal is_second_field : std_logic;
    signal out_blank : std_logic;
    signal out_hsync : std_logic;
    signal out_vsync : std_logic;
    signal out_red   : std_logic_vector(7 downto 0);
    signal out_green : std_logic_vector(7 downto 0);
    signal out_blue  : std_logic_vector(7 downto 0);

    signal audio_channel : std_logic_vector(2 downto 0);
    signal audio_de      : std_logic;
    signal audio_sample  : std_logic_vector(23 downto 0);

    signal debug : std_logic_vector(7 downto 0);
    signal clock_locked : std_logic;
    signal clock_locked_i : std_logic;

begin
    pm_dvi_r <= out_red(3 downto 0);
    pm_dvi_g <= out_green(3 downto 0);
    pm_dvi_b <= out_blue(3 downto 0);
    pm_dvi_clk <= pixel_clk;

    -- HDMI Rx Mux
    hdmi_rx_cec <= hdmi_rx1_cec when (button0 = '1') else hdmi_rx0_cec;
    hdmi_rx_hpa <= hdmi_rx1_hpa when (button0 = '1') else hdmi_rx0_hpa;
    hdmi_rx_scl <= hdmi_rx1_scl when (button0 = '1') else hdmi_rx0_scl;
    hdmi_rx_sda <= hdmi_rx1_sda when (button0 = '1') else hdmi_rx0_sda;
    hdmi_rx_clk_n <= hdmi_rx1_clk_n when (button0 = '1') else hdmi_rx0_clk_n;
    hdmi_rx_clk_p <= hdmi_rx1_clk_p when (button0 = '1') else hdmi_rx0_clk_p;
    hdmi_rx_p <= hdmi_rx1_p when (button0 = '1') else hdmi_rx0_p;
    hdmi_rx_n <= hdmi_rx1_n when (button0 = '1') else hdmi_rx0_n;

    clock_locked_i <= not clock_locked;

i_display_timings: display_timings port map (
        i_pix_clk  => pixel_clk,
        i_rst      => clock_locked_i,
        o_de       => pm_dvi_de
    );
    
i_hdmi_io: hdmi_io port map ( 
        clk100        => clk100,

        ---------------------
        -- Control signals
        ---------------------
        clock_locked     => clock_locked,
        data_synced      => open,
        debug            => debug,

        ---------------------
        -- HDMI input signals
        ---------------------
        hdmi_rx_cec   => hdmi_rx_cec,
        hdmi_rx_hpa   => hdmi_rx_hpa,
        hdmi_rx_scl   => hdmi_rx_scl,
        hdmi_rx_sda   => hdmi_rx_sda,
        hdmi_rx_txen  => hdmi_rx_txen,
        hdmi_rx_clk_n => hdmi_rx_clk_n,
        hdmi_rx_clk_p => hdmi_rx_clk_p,
        hdmi_rx_p     => hdmi_rx_p,
        hdmi_rx_n     => hdmi_rx_n,

        -------------------------------
        -- Pixel Clock Out
        -------------------------------
        pixel_clk => pixel_clk,

        -------------------------------
        -- VGA data recovered from HDMI
        -------------------------------
        in_blank        => in_blank,
        in_hsync        => in_hsync,
        in_vsync        => in_vsync,
        in_red          => in_red,
        in_green        => in_green,
        in_blue         => in_blue,
        is_interlaced   => is_interlaced,
        is_second_field => is_second_field,

        -----------------------------------
        -- For symbol dump or retransmit
        -----------------------------------
        audio_channel => audio_channel,
        audio_de      => audio_de,
        audio_sample  => audio_sample,
        
        -----------------------------------
        -- VGA data to be converted to HDMI
        -----------------------------------
        out_blank => out_blank,
        out_hsync => out_hsync,
        out_vsync => out_vsync,
        out_red   => out_red,
        out_green => out_green,
        out_blue  => out_blue,
        
        symbol_sync  => symbol_sync, 
        symbol_ch0   => symbol_ch0,
        symbol_ch1   => symbol_ch1,
        symbol_ch2   => symbol_ch2
    );
    
i_processing: pixel_processing Port map ( 
        clk => pixel_clk,
        switches => sw,
        ------------------
        -- Incoming pixels
        ------------------
        in_blank        => in_blank,
        in_hsync        => in_hsync,
        in_vsync        => in_vsync,
        in_red          => in_red,
        in_green        => in_green,
        in_blue         => in_blue,    
        is_interlaced   => is_interlaced,
        is_second_field => is_second_field,
        audio_channel   => audio_channel,
        audio_de        => audio_de,
        audio_sample    => audio_sample,
        -------------------
        -- Processed pixels
        -------------------
        out_blank => out_blank,
        out_hsync => out_hsync,
        out_vsync => out_vsync,
        out_red   => out_red,
        out_green => out_green,
        out_blue  => out_blue
    );
    
end Behavioral;