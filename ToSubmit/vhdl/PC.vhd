library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
  port(
    clk          : in  std_logic;
    reset_n      : in  std_logic;
    en           : in  std_logic;
    sel_a        : in  std_logic;
    sel_imm      : in  std_logic;
    sel_ihandler : in  std_logic;
    add_imm      : in  std_logic;
    imm          : in  std_logic_vector(15 downto 0);
    a            : in  std_logic_vector(15 downto 0);
    addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is

  signal address : signed(15 downto 0);
  constant ihandler_address : signed(15 downto 0) := X"0004";

begin

  inc_address : process(clk, reset_n)
  begin
    if (reset_n = '0') then
      address <= X"0000";

    elsif rising_edge(clk) then
      if (en = '1') then
        if (add_imm = '1') then
          address <= address + signed(imm);
        elsif (sel_imm = '1') then
          address <= signed(imm(13 downto 0) & "00");
        elsif (sel_a = '1') then
          address <= signed(a);
        elsif (sel_ihandler = '1') then
          address <= ihandler_address;
        else
          address <= address + X"0004";
        end if;

      end if;
    end if;
  end process;  -- inc_address

  addr <= X"0000" & (std_logic_vector(address) and (X"FFF" & "1100"));



end synth;
