library ieee;
use ieee.std_logic_1164.all;

entity sign_extension is
    port(   pre_sign: 				in std_logic;
			sign: 					in std_logic;
            partial_product:		in STD_LOGIC_VECTOR(32 downto 0);
			signed_partial_product:	out STD_LOGIC_VECTOR(36 downto 0));
end entity;

architecture beh of sign_extension is
begin

	signed_partial_product(0)  <= pre_sign;
	signed_partial_product(1)  <= '0';
	signed_partial_product(34 downto 2) <= partial_product;
	signed_partial_product(35)  <= not(sign);
	signed_partial_product(36) <= '1';

end architecture;
