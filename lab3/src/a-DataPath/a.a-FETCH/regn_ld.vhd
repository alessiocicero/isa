LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY regn_ld IS
	GENERIC ( N : integer := 8);
	PORT (R 	    : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	      Clock, Resetn, Load : IN STD_LOGIC;
	      Q 	    : BUFFER STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END regn_ld;

ARCHITECTURE Behavior OF regn_ld IS

BEGIN
	PROCESS (Clock)
	BEGIN
		IF (Clock'EVENT AND Clock = '1') THEN
		  IF (Resetn = '0') THEN
			 Q <= (OTHERS => '0');
			ELSIF(Load = '1') THEN
			 Q <= R;
			ELSE
			 Q <= Q;
			END IF;
		END IF;
	END PROCESS;

END Behavior;
