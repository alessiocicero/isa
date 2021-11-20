library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb_check_overflow_sub is
end entity tb_check_overflow_sub;

architecture behavioural of tb_check_overflow_sub is
signal a1, a2 : STD_LOGIC;
signal res: signed(7 downto 0);
signal q: signed (7 downto 0);
component check_overflow_sub is
	port(Sub_result	:IN signed (7 downto 0);
		Add1_MSB: IN STD_LOGIC;
		Add2_MSB: IN STD_LOGIC;
		Output	:OUT signed (7 downto 0));
end component check_overflow_sub;
begin
a1 <= '0', '1' after 20 ns, '0' after 40 ns, '1' after 60 ns;
a2 <= '0', '0' after 20 ns, '1' after 40 ns, '1' after 60 ns;
res <= "10101010", "01101010" after 10 ns,"10101010" after 20 ns, 
		"01101010" after 30 ns,"10101010" after 40 ns, 
		"01101010" after 50 ns,"10101010" after 60 ns, 
		"01101010" after 70 ns;
chk: check_overflow_sub port map(Sub_result=>res,Add1_MSB=>a1,Add2_MSB => a2, Output=>q);
end architecture;

