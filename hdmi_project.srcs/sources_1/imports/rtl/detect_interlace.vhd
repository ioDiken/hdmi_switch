library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity detect_interlace is
    Port ( clk             : in STD_LOGIC;
           hsync           : in std_logic;
           vsync           : in std_logic;
    	   is_interlaced   : out std_logic;
	   	   is_second_field : out std_logic);
end entity;

architecture Behavioral of detect_interlace is
	signal last_vsync     : std_logic := '0';
	signal last_hsync     : std_logic := '0';
	signal first_quarter  : unsigned(11 downto 0) := (others => '0');
	signal last_quarter   : unsigned(11 downto 0) := (others => '0');
	signal hcount         : unsigned(11 downto 0) := (others => '0');
	signal last_vsync_pos : unsigned(11 downto 0) := (others => '0');
	signal second_field   : std_logic := '0';
begin
clk_proc: process(clk)
	begin
		if rising_edge(clk) then
			if last_vsync = '0' and vsync = '1' then
				is_second_field <= '0';
				if hcount > first_quarter and hcount < last_quarter then
					-- The second field of an interlaced 
                           -- frame is indicated when the vsync is
	                      -- asserted in the middle of the scan line.
					--
					-- Also add a little check for a misbehaving source
					if last_vsync_pos /= hcount then
						is_interlaced   <= '1';
						is_second_field <= '1';
						second_field    <= '1';
					else
						is_interlaced   <= '1';
						is_second_field <= '1';
						second_field    <= '1';
					end if;

				else
					-- If we see two 'field 1's in a row we 
					-- switch back to indicating an 
                    -- uninterlaced source
					if second_field = '0' then
						is_interlaced <= '0';
					end if;									
					is_second_field <= '0';
					second_field    <= '0';
				end if;
				last_vsync_pos <= hcount;
			else
			end if;

			if last_hsync = '0' and hsync = '1' then
				hcount <= (others => '0');
				first_quarter <= "00" & hcount(11 downto 2);
				last_quarter <= hcount+1-hcount(11 downto 2);
			else
				hcount <= hcount +1;
			end if;
			last_vsync <= vsync;
			last_hsync <= hsync;
		end if;
	end process;
end architecture;
		