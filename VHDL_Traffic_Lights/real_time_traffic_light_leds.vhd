library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sources is
    port(
        clk   : in  std_logic; 
        red   : out std_logic;
        green : out std_logic
    );
end sources;

architecture Behavioral of sources is
    signal counter     : integer := 0;
    signal stepflag    : integer range 0 to 3 := 0;
    signal intmaxflag  : integer range 0 to 3 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
        
            if stepflag = 0 then -- red
                red   <= '1';
                green <= '0';
                
                if intmaxflag < 3 then
                    if counter = 2e9 then
                        counter     <= 0;
                        intmaxflag  <= intmaxflag + 1;
                    else
                        counter <= counter + 1;
                    end if;
                else
                    counter     <= 0;
                    stepflag    <= stepflag + 1;
                    red         <= '0';
                    intmaxflag  <= 0;
                end if;
            end if;

            if stepflag = 1 then -- yellow
                red   <= '1';
                green <= '1';

                if counter = 300e6 then
                    stepflag <= stepflag + 1;
                    red      <= '0';
                    green    <= '0';
                    counter  <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;

            if stepflag = 2 then -- green regular
                red   <= '0';
                green <= '1';

                if intmaxflag = 0 then
                    if counter = 2e9 then
                        green      <= '0';
                        intmaxflag <= intmaxflag + 1;
                        counter    <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                else
                    if counter = 400e6 then
                        stepflag    <= stepflag + 1;
                        red         <= '0';
                        green       <= '0';
                        intmaxflag  <= 0;
                        counter     <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                end if;
            end if;

            if stepflag = 3 then -- green blinking
                case counter is
                    when 0         => green <= '0'; red <= '0';
                    when 50e6  => green <= '1';
                    when 100e6 => green <= '0';
                    when 150e6 => green <= '1';
                    when 200e6 => green <= '0';
                    when 250e6 => green <= '1';
                    when 300e6 =>
                        green      <= '0';
                        red        <= '0';
                        counter    <= 0;
                        stepflag   <= 0;
                        intmaxflag <= 0;
                    when others =>
                        counter <= counter + 1;
                end case;
            end if;

        end if;
    end process;
end Behavioral;
