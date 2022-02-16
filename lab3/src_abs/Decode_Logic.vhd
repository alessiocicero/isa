LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.myTypes.all;

entity Decode_Logic IS
	PORT(
		instruction:	in 	std_logic_vector(31 downto 0);
		opcode: 		out std_logic_vector(6 downto 0);
		func3:			out std_logic_vector(2 downto 0);
		func7:			out std_logic_vector(6 downto 0);
		IMM32: 			out std_logic_vector(31 downto 0);
		ADD_RA:			out std_logic_vector(4 downto 0);
		ADD_RB:			out std_logic_vector(4 downto 0);
		ADD_W:			out std_logic_vector(4 downto 0)
		);
end entity Decode_Logic;


architecture Behavioral of Decode_Logic is

begin

	opcode	<=	instruction(6 downto 0);

dec_proc: process(instruction)
begin
	
	-- depending on value of OPCODE, we detect the type of instruction (R-type/I-TYPE/...)
	
    if 		(unsigned(instruction(6 downto 0)) = unsigned(RTYPE)) then 
        ADD_RA  <= instruction(19 downto 15);
        ADD_RB  <= instruction(24 downto 20);
        ADD_W   <= instruction(11 downto 7);
        func3 	<= instruction(14 downto 12);
		func7 	<= instruction(31 downto 25);
        IMM32  	<= (others=>'0');
        
	elsif	(unsigned(instruction(6 downto 0)) = unsigned(ITYPE)) then 
		if (unsigned(instruction(14 downto 12))= unsigned(SRAI)) then
			ADD_RA  <= instruction(19 downto 15);
			ADD_RB  <= (others=>'0');
			ADD_W   <= instruction(11 downto 7);
			func3 	<= instruction(14 downto 12);
			func7 	<= (others=>'0');
			IMM32(4 downto 0)	<= instruction(24 downto 20);
			IMM32(31 downto 5)	<= (others=>'0'); --Sign Extension
        else
	        ADD_RA  <= instruction(19 downto 15);
	        ADD_RB  <= (others=>'0');
	        ADD_W   <= instruction(11 downto 7);
	        func3 	<= instruction(14 downto 12);
			func7 	<= (others=>'0');
	        IMM32(11 downto 0)	<= instruction(31 downto 20);
			IMM32(31 downto 12)	<= (others=>instruction(31)); --Sign Extension
		end if;		
	elsif 	(unsigned(instruction(6 downto 0)) = unsigned(STYPE)) then 
        ADD_RA  <= instruction(19 downto 15);
        ADD_RB  <= instruction(24 downto 20);
        ADD_W   <= (others=>'0');
        func3 	<= instruction(14 downto 12);
		func7 	<= (others=>'0');
        IMM32(4 downto 0)	<= instruction(11 downto 7);
		IMM32(11 downto 5)	<= instruction(31 downto 25);
		IMM32(31 downto 12)	<= (others=>'0');
	
	elsif 	(unsigned(instruction(6 downto 0)) = unsigned(BTYPE)) then 
        ADD_RA  <= instruction(19 downto 15);
        ADD_RB  <= instruction(24 downto 20);
        ADD_W   <= (others=>'0');
        func3 	<= instruction(14 downto 12);
		func7 	<= (others=>'0');
		IMM32(3 downto 0) <= instruction(11 downto 8);
		IMM32(9 downto 4) <= instruction(30 downto 25);
		IMM32(10) <= instruction(7);
		IMM32(11) <= instruction(31);
		IMM32(31 downto 12)	<= (others => instruction(31));

	elsif 	(unsigned(instruction(6 downto 0)) = unsigned(LTYPE)) then 
        ADD_RA  <= instruction(19 downto 15);
        ADD_RB  <= (others=>'0');
        ADD_W   <= instruction(11 downto 7);
        func3 	<= instruction(14 downto 12);
		func7 	<= (others=>'0');
        IMM32(11 downto 0)	<= instruction(31 downto 20);
		IMM32(31 downto 12)	<= (others=>'0');
		
	elsif 	(unsigned(instruction(6 downto 0)) = unsigned(JAL)) then 
        ADD_RA  <= (others=>'0');
        ADD_RB  <= (others=>'0');
        ADD_W   <= instruction(11 downto 7);
        func3 	<= (others=>'0');
		func7 	<= (others=>'0');
        IMM32(9 downto 0)	<= instruction(30 downto 21);
        IMM32(10)<=instruction(20);
        IMM32(18 downto 11)<=instruction(19 downto 12);
        IMM32(19)<=instruction(31);
		IMM32(31 downto 20)	<= (others=>instruction(31));
	elsif   (unsigned(instruction(6 downto 0)) = unsigned(ABSLT)) then
		ADD_RA  <= instruction(19 downto 15);
        ADD_RB  <= (others=>'0');
        ADD_W   <= instruction(11 downto 7);
        func3 	<= (others=>'0');
		func7 	<= (others=>'0');
		IMM32	<= (others => '0');
	else --if 	(unsigned(instruction(6 downto 0)) = unsigned(AUIPC)) then 
        ADD_RA  <= (others=>'0');
        ADD_RB  <= (others=>'0');
        ADD_W   <= instruction(11 downto 7);
        func3 	<= (others=>'0');
		func7 	<= (others=>'0');
        IMM32(11 downto 0)	<= (others=>'0');
		IMM32(31 downto 12)	<= instruction(31 downto 12);
		
    end if;
end process dec_proc;


end Behavioral;