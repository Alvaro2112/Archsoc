

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;
architecture synth of timer is
type reg_map is array ( 0 to 3) of std_logic_vector (31 downto 0);
signal reg : reg_map := ((others=> (others=>'0')));
signal ltcy_read: std_logic;
signal ltcy_cs: std_logic;
signal ltcy_addr: std_logic_vector (1 downto 0);
begin
    ecrire : PROCESS(reset_n,clk)
    begin
        if(reset_n  /= '1') then
            reg <=     ((others=> (others=>'0')));
        elsif(rising_edge(clk)) then
            if (unsigned(reg(0)) = 0 and reg(3)(0) /= '0') then
                reg(3)( 1 downto 0 )<=  '1'&reg(2)(0) ;
                reg(0) <= reg(1);
            elsif( reg(3)(0) /= '0') then
                reg(0) <= std_logic_vector(unsigned(reg(0)) - 1);
            end if;
            if( cs /= '0') then
                if(write /= '0') then
                    if( address = "11") then
                        reg(3)(1) <=  ( not wrdata(1) nor (not reg(3)(1)));
      end if;
                    if( address = "10" ) then
                        reg(2)( 3 downto 0) <= wrdata( 3 downto 0);
                        if (wrdata(2) = '1') then
                            reg(3)(0) <= '0';
                        else
                            reg(3)(0) <= '1';
   end if;
      end if;
                    if( address = "01") then
                        reg(1) <= wrdata; 
                        reg(0) <= wrdata;
                        reg(3)(0) <= '0';
                    end if;
                end if;
            end if;
        end if;
 
    if(rising_edge(clk)) then
        ltcy_addr <= address;
        ltcy_cs <= cs;
        ltcy_read <= read;
    end if;   
    end process;

    rddata <= (OTHERS => 'Z') when ((ltcy_read and ltcy_cs) /= '1') else
        reg(0) when ltcy_addr = "00" else
        reg(1) when ltcy_addr = "01" else
        X"0000000" & "00" & reg(3)(1) & reg(3)(0) when ltcy_addr = "11" else  -- peut etre faux
        X"0000000" & "00" & reg(2)(1)& reg(2)(0); -- peut etre faux
    irq <= reg(3)(1) and reg(2)(1);
end synth;     
