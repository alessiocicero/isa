library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity check_overflow_mult is
	port(Mult_result: IN signed(15 downto 0);
		 Mult1_MSB	:IN std_logic;
		 Mult2_MSB  :IN std_logic;
		 Output	:OUT signed (7 downto 0));
end entity check_overflow_mult;

architecture behavioural of check_overflow_mult is
begin
check_process:process(Mult_result,Mult1_MSB,Mult2_MSB)
	begin
	if (Mult1_MSB = '1' and Mult2_MSB = '1') then
		if (Mult_result(14) = '1') then
			Output <= "01111111";
		else
			Output <= Mult_result(14 downto 7);
		end if;
	else
			Output <= Mult_result(14 downto 7);
	end if;
end process;
end architecture behavioural;	
