library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
	port (	A,B,Cin: in std_logic;
		S,Cout: out std_logic);
end entity full_adder;

architecture rtl of full_adder is
	signal net1, net2, net3: std_logic;
	begin
	net1 <= A xor B;
	S <= net1 xor Cin;
	net2 <= net1 and Cin;
	net3 <= A and B;
	Cout <= net2 or net3;
end architecture rtl;

