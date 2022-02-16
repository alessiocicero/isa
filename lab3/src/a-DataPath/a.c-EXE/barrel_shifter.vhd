library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity barrel_shifter is
  port (
	Rs 	   : in std_logic_vector(31 downto 0) ; -- operand to be shifted
	sh_amt : in std_logic_vector(31 downto 0) ; -- shift amount
	result : out std_logic_vector(31 downto 0)  -- result operation
  ) ;
end entity ; -- barrel_shifter

architecture rtl of barrel_shifter is

begin

process( sh_amt,Rs )
variable sh_amt_var : integer;
begin
	sh_amt_var := to_integer(unsigned(sh_amt));

	case sh_amt_var is
     when  0  =>
         result( 31  downto  0 ) <= Rs(31 downto  0 );
     when  1  =>
         result( 30  downto  0 ) <= Rs(31 downto  1 );
         result(31) <= Rs(31);
     when  2  =>
         result( 29  downto  0 ) <= Rs(31 downto  2 );
         result(31 downto  30 ) <= (others => Rs(31));
     when  3  =>
         result( 28  downto  0 ) <= Rs(31 downto  3 );
         result(31 downto  29 ) <= (others => Rs(31));
     when  4  =>
         result( 27  downto  0 ) <= Rs(31 downto  4 );
         result(31 downto  28 ) <= (others => Rs(31));
     when  5  =>
         result( 26  downto  0 ) <= Rs(31 downto  5 );
         result(31 downto  27 ) <= (others => Rs(31));
     when  6  =>
         result( 25  downto  0 ) <= Rs(31 downto  6 );
         result(31 downto  26 ) <= (others => Rs(31));
     when  7  =>
         result( 24  downto  0 ) <= Rs(31 downto  7 );
         result(31 downto  25 ) <= (others => Rs(31));
     when  8  =>
         result( 23  downto  0 ) <= Rs(31 downto  8 );
         result(31 downto  24 ) <= (others => Rs(31));
     when  9  =>
         result( 22  downto  0 ) <= Rs(31 downto  9 );
         result(31 downto  23 ) <= (others => Rs(31));
     when  10  =>
         result( 21  downto  0 ) <= Rs(31 downto  10 );
         result(31 downto  22 ) <= (others => Rs(31));
     when  11  =>
         result( 20  downto  0 ) <= Rs(31 downto  11 );
         result(31 downto  21 ) <= (others => Rs(31));
     when  12  =>
         result( 19  downto  0 ) <= Rs(31 downto  12 );
         result(31 downto  20 ) <= (others => Rs(31));
     when  13  =>
         result( 18  downto  0 ) <= Rs(31 downto  13 );
         result(31 downto  19 ) <= (others => Rs(31));
     when  14  =>
         result( 17  downto  0 ) <= Rs(31 downto  14 );
         result(31 downto  18 ) <= (others => Rs(31));
     when  15  =>
         result( 16  downto  0 ) <= Rs(31 downto  15 );
         result(31 downto  17 ) <= (others => Rs(31));
     when  16  =>
         result( 15  downto  0 ) <= Rs(31 downto  16 );
         result(31 downto  16 ) <= (others => Rs(31));
     when  17  =>
         result( 14  downto  0 ) <= Rs(31 downto  17 );
         result(31 downto  15 ) <= (others => Rs(31));
     when  18  =>
         result( 13  downto  0 ) <= Rs(31 downto  18 );
         result(31 downto  14 ) <= (others => Rs(31));
     when  19  =>
         result( 12  downto  0 ) <= Rs(31 downto  19 );
         result(31 downto  13 ) <= (others => Rs(31));
     when  20  =>
         result( 11  downto  0 ) <= Rs(31 downto  20 );
         result(31 downto  12 ) <= (others => Rs(31));
     when  21  =>
         result( 10  downto  0 ) <= Rs(31 downto  21 );
         result(31 downto  11 ) <= (others => Rs(31));
     when  22  =>
         result( 9  downto  0 ) <= Rs(31 downto  22 );
         result(31 downto  10 ) <= (others => Rs(31));
     when  23  =>
         result( 8  downto  0 ) <= Rs(31 downto  23 );
         result(31 downto  9 ) <= (others => Rs(31));
     when  24  =>
         result( 7  downto  0 ) <= Rs(31 downto  24 );
         result(31 downto  8 ) <= (others => Rs(31));
     when  25  =>
         result( 6  downto  0 ) <= Rs(31 downto  25 );
         result(31 downto  7 ) <= (others => Rs(31));
     when  26  =>
         result( 5  downto  0 ) <= Rs(31 downto  26 );
         result(31 downto  6 ) <= (others => Rs(31));
     when  27  =>
         result( 4  downto  0 ) <= Rs(31 downto  27 );
         result(31 downto  5 ) <= (others => Rs(31));
     when  28  =>
         result( 3  downto  0 ) <= Rs(31 downto  28 );
         result(31 downto  4 ) <= (others => Rs(31));
     when  29  =>
         result( 2  downto  0 ) <= Rs(31 downto  29 );
         result(31 downto  3 ) <= (others => Rs(31));
     when  30  =>
         result( 1  downto  0 ) <= Rs(31 downto  30 );
         result(31 downto  2 ) <= (others => Rs(31));
     when  31  =>
         result(0) <= Rs(31);
         result(31 downto  1 ) <= (others => Rs(31));
     when others => result <= (others => '0');
end case;
	
end process ; -- 

--BS_async : process( sh_amt,Rs )
--
--begin
--
--	shifter_array : for i in 0 to 31 loop
--
--	if (i+to_integer(unsigned(sh_amt))<32) then
--		result(i) <= Rs(i + to_integer(unsigned(sh_amt)));
--	else
--		result(i) <= Rs(31);
--	end if;
--	
--	end loop shifter_array; -- shifter_array
--
--end process ; -- BS_async

end architecture ; -- rtl