library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant OP_CODE_SIZE   : integer :=  7;   -- OPCODE field size
    constant uCODE_LUT_SIZE : integer :=  14;  -- Microcode Memory Size
    constant CW_SIZE        : integer :=  12;   -- Control Word Size);

-- Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0110011";
	constant ITYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0010011";
	constant STYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0100011";
	constant BTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "1100011";
	constant LTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0000011";

	--REWATCH PLS --------------------------------------------------------------------
	constant JAL : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  	"1101111";
	constant AUIPC : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "0010111";
	constant LUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  	"0110111";

	constant ABSLT: std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "0001111";

	constant SRAI : std_logic_vector(2 downto 0) :=  	"101";

	----RTYPE
	--"0110011"; --		0	ADD 	--31:25 = 0, 14:12 =0,
	--"0110011"; --		1	SLT 	--31:25 = 0, 14:12 =2,
	--"0110011"; --		2	XOR  	--31:25 = 0, 14:12 =4,
	--
	----ITYPE
	--"0010011"; --		3	ADDI				 14:12 =0,
	--"0010011"; --		4	SRAI	--31:26 = 16, 24:20 shamt 14:12 =5,	
	--"0010011"; --		5	ANDI	             14:12 =7,  
	--
	----STYPE
	--"0100011"; --		6	SW  	--31:25 = 0, 14:12 =2,
	--
	----BTYPE
	--"1100011"; --		7	BEQ 	             14:12 =0, 
	--
	----LTYPE
	--"0000011"; --		8	LW  	             14:12 =2,
	--
	----JAL
	--"1101111"; --		9	JAL		
	--
	--"0010111"; --		10	AUIPC	
	--
	--"0110111" --			11	LUI									


	constant IRAM_ADDRESS_LENGTH : integer := 32;
	constant DRAM_ADDRESS_LENGTH : integer := 32;



end myTypes;

