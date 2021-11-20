LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
ENTITY muxnbit_2to1 IS
	GENERIC(N : INTEGER := 7);
	PORT(X,Y : IN SIGNED(N-1 DOWNTO 0);
		s: IN STD_LOGIC;
    	     M : OUT SIGNED(N-1 DOWNTO 0));				 
END ENTITY muxnbit_2to1;

ARCHITECTURE Behaviour OF muxnbit_2to1 IS

BEGIN
mux_process: process (X,Y)
	begin
		if s = '0' then
			M <= X;
		else
			M <= Y;
		end if;
	end process;
END ARCHITECTURE Behaviour;
