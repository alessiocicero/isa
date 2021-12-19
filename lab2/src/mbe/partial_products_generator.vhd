library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity partial_products_generator is
	port(	multa:			in STD_LOGIC_VECTOR(31 downto 0);
			multb_triplet: 	in STD_LOGIC_VECTOR(2 downto 0);
			sign: 			out std_logic;
			partial_product:out STD_LOGIC_VECTOR(32 downto 0)); 
			--The 33th bit is used to store 2a
end entity;

architecture beh of partial_products_generator is
begin
part_process: process (multa,multb_triplet)
	
	begin
	--	0
	if	(multb_triplet = "000") then 
		partial_product <= (others => '0');
		sign <= '0';
	--	a	
	elsif	(multb_triplet = "001") or (multb_triplet = "010") then 
		partial_product(31 downto 0) <= multa;
		partial_product(32) <= '0';
		sign <= '0';
	--	2a	
	elsif	(multb_triplet = "011") then 
		partial_product(32 downto 1) <= multa;
		partial_product(0) <= '0';
		sign <= '0';
	-- 	-2a
	elsif	(multb_triplet = "100") then 
		partial_product(32 downto 1) <= not(multa);
		partial_product(0) <= '1';
		sign <= '1';
	-- 	-a
	elsif	(multb_triplet = "101") or (multb_triplet = "110") then 
		partial_product(31 downto 0) <= not(multa);
		partial_product(32) <= '1';
		sign <= '1';
	-- 	-0
	else
		partial_product <= (others => '1');
		sign <= '1';

	end if;
end process;
end architecture;
