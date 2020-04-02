library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0)
    );
end control_registers;

architecture synth of control_registers is

signal s_stat, s_estat, s_bstat, s_iena, s_epnd: std_logic_vector(31 downto 0);

begin



write_clk: process(clk, reset_n, write_n)
    begin

        if(reset_n = '0') then
            s_stat <= X"00000000";
            s_estat <= X"00000000";
            s_bstat <= X"00000000";
            s_iena <= X"00000000";
        
        elsif(rising_edge(clk) and reset_n = '1') then
            if(backup_n /= '1') then
                s_estat <= s_stat;
                s_stat <= X"00000000";
            end if;
            if(restore_n /= '1') then
                s_stat <= s_estat;
            end if;
            if(write_n /= '1') then
                if(unsigned(address) = 0) then s_stat <= wrdata;
                elsif(unsigned(address) = 1) then s_estat <= wrdata;
                elsif(unsigned(address) = 2) then s_bstat(1) <= wrdata(1);
                elsif(unsigned(address) = 3) then s_iena <= wrdata;
                end if;
            end if;
        end if;
    end process;

rddata <= s_stat when unsigned(address) = 0 else
      s_estat when unsigned(address) = 1 else
      X"0000000" & "00" & s_bstat(0) & "0" when unsigned(address) = 2 else
      s_iena when unsigned(address) = 3 else
      s_epnd when unsigned(address) = 4;










s_epnd <= (s_iena and irq);
ipending <= '1' when s_stat /= X"00000000" and (s_epnd /= X"00000000")else '0';

    


end synth;