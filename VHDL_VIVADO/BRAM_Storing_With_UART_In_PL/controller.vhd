library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

        entity controller is
            Port (
                clk, dataready : in std_logic;
                din, douta           : in std_logic_vector(7 downto 0);
                ena, wea, writestart : out std_logic;
                address, dina, dout  : out std_logic_vector(7 downto 0)
            );
        end controller;
        
        architecture Behavioral of controller is
        type actiontype is (write, read);
        signal action        : actiontype := read;
        signal tempdata      : std_logic_vector(7 downto 0) :="00000000";
        signal tempaddr      : std_logic_vector(7 downto 0) :="00000000";
        signal datastate     : integer range 0 to 2         :=0;
        signal prevdataready : std_logic                    :='0';
        signal signaldone    : std_logic                    :='0';
        signal counter       : integer range 0 to 2         :=0;
        signal startdelaytx  : std_logic                    :='0';
        begin
            process(clk)
                begin
                if rising_edge(clk) then
                     writestart <= '0';
                     if(dataready = '1' and prevdataready = '0') then
                         case datastate is
                            when 0 =>
                                action <= read;
                                ena <= '0';
                                wea <= '0';
                                writestart <= '0';  
                                if(din = "00101010") then -- means *
                                    datastate <= 1;
                                end if;
                            when 1 =>
                                tempaddr <= din;
                                datastate <= 2;
                            when 2 =>
                                if(din = "00100011") then -- means #
                                    datastate <= 0;
                                    signaldone <= '1';
                                else
                                    tempdata <= din;
                                    action <= write;
                                end if;
                                signaldone <= '1';
                        end case;
                     end if;
                     if(startdelaytx = '1') then
                        if(counter = 2) then    
                            writestart <= '1'; -- tx starts writing
                            counter <= 0;
                            startdelaytx <= '0';
                        else
                            counter <= counter + 1;
                        end if;
                     end if;
                     if(signaldone = '1') then
                        if(action = read) then
                            startdelaytx <= '1';
                            ena <= '1';
                            wea <= '0';
                            address <= tempaddr;
                            dout <= douta;
                        else -- write
                                address <= tempaddr;
                                dina <= tempdata;
                                ena <= '1'; -- general enable
                                wea <= '1'; -- enable write
                        end if;
                        signaldone <= '0';
                     end if;
                     prevdataready <= dataready;
                 end if;
            end process;
        end Behavioral;
