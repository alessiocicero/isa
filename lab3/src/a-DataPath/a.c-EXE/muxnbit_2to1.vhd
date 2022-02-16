LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY muxnbit_2to1 IS
	GENERIC(N : INTEGER := 7);
	PORT(X,Y : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		s: IN STD_LOGIC;
    	     M : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));				 
END ENTITY muxnbit_2to1;

ARCHITECTURE Behaviour OF muxnbit_2to1 IS

COMPONENT mux2to1 IS
	PORT(x,y,s : IN STD_LOGIC;
    	     m : OUT STD_LOGIC);				 
END COMPONENT mux2to1;

BEGIN

mux : FOR i IN 0 TO N-1 GENERATE
	muxn : mux2to1 PORT MAP(x => X(i), y => Y(i), s => s, m => M(i));
END GENERATE;

END ARCHITECTURE Behaviour;
