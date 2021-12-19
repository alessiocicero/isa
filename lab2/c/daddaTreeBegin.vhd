library ieee;
use ieee.std_logic_1164.all;
use work.pp_array_pkg.all;


entity daddaTree is
        port(   pp_ext: in ppmatrix;
                        Addend1: out std_logic_vector(63 downto 0);
                        Addend2: out std_logic_vector(63 downto 0));
end entity;

architecture rtl of daddaTree is
        component full_adder is
                port(   A,B,Cin: in std_logic;
                        S,Cout: out std_logic);
        end component full_adder;
        component half_adder is
                port(   A,B: in std_logic;
                        S,Cout: out std_logic);
        end component half_adder;

