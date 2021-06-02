library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_audio_to_db is
end tb_audio_to_db;

architecture Behavioral of tb_audio_to_db is
    component audio_to_db is
    Port ( clk           : in  STD_LOGIC;

           in_channel    : in  STD_LOGIC_VECTOR (2 downto 0);
           in_de         : in  STD_LOGIC;
           in_sample     : in  STD_LOGIC_VECTOR (23 downto 0);

           out_channel   : out STD_LOGIC_VECTOR (2 downto 0);
           out_de        : out STD_LOGIC;
           out_level     : out STD_LOGIC_VECTOR (5 downto 0));
    end component;

    signal clk           : STD_LOGIC := '0';

    signal in_channel    : STD_LOGIC_VECTOR (2 downto 0)  := (others => '0');
    signal in_de         : STD_LOGIC                      := '1';
    signal in_sample     : STD_LOGIC_VECTOR (23 downto 0) := (others => '0');

    signal out_channel   : STD_LOGIC_VECTOR (2 downto 0);
    signal out_de        : STD_LOGIC;
    signal out_level     : STD_LOGIC_VECTOR (5 downto 0);

begin

process
    begin
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
    end process;

process
    begin
        wait until rising_edge(clk);
        in_de <= '1';
        in_sample <= in_sample(in_sample'high-1 downto 0) & not in_sample(in_sample'high);
        wait until rising_edge(clk);
        in_de <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
    end process;

uut: audio_to_db port map (
        clk         => clk,
        in_channel  => in_channel,
        in_de       => in_de,
        in_sample   => in_sample,

        out_channel => out_channel,
        out_de      => out_de,
        out_level   => out_level);

end Behavioral;
