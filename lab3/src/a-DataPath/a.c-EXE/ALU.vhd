library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ALU is
  port( A, B : in std_logic_vector(31 downto 0);
        ALU_cmd : in std_logic_vector(2 downto 0);
        result : out std_logic_vector(31 downto 0);
        zero : out std_logic);
end entity;

architecture rtl of ALU is

  signal add_result, shift_result, and_result, xor_result,compare_result : std_logic_vector(31 downto 0);
  signal zero_result : std_logic;

component barrel_shifter is
  port (
  Rs     : in std_logic_vector(31 downto 0) ; -- operand to be shifted
  sh_amt : in std_logic_vector(31 downto 0) ; -- shift amount
  result : out std_logic_vector(31 downto 0)
  ) ;
end component ; -- barrel_shifter
  
  begin

ALU_process : process (ALU_cmd,add_result,shift_result,and_result,xor_result,zero_result,compare_result)
  begin
    result <= (others => '0');
    zero <= '0';
    case ALU_cmd is
      when "000" => result <= add_result;
      when "101" => result <= shift_result;
      when "111" => result <= and_result;
      when "100" => result <= xor_result;
      when "010" => 
        zero <= zero_result;--also for compare, result: 1 if A<B, 0 if A>B
        result <= compare_result;
      when others => result <= (others => '0'); zero <= '0';
    end case;
end process;

    add_result <= A + B; 

  BS : barrel_shifter 
  port map(
    Rs     => A,
    sh_amt => B,
    result => shift_result
  ) ;

  and_result <= A and B;

  xor_result <= A xor B;

Compare : process (A,B)
  begin
    if(A > B) then
      compare_result <= (others => '0');
      zero_result <= '0';
    elsif(A < B) then
      compare_result <= x"00000001";
      zero_result <= '0';
    else
      compare_result <= (others => '0');
      zero_result <= '1';
    end if;
end process;
    
end architecture;
        
