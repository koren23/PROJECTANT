library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity Receiver is
    generic (
        BaudRate : integer := 115200;
        Clk_Freq : integer := 100e4
    );
    port(
        clk           : in  std_logic; -- clock coming from clock wizard (100MHZ)
        rx            : in std_logic;-- rx coming from io0 external
        output_vector : out std_logic_vector(7 downto 0);-- vector of 8 bits rx output
        flag          : out std_logic-- flag sent to tx means - start sending data
        );
end Receiver;

architecture Behavioral of Receiver is
    type statetype is (idle, start, data, stop);
    signal state              : statetype                    := idle;
	signal Bit_counting_value : integer                      := (100*Clk_Freq)/BaudRate;
    signal counter            : integer range 0 to 868       :=0; -- counting to 1 Bit in 115200 Baudrate 
    signal tempdata           : std_logic_vector(7 downto 0) := (others => '0'); -- tempdata saving before releasing to tx
	signal bit_number         : integer range 0 to 7         := 0; -- current rx to vector location
	signal temporaryrx        : std_logic;
begin
    process(clk)
    begin
        temporaryrx <= rx;
        flag <= '0'; -- tells tx to not send data yet/anymore
        if rising_edge(clk) then
    		case state is
			
				when idle => -- expecting rx 1 does nothing untill drops to 0
				    if temporaryrx = '0' then
				        if counter = Bit_counting_value / 2 then   -- waits half a bit
                            counter <= 0;
                            state <= start;
                        else
                            counter <= counter + 1;
                        end if;
                    end if;
                    
				when start => -- waits one bit and resets everything
				    if counter = Bit_counting_value then
                        counter <= 0;
                        state <= data;
					    bit_number <= 0;
					    flag <= '0';
                    else
                        counter <= counter + 1;
                    end if;
                    
				when data => -- repeats 8 times
				    if counter = Bit_counting_value then -- one bit passed
                        counter <= 0;
                        tempdata(bit_number) <= temporaryrx;
					   if bit_number = 7 then
				    		state <= stop;
					   else
						  bit_number <= bit_number + 1;
					   end if;
                    else
                        counter <= counter + 1;
                    end if;
					
				when stop => -- waits one bit to reset and send output on stopbit
				    if counter = Bit_counting_value then
                        counter <= 0;
                        if temporaryrx = '1' then
					       output_vector <= tempdata;
						   flag <= '1';
					    end if;
					    state <= idle;
                    else
                        counter <= counter + 1;
                    end if;
                    
			end case;
        end if;
    end process;
end Behavioral;
