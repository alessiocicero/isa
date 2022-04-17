library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.pp_array_pkg.all;

entity mbe is 
	port (	multa:	IN STD_LOGIC_VECTOR(31 downto 0);
			multb:	IN STD_LOGIC_VECTOR(31 downto 0);
			result: OUT STD_LOGIC_VECTOR(63 downto 0));
end entity mbe;

architecture behaviour of mbe is	

type initmatrix is array (16 downto 0) of std_logic_vector(32 downto 0);

--type signed_ppmatrix is array (16 downto 0) of std_logic_vector(36 downto 0);
--type ddmatrix is array (16 downto 0) of std_logic_vector( downto 0);

component partial_products_generator is
        port(   	multa:          in STD_LOGIC_VECTOR(31 downto 0);
                	multb_triplet:  in STD_LOGIC_VECTOR(2 downto 0);
				  	sign: 			out std_logic;
                    partial_product:out STD_LOGIC_VECTOR(32 downto 0));
end component;

component sign_extension is
        port(   	pre_sign: 				in std_logic;
					sign: 					in std_logic;
                    partial_product:		in STD_LOGIC_VECTOR(32 downto 0);
					signed_partial_product:	out STD_LOGIC_VECTOR(36 downto 0));
end component;

component daddaTree is
	port(	pp_ext: in ppmatrix;
			Addend1: out std_logic_vector(63 downto 0);
			Addend2: out std_logic_vector(63 downto 0));
end component;

signal multb_ext : std_logic_vector(34 downto 0);
signal sign : std_logic_vector(16 downto 0);
signal Addend1: std_logic_vector(63 downto 0);
signal Addend2: std_logic_vector(63 downto 0);
signal partial_product : initmatrix;
signal signed_partial_product : ppmatrix;
signal result_unsigned : unsigned(63 downto 0);
--signal signed_ddmatrix : ddmatrix;

begin

multb_ext(32 downto 1) <= multb;
multb_ext(0) <= '0';
multb_ext(33) <= '0';
multb_ext(34) <= '0';

partial_product_generate : 
	for i in 0 to 16 generate
		ppx : partial_products_generator port map (multa => multa, multb_triplet => multb_ext((2*i+2) downto (2*i)), sign => sign(i), partial_product => partial_product(i));
	end generate;

signed_ppt_generate : 
	for i in 1 to 14 generate		
		sppx : sign_extension port map (pre_sign => sign(i-1), sign => sign(i), partial_product => partial_product(i), signed_partial_product => signed_partial_product(i));
	end generate;

signed_partial_product(0) <= '0' & not(sign(0)) & sign(0) & sign(0) & partial_product(0);
signed_partial_product(15) <= '0' & not(sign(15)) & partial_product(15) & '0' & sign(14) ;
signed_partial_product(16) <= '0' & '0' & partial_product(16) & '0' & sign(15) ;

--pp1 : partial_products_generator port map (multa => multa, multb_triplet => multb_ext(2 downto 0), sign => sign(0), partial_product => partial_product(0));

dadda : daddaTree port map (pp_ext => signed_partial_product, Addend1 => Addend1, Addend2 => Addend2);

result_unsigned <= unsigned(Addend1) + unsigned(Addend2);
result <= std_logic_vector(result_unsigned);
end architecture behaviour;
