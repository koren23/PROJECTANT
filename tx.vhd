library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    
    entity Transmiter is
        generic (
            stop_bit_length : integer := 1;  -- 1=1 baud, 2=1.5 baud, 3=2 baud
            BaudRate : integer := 115200;
            Clock_Freq : integer := 100e4
        );
        port (
            clk  : in std_logic;
            tx   : out std_logic;
            flag : in std_logic; -- sent by rx to start
            databyte : in std_logic_vector(7 downto 0) -- data sent by rx
        );
    end Transmiter;
    
    architecture Behavioral of Transmiter is
        type statetype is (idle, start, data, stop);
        signal state : statetype := idle;
        signal counter : integer range 0 to 868 := 0;
        signal sentflag : boolean := false;
        signal stopcount : integer range 0 to 1 := 0;
        signal Bit_counting_value : integer := (100*Clk_Freq)/BaudRate;
        signal bit_number : integer range 0 to 7 := 0; -- location of bit being sent
    begin
        process(clk)
        begin
            if rising_edge(clk) then
                case state is
                
                    when idle => -- sends 1 until flag=1 sentflag=false and one bit passed since
                        tx <= '1';
                        sentflag <= false;
                            if flag = '1' and not sentflag then
                                if counter = Bit_counting_value then
                                    state <= start;
                                    sentflag <= true;
                                else
                                    counter <= counter + 1;
                                end if;
                            end if;
    
                        when start =>
                            if counter = Bit_counting_value then
                                tx <= '0';
                                bit_number <= 0;
                                state <= data;
                            else
                                counter <= counter + 1;
                            end if;
    
                        when data =>
                            if counter = Bit_counting_value then
                                tx <= databyte(bit_number);
                                if bit_number = 7 then
                                    stopcount <= 0;
                                    state <= stop;
                                else
                                    bit_number <= bit_number + 1;
                                end if;
                            else
                                counter <= counter + 1;
                            end if;
                            
                        when stop =>
                            tx <= '1';
                            case stop_bit_length is
                            
                            when 3 =>
                                if stopcount = 1 then
                                    state <= idle;
                                    sentflag <= false;
                                else
                                    stopcount <= stopcount + 1;
                                end if;
                                
                            when 2 => if stopcount = 1 then
                                    if counter = Bit_counting_value then
                                            state <= idle;
                                            sentflag <= false;
                                        elsif stopcount = 1 then
                                            stopcount <= stopcount + 1;
                                        else
                                            stopcount <= stopcount + 1;
                                        end if;
                                    else 
                                        counter <= counter + 1;
                                    end if;
                                    
                            when others =>
                                state <= idle;
                                sentflag <= false;        
                    end case;
                end case;
            end if;
        end process;
    end Behavioral;