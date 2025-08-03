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
		type datastatetype is (startbyte,databyte,stoptestbyte,finalstopbyte);
        signal action        : actiontype := read;
        signal datastate     : datastatetype                :=startbyte;
        signal tempdata      : std_logic_vector(7 downto 0) := (others => '0');
        signal tempaddr      : std_logic_vector(7 downto 0) := (others => '0');
        signal prevdataready : std_logic                    :='0';
        signal signaldone    : std_logic                    :='0';
        signal counter       : integer range 0 to 2         :=0;
        signal startdelaytx  : std_logic                    :='0';
        begin
            process(clk)
                begin
                if rising_edge(clk) then
                     if(datareadyin = '1' and prevdataready = '0') then
	-- 	rising edge of datareadyin coming from rx
                     
                         case datastate is
                            when startbyte => -- looking for *
                                action <= read; -- default
                                enaout <= '0'; -- disabling BRAM
                                weaout <= '0';
                                if(din = "00101010") then -- means *
                                    datastate <= databyte;
                                end if;
                            when databyte => -- saving address
                                tempaddr <= din; -- address 
                                datastate <= stoptestbyte;
                            when stoptestbyte => -- stop bit or continue 
                                if(din = "00100011") then -- means #
                                    datastate <= startbyte;
                                    signaldone <= '1'; --start reading
									action <= read;
                                else -- data
                                    tempdata <= din;
									datastate <= finalstopbyte;
								end if;
							when finalstopbyte =>
								datastate <= startbyte; -- start state case all over again
								if(din = "00100011") then -- means #
									action <= write;
									signaldone <= '1'; --start writing
                                end if;
                        end case;
                        
                     end if;
                     
                     if(signaldone = '1') then -- finished with state case
                        if(action = read) then
                            startdelaytx <= '1'; -- starts delay
							enaout <= '1';-- general enable
                            weaout <= '0'; -- disable write (reads)
                            addressout <= tempaddr;	-- exports address to BRAM
                            dout <= dbramin; -- exports data to tx
                        else -- write
                                addressout <= tempaddr; -- exports address to BRAM
                                dbramout <= tempdata; -- exports data to BRAM
                                enaout <= '1'; -- general enable
                                weaout <= '1'; -- enable write
                        end if;
                        signaldone <= '0'; -- resetting when done 
                     end if;
                     
                     if(startdelaytx = '1') then -- need to delay writestartout a little 
                        if(counter = 2) then  -- delay for 2 clock counts (1 might work)  
                            writestartout <= '1'; -- tx starts writing
                            counter <= 0;
                            startdelaytx <= '0'; -- reset the entire if loop
                        else
                            counter <= counter + 1;
                        end if;
					 else
						writestartout <= '0'; -- tx doesnt write until startdelaytx = '1'
                     end if;
                     prevdataready <= datareadyin; -- updating datareadyin to notice rising edge pattern
                 end if;
            end process;
        end Behavioral;
