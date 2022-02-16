library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity decode_stage is
port(	
	--inputs
	clk:	in std_logic;
	instruction:	in 	std_logic_vector(31 downto 0);
	RF_DataIn:		in 	std_logic_vector(31 downto 0);	--RF input data 
	RF_WA:			in 	std_logic_vector(4 downto 0);	-- write address for the Register file
	rst:			in 	std_logic;
	stall:		in 	std_logic;
	--control
	RegWrite:		in 	std_logic;
	opcode: 		out std_logic_vector(6 downto 0);
	func3:			out std_logic_vector(2 downto 0);
	func7:			out std_logic_vector(6 downto 0);
	
	--outputs
	RA: 			out std_logic_vector(31 downto 0);
	RB: 			out std_logic_vector(31 downto 0);
	RSA: 			out std_logic_vector(4 downto 0);
	RSB: 			out std_logic_vector(4 downto 0);
	RD: 			out std_logic_vector(4 downto 0);
	IMM32: 			out std_logic_vector(31 downto 0);
	--outputs from instruction
	RSA_iram: 	out std_logic_vector(4 downto 0);
	RSB_iram: 	out std_logic_vector(4 downto 0));
end entity decode_stage;


architecture Behavioral of decode_stage is

component Decode_Logic IS
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
end component;


component RegisterFile IS
   PORT(
   	clk:  in std_logic;
		RESET_n:      	in  std_logic;
		RegWrite:   	in  std_logic;
		ADD_RA:     	in  std_logic_vector(4 downto 0);
		ADD_RB:     	in  std_logic_vector(4 downto 0);
		ADD_W:      	in  std_logic_vector(4 downto 0);
		RF_DataIn:  	in  std_logic_vector(31 downto 0);
		RA:         	out std_logic_vector(31 downto 0);
		RB:      		out std_logic_vector(31 downto 0)
    );
end component;

signal s_ADD_RA:	std_logic_vector(4 downto 0);
signal s_ADD_RB:	std_logic_vector(4 downto 0);

signal RSA_dec: 			std_logic_vector(4 downto 0);
signal RSB_dec: 			std_logic_vector(4 downto 0);
signal RSD_dec: 			std_logic_vector(4 downto 0);
signal IMM32_dec: 		std_logic_vector(31 downto 0);

begin


DEC_L: Decode_Logic
	port map(
		instruction	=>	instruction,
		opcode		=>	opcode,
		func3		=>	func3,
		func7		=>	func7,
		IMM32		=>	IMM32_dec,
		ADD_RA		=>	RSA_dec,
		ADD_RB		=>	RSB_dec,
		ADD_W		=>	RSD_dec
	);


REG_FILE: RegisterFile
	port map(
		clk => clk,
		RESET_n		=>	rst,
		RegWrite	=>	RegWrite,
		ADD_RA		=>	s_ADD_RA,
		ADD_RB		=>	s_ADD_RB,
		ADD_W		=>	RF_WA,
		RF_DataIn	=>	RF_DataIn,
		RA			=>	RA,
		RB			=>	RB
	);

RSA		<= s_ADD_RA;
RSB		<= s_ADD_RB;

RSA_iram  <= RSA_dec;
RSB_iram  <= RSB_dec;

mux_proc : process (stall, RSA_dec,RSB_dec,RSD_dec,IMM32_dec)
	begin
  if(stall = '0') then
	s_ADD_RA <= RSA_dec; 	
	s_ADD_RB <= RSB_dec;  		 	
	RD 		<= RSD_dec;	
 	IMM32    <= IMM32_dec;
  else --We execute ADDI,x0,x0
	s_ADD_RA <= "00000"; 	
	s_ADD_RB <= "00000";  		 	
	RD 		<= "00000";	
	IMM32    <= (others=>'0');
  end if;
  end process;

end architecture Behavioral;
