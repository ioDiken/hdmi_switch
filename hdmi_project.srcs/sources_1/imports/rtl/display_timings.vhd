library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity display_timings is
    port (
        i_pix_clk               : in std_logic;          -- pixel clock
        i_rst                   : in std_logic;          -- reset: restarts frame (active high)
        o_de                    : out std_logic         -- display enable: high during active video
        );
    end entity;

architecture Behavioral of display_timings is
    signal o_sx : integer := 0;  -- horizontal beam position (including blanking)
    signal o_sy : integer := 0;  -- horizontal beam position (including blanking)
    
    signal H_RES    : integer := 1920;  -- horizontal resolution (pixels)
    signal V_RES    : integer := 1080;  -- vertical resolution (lines)
    signal H_FP     : integer := 88;    -- horizontal front porch
    signal H_SYNC   : integer := 44;    -- horizontal sync
    signal H_BP     : integer := 148;   -- horizontal back porch
    signal V_FP     : integer := 4;     -- vertical front porch
    signal V_SYNC   : integer := 5;     -- vertical sync
    signal V_BP     : integer := 36;    -- vertical back porch
    signal H_POL    : integer := 0;     -- horizontal sync polarity (0:neg, 1:pos)
    signal V_POL    : integer := 0;     -- vertical sync polarity (0:neg, 1:pos)

    -- Horizontal: sync, active, and pixels
    signal H_STA    : integer;  -- horizontal start
    signal HS_STA   : integer;  -- sync start
    signal HS_END   : integer;  -- sync end --- H_STA + H_FP
    signal HA_STA   : integer;  -- active start
    signal HA_END   : integer;  -- active end

    -- Vertical: sync, active, and pixels
    signal V_STA    : integer;  -- vertical start
    signal VS_STA   : integer;  -- sync start
    signal VS_END   : integer;  -- sync end --- V_STA + V_FP
    signal VA_STA   : integer;  -- active start
    signal VA_END   : integer;  -- active end

begin
    H_STA  <= 0 - H_FP - H_SYNC - H_BP;
    HS_STA <= H_STA + H_FP;
    HS_END <= HS_STA + H_SYNC;
    HA_STA <= 0;
    HA_END <= H_RES - 1;

    V_STA  <= 0 - V_FP - V_SYNC - V_BP;
    VS_STA <= V_STA + V_FP;
    VS_END <= VS_STA + V_SYNC;
    VA_STA <= 0;
    VA_END <= V_RES - 1;

    -- display enable: high during active period
     o_de <= '1' when ((o_sx > 0) and (o_sy > 0)) else '0';

    process(i_pix_clk)
    begin
        if rising_edge(i_pix_clk) then
            if (i_rst = '1')  then -- reset to start of frame
                o_sx <= H_STA;
                o_sy <= V_STA;
            else
                if (o_sx = HA_END) then  -- end of line
                    o_sx <= H_STA;
                    if (o_sy = VA_END) then  -- end of frame
                        o_sy <= V_STA;
                    else
                        o_sy <= o_sy + 1;
                    end if;
                else
                    o_sx <= o_sx + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

