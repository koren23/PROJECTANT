library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sources is
    port(
        clk   : in  std_logic; 
        yellow : out std_logic_vector(1 downto 0);
        blue : out std_logic;
        green : out std_logic;
        red : out std_logic
    );
end sources;

architecture Behavioral of sources is
    signal count : integer := 0;
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
             if count = 1e9 then
                green <= '0';
                blue <= '0';
                red <= '0';
                yellow <= "00";
             elsif count = 700e6 then
                green <= '0';
                blue <= '0';
                red <= '1';
                yellow <= "00";
             elsif count = 500e6 then
                green <= '0';
                blue <= '1';
                red <= '1';
                yellow <= "00";
             elsif count = 100e6 then
                green <= '0';
                blue <= '0';
                red <= '1';
                yellow <= "11";
             elsif count = 0 then 
                green <= '1';
                blue <= '0';
                red <= '1';
                yellow <= "11";
             end if;
             count <= count +1;
        end if;
        
    end process;
end Behavioral;