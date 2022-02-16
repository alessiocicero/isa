LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux2to1 IS
	PORT(x,y,s : IN STD_LOGIC;
    	     m : OUT STD_LOGIC);				 
END ENTITY mux2to1;

ARCHITECTURE behavior OF mux2to1 IS
BEGIN
    --Comportamento del multiplexer come funzione booleana
	m <= (NOT (s) AND x) OR (s AND y); 
END ARCHITECTURE behavior;