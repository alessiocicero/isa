library ieee;
library work;
use ieee.std_logic_1164.all;

package pp_array_pkg is
	type ppmatrix is array (16 downto 0) of std_logic_vector(36 downto 0);
end package;
