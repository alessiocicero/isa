library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb_mult_signed is
end entity;

architecture behavioural of tb_mult_signed is
signal m1,m2,fixed_point_res,saturated_res: signed (7 downto 0);
signal res: signed (15 downto 0);

component check_overflow_mult is
	port(Mult_result: IN signed(15 downto 0);
		 Mult1_MSB	:IN std_logic;
		 Mult2_MSB  :IN std_logic;
		 Output	:OUT signed (7 downto 0));
end component check_overflow_mult;

begin
m1 <= "01111111", "10000000" after 20 ns, "01111111" after 40 ns, "10000000" after 60 ns;
m2 <= "01111111", "10000000" after 40 ns;
res <= m1 * m2;
fixed_point_res <= res(14 downto 7);
sat: check_overflow_mult port map(Mult_result => res, Mult1_MSB => m1(7), Mult2_MSB => m2(7), Output => saturated_res);

end architecture;
