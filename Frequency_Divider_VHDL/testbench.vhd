
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbnch is
end testbnch;

architecture Behavioral of testbnch is
    signal clk_tb    : std_logic := '0';
    signal yellow_tb : std_logic_vector(1 downto 0);
    signal blue_tb   : std_logic;
    signal green_tb  : std_logic;
    signal red_tb    : std_logic;
    constant clk_period : time := 10 ns;
begin
    uut: entity work.entityname
        port map (
            clk => clk_tb,
            yellow => yellow_tb,
            blue => blue_tb,
            green => green_tb,
            red => red_tb
        );
    clk_process: process
        begin
        while now < 100 ms loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period /2;
        end loop;
        wait;
    end process;
    
end Behavioral;
