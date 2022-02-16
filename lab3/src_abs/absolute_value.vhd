library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity absolute_value is
  port (
	A : in std_logic_vector(31 downto 0) ;
	result : out std_logic_vector(31 downto 0)  -- result operation
  ) ;
end entity ; -- absolute_value

architecture rtl of absolute_value is


begin

--result	<= std_logic_vector(abs(signed(A)));

absolute : process( A )
begin
	if (A(31) = '0') then
		result <= A;
	else
		result <= std_logic_vector(not(signed(A)) + 1);
	end if ;
end process ; -- abs

end architecture ; -- rtl