LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY regn_ld IS
	GENERIC ( N : integer := 8);
	PORT (R 	    : IN signed(N-1 DOWNTO 0);
	      Clock, Resetn, Load : IN STD_LOGIC;
	      Q 	    : out signed(N-1 DOWNTO 0));
END regn_ld;

ARCHITECTURE Behavior OF regn_ld IS

signal feedback : signed(N-1 downto 0);

BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
		  IF (Resetn = '0') THEN
			 feedback <= (OTHERS => '0');
			ELSIF(Load = '1') THEN
			 feedback <= R;
			ELSE
			 feedback <= feedback;
			END IF;
		END IF;
	END PROCESS;

	Q <= feedback;

END Behavior;
