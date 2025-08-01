library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sources is
    port(
        clk   : in  std_logic; 
        red   : out std_logic;
        green : out std_logic;
        yellow : out std_logic
    );
end sources;

architecture Behavioral of sources is
    signal counter     : integer := 0;
    signal stepflag    : integer range 0 to 4 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then

            if stepflag = 0 then -- red
                red   <= '1';
                green <= '0';
                yellow <= '0';
                if counter = 500e6 then
                    stepflag <= stepflag + 1;
                    red      <= '0';
                    green    <= '0';
                    yellow <= '0';
                    counter  <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
            
            if stepflag = 1 then -- red and yellow
                red   <= '1';
                green <= '0';
                yellow <= '1';
                if counter = 200e6 then
                    stepflag <= stepflag + 1;
                    red      <= '0';
                    green    <= '0';
                    yellow <= '0';
                    counter  <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
            
            if stepflag = 2 then -- green
                red   <= '0';
                green <= '1';
                yellow <= '0';
                if counter = 400e6 then
                    stepflag <= stepflag + 1;
                    red      <= '0';
                    green    <= '0';
                    yellow <= '0';
                    counter  <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
            
            if stepflag = 3 then -- green blinking
                if counter = 0 then
                    green <= '0';
                    red <= '0';
                    yellow <= '0';
                end if;
                if counter = 50e6 then
                    green <= '1';
                end if;
                if counter = 100e6 then
                    green <= '0';
                end if;
                if counter = 150e6 then
                    green <= '1';
                end if;
                if counter = 200e6 then
                    green <= '0';
                end if;
                if counter = 250e6 then
                    green <= '1';
                end if;
                if counter = 300e6 then
                    green <= '0';
                    red <= '0';
                    yellow <= '0';
                    counter <= 0;
                    stepflag <= stepflag + 1;
                else
                    counter <= counter + 1;
                end if;
            end if;
            
            if stepflag = 4 then -- yellow
                red   <= '0';
                green <= '0';
                yellow <= '1';
                if counter = 200e6 then
                    stepflag <= 0;
                    red      <= '0';
                    green    <= '0';
                    yellow <= '0';
                    counter  <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;

        end if;
    end process;
end Behavioral;
