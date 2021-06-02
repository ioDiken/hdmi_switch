library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity line_delay is
    Port ( clk : in STD_LOGIC;
           -------------------------------
           -- VGA data recovered from HDMI
           -------------------------------
           in_blank  : in std_logic;
           in_hsync  : in std_logic;
           in_vsync  : in std_logic;
           in_red    : in std_logic_vector(7 downto 0);
           in_green  : in std_logic_vector(7 downto 0);
           in_blue   : in std_logic_vector(7 downto 0);
     
           -----------------------------------
           -- VGA data to be converted to HDMI
           -----------------------------------
           out_blank : out std_logic;
           out_hsync : out std_logic;
           out_vsync : out std_logic;
           out_red   : out std_logic_vector(7 downto 0);
           out_green : out std_logic_vector(7 downto 0);
           out_blue  : out std_logic_vector(7 downto 0));
end line_delay;

architecture Behavioral of line_delay is
    type mem_block is array (0 to 511) of std_logic_vector(26 downto 0);
    signal mem_0 : mem_block := (others => (others => '0'));
    signal mem_1 : mem_block := (others => (others => '0'));
    signal mem_2 : mem_block := (others => (others => '0'));
    signal mem_3 : mem_block := (others => (others => '0'));
    signal mem_4 : mem_block := (others => (others => '0'));
    
    signal wr_addr    : unsigned(8 downto 0) := (others =>'1');
    signal offset_0   : unsigned(8 downto 0) := (others =>'1');
    signal offset_1   : unsigned(8 downto 0) := (others =>'1');
    signal offset_2   : unsigned(8 downto 0) := (others =>'1');
    signal offset_3   : unsigned(8 downto 0) := (others =>'1');
    signal offset_4   : unsigned(8 downto 0) := (others =>'1');

    signal width      : unsigned(11 downto 0) := (others =>'0');
    signal line_count : unsigned(11 downto 0) := (others =>'0');
    signal last_hsync : std_logic := '0';
    signal mid_0      : std_logic_vector(26 downto 0) := (others =>'0');
    signal mid_1      : std_logic_vector(26 downto 0) := (others =>'0');
    signal mid_2      : std_logic_vector(26 downto 0) := (others =>'0');
    signal mid_3      : std_logic_vector(26 downto 0) := (others =>'0');
begin

process(clk)
    variable mem_4_out : std_logic_vector(26 downto 0);
    variable temp      : unsigned(11 downto 0) := (others =>'1');
    begin
        if rising_edge(clk) then
            ------------------------------------------------ 
            -- Retreive the value from the end of the delay
            -- and break out the signals
            ------------------------------------------------ 
            mem_4_out := mem_4(to_integer(wr_addr+offset_4));
            out_red   <= mem_4_out(26 downto 19);
            out_green <= mem_4_out(18 downto 11);
            out_blue  <= mem_4_out(10 downto  3);
            out_blank <= mem_4_out(2);
            out_hsync <= mem_4_out(1);
            out_vsync <= mem_4_out(0);
            
            -------------------------------------------------
            -- Move everything through the five memory blocks
            -------------------------------------------------
            mem_4(to_integer(wr_addr)) <= mid_3;
            mid_3                      <= mem_3(to_integer(wr_addr+offset_3));
            mem_3(to_integer(wr_addr)) <= mid_2;
            mid_2                      <= mem_2(to_integer(wr_addr+offset_2));
            mem_2(to_integer(wr_addr)) <= mid_1;
            mid_1                      <= mem_1(to_integer(wr_addr+offset_1));
            mem_1(to_integer(wr_addr)) <= mid_0;
            mid_0                      <= mem_0(to_integer(wr_addr+offset_0));
            mem_0(to_integer(wr_addr)) <= in_red & in_green & in_blue & in_blank & in_hsync & in_vsync;
            wr_addr <= wr_addr - 1;
            if in_hsync = '1' and last_hsync ='0' then
                width <= line_count;
                line_count <= (others => '0');
            else
                line_count <=line_count + 1;
            end if;
            
            -------------------------------------------------------------
            -- Update the offsets every cycle, not that we really need to
            -- This improves the timing as we have less logic
            -------------------------------------------------------------
            offset_0 <= to_unsigned(508,9);
            temp := width-512+0; offset_1 <= temp(10 downto 2);
            temp := width-512+1; offset_2 <= temp(10 downto 2);
            temp := width-512+2; offset_3 <= temp(10 downto 2);
            temp := width-512+3; offset_4 <= temp(10 downto 2);
             
            last_hsync <= in_hsync;
        end if;
    end process;

end Behavioral;
