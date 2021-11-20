library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity check_overflow_add is
	port(Add_result	:IN signed (7 downto 0);
		Add1_MSB: IN STD_LOGIC;
		Add2_MSB: IN STD_LOGIC;
		Output	:OUT signed (7 downto 0));
end entity check_overflow_add;

architecture behavioural of check_overflow_add is
begin
check_process: process(Add_result, Add1_MSB, Add2_MSB)
	begin
	if (Add1_MSB = '0' AND Add2_MSB = '0') then
		if(Add_result(7) = '1') then
			Output <= "01111111";
		else
			Output <= Add_result(7 downto 0);
		end if;
	elsif(Add1_MSB = '1' AND Add2_MSB = '1') then
		if(Add_result(7) = '0') then
			Output <= "10000000";
		else
			Output <= Add_result(7 downto 0);
		end if;
	else
		Output <= Add_result(7 downto 0);
	end if;
end process;
		

end architecture behavioural;	
