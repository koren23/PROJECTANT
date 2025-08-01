library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sources is
    port(
    clk : in std_logic; 
    led : out std_logic_vector(3 downto 0);
    btn : in std_logic
    );
end sources;

architecture Behavioral of sources is
    signal counter : unsigned(26 downto 0) := (others => '0');
    signal step_counter : integer range 0 to 4 := 0;
    signal running : boolean := false;
begin

    process(clk)
    begin
        if rising_edge(clk) then
        
            if btn = '1' then
                if not running then
                    running <= true;
                    step_counter <= 1;
                    counter <= (others => '0');
                end if;
            
            if running then
            
                if counter = 50e6 then
                    counter <= (others => '0');
                    
                    if step_counter < 4 then
                        step_counter <= step_counter + 1;
                    else
                        step_counter <= 1;
                    end if;
                    
                else
                    counter <= counter + 1;
                end if;              
            end if;
        else
            running <= false;
            step_counter <= 0;   
            counter <= (others => '0');
        end if;
    end if;
    end process;
    with step_counter select
        led <= "0000" when 0,
               "0001" when 1,
               "0010" when 2,
               "0100" when 3, 
               "1000" when 4,
               "0000" when others;
end Behavioral;
