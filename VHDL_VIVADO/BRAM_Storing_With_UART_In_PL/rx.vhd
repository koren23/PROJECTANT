library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Receiver is
    generic (
        BaudRate : integer := 115200;
        Clk_Freq : integer := 100e6  -- 100 MHz clock
    );
    port (
        clk  : in  std_logic;         -- clock coming from clock wizard (100 MHz)
        rx   : in  std_logic;         -- rx coming from io0 external
        din  : out std_logic_vector(7 downto 0); -- vector of 8 bits rx output
        dataready : out std_logic -- sent to controller
    );
end Receiver;

architecture Behavioral of Receiver is
    type statetype is (idle, start, data, stop);
    signal state              : statetype                             := idle;
  constant Bit_counting_value : integer                               := Clk_Freq / BaudRate;  -- Correct bit counting formula
    signal counter            : integer range 0 to Bit_counting_value := 0;     -- Count up to the baud rate
    signal tempdata           : std_logic_vector(7 downto 0) := (others => '0');  -- Temp data storage
    signal bit_number         : integer range 0 to 7 := 0;       -- Current bit number
    signal rx_sync            : std_logic := '1';  -- Synchronized rx signal
    signal rx_prev            : std_logic := '1';  -- Previous rx value to detect falling edge

begin
    process(clk)
    begin
        if rising_edge(clk) then
            rx_prev <= rx_sync;      -- Store previous rx value
            rx_sync <= rx;           -- Synchronize rx with clock

            case state is
                -- Waiting for falling edge of start bit (rx goes from '1' to '0')
                when idle =>
                    dataready <= '0';
                    if rx_prev = '1' and rx_sync = '0' then -- Falling edge detected
                        counter <= 0;
                        state <= start;
                    end if;

                -- Half bit duration to avoid noise (start bit detection)
                when start =>
                    if counter = Bit_counting_value /2 then
                        counter <= 0;
                        bit_number <= 0;
                        state <= data;
                    else
                        counter <= counter + 1;
                    end if;

                -- Receiving 8 data bits (one at a time)
                when data =>
                    if counter = Bit_counting_value then
                        counter <= 0;
                        tempdata(bit_number) <= rx_sync;  -- Store received bit in tempdata                       
                        -- Check if all 8 bits have been received
                        if bit_number = 7 then
                            state <= stop;  -- Move to stop bit state
                        else
                            bit_number <= bit_number + 1;
                        end if;
                    else
                        counter <= counter + 1;
                    end if;

                -- Checking the stop bit (should be '1')
                when stop =>
                    if counter = Bit_counting_value then
                        counter <= 0;
                        if rx_sync = '1' then  -- Valid stop bit
                            din <= tempdata;  -- Output the received data
                            dataready <= '1';
                        end if;
                        state <= idle;  -- Reset back to idle state
                    else
                        counter <= counter + 1;
                    end if;

            end case;
        end if;
    end process;
end Behavioral;
