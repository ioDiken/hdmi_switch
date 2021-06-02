library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conversion_to_RGB is
    port ( clk      : in std_Logic;
           input_is_YCbCr : in std_Logic;
           input_is_sRGB  : in std_Logic;

           ------------------------
           in_blank : in std_logic;
           in_hsync : in std_logic;
           in_vsync : in std_logic;
           in_U     : in std_logic_vector(11 downto 0);  -- B or Cb
           in_V     : in std_logic_vector(11 downto 0);  -- G or Y
           in_W     : in std_logic_vector(11 downto 0);  -- R or Cr

           ------------------------
           out_blank : out std_logic;
           out_hsync : out std_logic;
           out_vsync : out std_logic;
           out_R     : out std_logic_vector(11 downto 0);
           out_G     : out std_logic_vector(11 downto 0);
           out_B     : out std_logic_vector(11 downto 0));
end entity;

architecture Behavioral of conversion_to_RGB is
    ------------------------------
    -- For the pipeline 
    ------------------------------
    signal s1_blank : std_logic;
    signal s1_hsync : std_logic;
    signal s1_vsync : std_logic;
    signal s1_U     : std_logic_vector(12 downto 0);  -- B or Cb, plus underflow guard bit
    signal s1_V     : std_logic_vector(12 downto 0);  -- G or Y, plus underflow guard bit
    signal s1_W     : std_logic_vector(12 downto 0);  -- R or Cr, plus underflow guard bit

    signal s2_blank : std_logic;
    signal s2_hsync : std_logic;
    signal s2_vsync : std_logic;
    signal s2_U     : std_logic_vector(12 downto 0);  -- B or Cb, plus overflow guard bit
    signal s2_V     : std_logic_vector(12 downto 0);  -- G or Y, plus overflow guard bit
    signal s2_W     : std_logic_vector(12 downto 0);  -- R or Cr, plus overflow guard bit

    ------------------------------
    -- For Calculation
    ------------------------------
    signal a     : unsigned(26 downto 0) := (others => '0');
    signal b     : unsigned(26 downto 0) := (others => '0');
    signal c     : unsigned(26 downto 0) := (others => '0');
    signal d     : unsigned(26 downto 0) := (others => '0');
    signal e     : unsigned(26 downto 0) := (others => '0');
    signal R_raw : unsigned(26 downto 0) := (others => '0');
    signal G_raw : unsigned(26 downto 0) := (others => '0');
    signal B_raw : unsigned(26 downto 0) := (others => '0');
begin
clk_proc: process(clk)
   begin
      if rising_edge(clk) then
         -----------------------------------------------
         -- Step 3: clamp the result
         -----------------------------------------------
         out_blank <= s2_blank;
         out_hsync <= s2_hsync;
         out_vsync <= s2_vsync;
         if input_is_YCbCr = '0' then
            -- trap overflows form prior stage
            if s2_U(s2_U'high) = '0' then
                out_B     <= s2_U(s2_U'high-1 downto 0);
            else 
                out_B     <= (others => '1');
            end if;
            
            if s2_V(s2_V'high) = '0' then
                out_G     <= s2_V(s2_V'high-1 downto 0); 
            else 
                out_G     <= (others => '1');
            end if;
            
            if s2_W(s2_W'high) = '0' then
                out_R     <= s2_W(s2_W'high-1 downto 0); 
            else 
                out_R     <= (others => '1');
            end if;
         else   
            case R_raw(R_raw'high-1 downto R_raw'high-2) is
                when "00"   => out_R <= std_logic_vector(R_raw(R_raw'high-3 downto R_raw'high-14)); -- In range
                when "01"   => out_R <= (others => '1');                          -- Overflow
                when others => out_R <= (others => '0');                          -- Underflow
             end case;
                
            case G_raw(G_raw'high-1 downto G_raw'high-2) is
                when "00"   => out_G <= std_logic_vector(G_raw(G_raw'high-3 downto G_raw'high-14)); -- In range
                when "01"   => out_G <= (others => '1');                          -- Overflow
                when others => out_G <= (others => '0');                          -- Underflow
             end case;
                
            case B_raw(B_raw'high-1 downto B_raw'high-2) is
                when "00"   => out_B <= std_logic_vector(B_raw(B_raw'high-3 downto B_raw'high-14)); -- In range
                when "01"   => out_B <= (others => '1');                          -- Overflow
                when others => out_B <= (others => '0');                          -- Underflow
             end case;
         end if;
         -------------------------------------------------
         -- Step 2: Add the partial results and remove the
         -- offset introduced by the use of studio range
         -------------------------------------------------
         s2_blank <= s1_blank;
         s2_hsync <= s1_hsync;
         s2_vsync <= s1_vsync;
         if input_is_sRGB = '1' then
            -- Trap underflows from prior stage
            if s1_U(s1_U'high) = '0' then
                s2_U     <= std_logic_vector(unsigned(s1_U) + unsigned(s1_U(s1_U'high downto 5)));
            else
                s2_U  <= (others => '0');
            end if; 

            if s1_V(s1_V'high) = '0' then
                s2_V     <= std_logic_vector(unsigned(s1_V) + unsigned(s1_V(s1_V'high downto 5)));   
            else
                s2_V  <= (others => '0');
            end if;
             
            if s1_W(s1_W'high) = '0' then
                s2_W     <= std_logic_vector(unsigned(s1_W) + unsigned(s1_W(s1_W'high downto 5)));
            else
                s2_W  <= (others => '0');
            end if; 
         else
            s2_U <= s1_U;
            s2_V <= s1_V;
            s2_W <= s1_W;
         end if;  
         R_raw <= a + d     - to_unsigned(4767*256 +    0*2048 + 7344*2048, 27);
         G_raw <= a - b - e + to_unsigned(-4767*256 +  872*2048 + 2183*2048, 27);
         B_raw <= a + c     - to_unsigned(4767*256 + 8650*2048 +    0*2048, 27);
  
         -------------------------------------------------
         -- Step 1: Multiply the incoming values by the   
         -- Conversion coefficients
         -------------------------------------------------
         s1_blank <= in_blank;
         s1_hsync <= in_hsync;
         s1_vsync <= in_vsync;
         if input_is_sRGB = '1' then
             s1_U     <= std_logic_vector(unsigned('0' & in_U) - 256); 
             s1_V     <= std_logic_vector(unsigned('0' & in_V) - 256);
             s1_W     <= std_logic_vector(unsigned('0' & in_W) - 256);
         else
             s1_U     <= '0' & in_U; 
             s1_V     <= '0' & in_V; 
             s1_W     <= '0' & in_W;
         end if; 
         a <= unsigned(in_V) * to_unsigned(4767,15); -- 1.164 * 2^12
         b <= unsigned(in_U) * to_unsigned( 872,15); -- 0.213 * 2^12
         c <= unsigned(in_U) * to_unsigned(8650,15); -- 2.112 * 2^12
         d <= unsigned(in_W) * to_unsigned(7344,15); -- 1.793 * 2^12
         e <= unsigned(in_W) * to_unsigned(2183,15); -- 0.533 * 2^12
      end if;
   end process;
end architecture;
