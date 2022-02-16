library ieee;
use ieee.std_logic_1164.all;

entity writeback_stage is
	port(	data_memory_out:		in std_logic_vector(31 downto 0);
			data_memory_bypass: in std_logic_vector(31 downto 0);
			mem_to_reg 		  :	in std_logic;
			writeback_data_out:	out std_logic_vector(31 downto 0));
end entity writeback_stage;

architecture rtl of writeback_stage is

begin

mux : process( mem_to_reg, data_memory_out, data_memory_bypass)
begin
	if (mem_to_reg = '0') then
		writeback_data_out <= data_memory_out;
	else
		writeback_data_out <= data_memory_bypass;
	end if ;
end process ; -- mux

end architecture rtl;
