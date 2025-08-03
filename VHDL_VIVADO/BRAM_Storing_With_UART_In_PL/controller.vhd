library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

        entity controller is
            Port (
                clk, datareadyin : in std_logic;
                din, dbramin           : in std_logic_vector(7 downto 0);
                enaout, weaout, writestartout : out std_logic;
                addressout, dbramout, dout  : out std_logic_vector(7 downto 0)
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
                     writestartout <= '0';
                     if(datareadyin = '1' and prevdataready = '0') then
                     
                         case datastate is
                            when 0 =>
                                action <= read;
                                enaout <= '0';
                                weaout <= '0';
                                writestartout <= '0';  
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
                     
                     
                     
                     if(signaldone = '1') then
                        if(action = read) then
                            startdelaytx <= '1';
                            addressout <= tempaddr;
                            dout <= dbramin;
                        else -- write
                                addressout <= tempaddr;
                                dbramout <= tempdata;
                                enaout <= '1'; -- general enable
                                weaout <= '1'; -- enable write
                        end if;
                        signaldone <= '0';
                     end if;
                     
                     if(startdelaytx = '1') then
                        if(counter = 2) then    
                            writestartout <= '1'; -- tx starts writing
                            enaout <= '1';
                            weaout <= '0';
                            counter <= 0;
                            startdelaytx <= '0';
                        else
                            counter <= counter + 1;
                            startdelaytx <= '1';
                        end if;
                     end if;
                     prevdataready <= datareadyin;
                 end if;
            end process;
        end Behavioral;
