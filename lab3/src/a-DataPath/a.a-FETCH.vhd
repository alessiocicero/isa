library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity fetch_stage is
	port( 	   
				clk:   in std_logic;
			   rst_n : in std_logic;
		  branch_sel : in std_logic;
		     PCWrite : in std_logic;
		pc_jump_addr : in std_logic_vector((IRAM_ADDRESS_LENGTH-1) downto 0);
			  pc_out : out std_logic_vector((IRAM_ADDRESS_LENGTH-1) downto 0)
 	   );
end entity fetch_stage;

architecture rtl of fetch_stage is

component regn_ld IS
	GENERIC ( N : integer := 8);
	PORT (R 	    : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	      Clock, Resetn, Load : IN STD_LOGIC;
	      Q 	    : BUFFER STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END component;

signal pc_in,pc_next_addr,pc_reg_out : std_logic_vector((IRAM_ADDRESS_LENGTH-1) downto 0);

begin
mux_process : process (branch_sel,pc_next_addr,pc_jump_addr)
begin

	if(branch_sel = '0') then
		pc_in <= pc_next_addr;
    else
    	pc_in <= pc_jump_addr;
    end if;

end process;

PC : regn_ld 
	generic map(
		N => IRAM_ADDRESS_LENGTH) 
	port map(
		R => pc_in, 
		Clock => clk, 
		Resetn => rst_n, 
		Load => PCWrite, 
		Q => pc_reg_out);

pc_next_addr <= std_logic_vector(unsigned(pc_reg_out) + 4);
pc_out <= pc_reg_out;
end architecture rtl;
