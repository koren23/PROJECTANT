library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sources is
    port(
        clk   : in  std_logic; 
        leds : out std_logic_vector(2 downto 0) 
    );
end sources;

architecture Behavioral of sources is
    signal counter     : integer := 0;
    signal stepflag    : integer range 0 to 4 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            case stepflag is 
            
                when 0 => -- red
                    leds <= "100";
                    if counter = 500e6 then
                        stepflag <= stepflag + 1;
                        leds <= "000";
                        counter  <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when 1 => -- red yellow
                    leds <= "111";
                    if counter = 200e6 then
                        stepflag <= stepflag + 1;
                        leds <= "000";
                        counter  <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when 2 => -- green
                    leds <= "010";
                    if counter = 400e6 then
                        stepflag <= stepflag + 1;
                        leds <= "000";
                        counter  <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when 3 => -- green blinking
                    if counter = 0 then
                        leds <= "000";
                    end if;
                    if counter = 50e6 then
                        leds <= "010";
                    end if;
                    if counter = 100e6 then
                        leds <= "000";
                    end if;
                    if counter = 150e6 then
                        leds <= "010";
                    end if;
                    if counter = 200e6 then
                        leds <= "000";
                    end if;
                    if counter = 250e6 then
                        leds <= "010";
                    end if;
                    if counter = 300e6 then
                        leds <= "000";
                        counter <= 0;
                        stepflag <= stepflag + 1;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when 4 => -- yellow
                    leds <= "011";
                    if counter = 200e6 then
                        stepflag <= 0;
                        leds <= "000";
                        counter  <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                
            end case;
        end if;
    end process;
end Behavioral;