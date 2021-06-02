library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity guidelines is
    Port ( clk : in STD_LOGIC;
       enable_feature   : in std_logic;
       -------------------------------
       -- VGA data recovered from HDMI
       -------------------------------
       in_blank  : in std_logic;
       in_hsync  : in std_logic;
       in_vsync  : in std_logic;
       in_red    : in std_logic_vector(7 downto 0);
       in_green  : in std_logic_vector(7 downto 0);
       in_blue   : in std_logic_vector(7 downto 0);
       is_interlaced   : in std_logic;
       is_second_field : in std_logic;
        
       -----------------------------------
       -- VGA data to be converted to HDMI
       -----------------------------------
       out_blank : out std_logic;
       out_hsync : out std_logic;
       out_vsync : out std_logic;
       out_red   : out std_logic_vector(7 downto 0);
       out_green : out std_logic_vector(7 downto 0);
       out_blue  : out std_logic_vector(7 downto 0));
end guidelines;

architecture Behavioral of guidelines is
    signal hcount : unsigned(11 downto 0) := (others => '0');
    signal vcount : unsigned(11 downto 0) := (others => '0');
    signal h_size : unsigned(11 downto 0) := (others => '0');
    signal v_size : unsigned(11 downto 0) := (others => '0');
    signal last_blank : std_logic := '0';
    signal last_vsync : std_logic := '0';
begin

process(clk)
    begin
        if rising_edge(clk) then
            out_blank  <= in_blank;
            out_hsync  <= in_hsync;
            out_vsync  <= in_vsync;
            out_red    <= in_red;
            out_green  <= in_green;
            out_blue   <= in_blue;

            if enable_feature = '1' then
                if h_size = 1280 then
                    if hcount = 426 or hcount = 854 then
                        out_red   <= (others => '1');
                        out_green <= (others => '1');
                        out_blue  <= (others => '1');
                    end if; 
                end if; 

                if h_size = 1920 then
                    if hcount = 640 or hcount = 1280 then
                        out_red   <= (others => '1');
                        out_green <= (others => '1');
                        out_blue  <= (others => '1');
                    end if; 
                end if;

                if v_size = 720 then
                    if vcount = 240 or vcount = 480 then
                        out_red   <= (others => '1');
                        out_green <= (others => '1');
                        out_blue  <= (others => '1');
                    end if;
                end if;

                if v_size = 1080 then
                    if is_interlaced = '0' and (vcount = 360 or vcount = 720) then
                        out_red   <= (others => '1');
                        out_green <= (others => '1');
                        out_blue  <= (others => '1');
                    end if;
                    
                    if is_interlaced = '1' and (vcount = 180 or vcount = 360) then
                        out_red   <= (others => '1');
                        out_green <= (others => '1');
                        out_blue  <= (others => '1');
                    end if;
                end if;
            end if;
                            
            -------------------------------------------------------------
            -- Count the number of lines in a frame (not field!!!)
            -------------------------------------------------------------
            if last_blank = '0' and in_blank = '1' then
                vcount <= vcount + 1;
            end if;
            
            -------------------------------------------------------------
            -- Use the falling edge of VSYNC to to capture the number of 
            -- lines on the screen, as the rising edge is where the 
            -- interaced field is detected and can be a bit unstable.
            -------------------------------------------------------------
            if in_vsync = '0' and last_vsync = '1' and is_second_field = '0'then
                vcount <= (others => '0');
                v_size <= vcount;
            end if;

            -------------------------------------------------------------
            -- Count the width of the frame
            -------------------------------------------------------------
            if in_blank = '1' then
                if hcount /= 0 then
                    h_size <= hcount;
                end if;
                hcount <= (others => '0');
            else
                hcount <= hcount + 1;
            end if;
            last_blank <= in_blank;
            last_vsync <= in_vsync;
            if enable_feature = '1' and in_blank = '0' then
            end if; 
        end if;
    end process;
end Behavioral;
