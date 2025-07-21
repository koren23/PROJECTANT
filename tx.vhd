library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Transmiter is
    generic (
        stop_bit_length : integer := 1;  -- 1=1 baud, 2=1.5 baud, 3=2 baud
        BaudRate        : integer := 115200;
        Clk_Freq        : integer := 100e6
    );
    port (
        clk      : in std_logic;
        tx       : out std_logic;
        flag     : in std_logic; -- sent by rx to start
        databyte : in std_logic_vector(7 downto 0); -- data sent by rx
        stateflag     : out std_logic_vector(1 downto 0) -- 00 idle 01 start 10 data 11 stop
    );
end Transmiter;

architecture Behavioral of Transmiter is
    type statetype is (idle, start, data, stop);
    signal state              : statetype                    := idle;
    signal counter            : integer range 0 to 868       := 0;
    signal tempbyte           : std_logic_vector(7 downto 0) := "00000000";
    signal stopcount          : integer range 0 to 3         := 0; -- Extended range for different stop lengths
    signal bit_counting_value : integer                      := Clk_Freq/BaudRate;
    signal bit_number         : integer range 0 to 7         := 0; -- Location of bit being sent
    signal flag_prev          : std_logic                    := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
            
                when idle =>
                    stateflag <= "00";
                    if flag = '1' and flag_prev = '0' then -- makes sure it only works when flag rises
                        tempbyte <= databyte; -- saves data in a temp
                        state <= start;
                    else
                        tx <= '1'; -- idle value is 1
                    end if;
                    flag_prev <= flag;
                            
                when start =>
                    stateflag <= "01";
                        state <= data;
                        Bit_number <= 0;
                        counter <= 0;
                        tx <= '0';
                   
                when data =>
                    stateflag <= "10";
                    if bit_number = 7 then
                        if counter = bit_counting_value then
                            tx <= tempbyte(bit_number);
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                        state <= stop;
                    else
                        bit_number <= bit_number + 1;
                    end if;
                    
                    
                when stop =>
                    stateflag <= "11";
                    case stop_bit_length is
                        
                        when 3 =>
                        if counter = bit_counting_value + bit_counting_value then
                            state <= idle;
                            counter <= 0;
                        else
                            tx <= '1';
                            counter <= counter +1;
                        end if;
                        
                        when 2 =>
                        if counter = bit_counting_value/2 + bit_counting_value then
                            state <= idle;
                            counter <= 0;
                        else
                            tx <= '1';
                            counter <= counter +1;
                        end if;
                        
                        when others =>
                        if counter = bit_counting_value then
                            state <= idle;
                            counter <= 0;
                        else
                            tx <= '1';
                            counter <= counter +1;
                        end if;
                        
                    end case;
            end case;
        end if;
    end process;
end Behavioral;
