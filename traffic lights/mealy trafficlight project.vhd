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
    signal state : integer range 0 to 9;
    signal blinkled : std_logic := '0';
    signal blinkcount : integer range 0 to 6;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when 0 =>
                    if counter = 500e6 then
                        state <= 1;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 1 =>
                    if counter = 200e6 then
                        state <= 2;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 2 =>
                    if counter = 400e6 then
                        state <= 3;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 3 =>
                    if counter = 50e6 then
                        state <= 4;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 4 =>
                    if counter = 50e6 then
                        state <= 5;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 5 =>
                    if counter = 50e6 then
                        state <= 6;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 6 =>
                    if counter = 50e6 then
                        state <= 7;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;    
                when 7 =>
                    if counter = 50e6 then
                        state <= 8;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                when 8 =>
                    if counter = 50e6 then
                        state <= 9;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;  
                when 9 =>
                    if counter = 200e6 then
                        state <= 0;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
            end case;
        end if;
    end process;
    with state select
    leds <= "100" when 0,
            "111" when 1,
            "010" when 2,
            "000" when 3,
            "010" when 4,
            "000" when 5,
            "010" when 6,
            "000" when 7,
            "010" when 8,
            "011" when 9;
            
end Behavioral;