library ieee;
use ieee.std_logic_1164.all;

entity muxnbit_4to1 is
	generic(N : integer := 7);
	port(
		X,Y,Z,Q : in std_logic_vector(N-1 downto 0);
		  	  s : in std_logic_vector(1 downto 0);
    	  	  M : out std_logic_vector(N-1 downto 0)) ;
end entity ; -- muxnbit_4to1

architecture rtl of muxnbit_4to1 is

begin

mux : process( s,X,Y,Z,Q )
begin
	case( s ) is
	
		when "00" => M <= X;

		when "01" => M <= Y;

		when "10" => M <= Z;

		when "11" => M <= Q;
	
		when others =>
	
	end case ;
end process ; -- mux

end architecture ; -- rtl