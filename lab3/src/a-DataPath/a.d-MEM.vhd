library ieee;
use ieee.std_logic_1164.all;

entity memory_stage is
  port (
	zero_mem_pip 		: in std_logic;
	branch_mem_pip 	: in std_logic;
	jump_sel				: in std_logic;
	branch_sel 			: out std_logic
  ) ;
end entity ; -- memory_stage

architecture rtl of memory_stage is

begin

branch_sel <= (zero_mem_pip and branch_mem_pip) or jump_sel;

end architecture ; -- rtl