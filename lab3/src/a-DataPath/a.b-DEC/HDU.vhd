--	Project: RISC-V 32 bit Architecture
--	Module: Hazard Detection Unit (HDU)
--	Author: Filippo Carastro
--	Updated: 05/02/2022
--	Hazard detection for load instruction.

-- ld x1
-- x2 <- x1 + x3;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity hazard_detection_unit is
  port (
  regWrite	 					: in std_logic ; -- register write '1' in the previous instruction
  branch_sel 					: in std_logic;
  branch_sel_ex_pip		: in std_logic;
  branch_sel_mem_pip	: in std_logic;
  branch_sel_wb_pip		: in std_logic;
  jump_sel						: in std_logic;
  jump_sel_ex_pip			: in std_logic;
  jump_sel_mem_pip		:	in std_logic;
  MemRead_ex_pip			: in std_logic;
  MemRead_mem_pip			: in std_logic;
  MemRead_wb_pip			: in std_logic;
  Rd_ex_pip		 				: in std_logic_vector(4 downto 0) ; -- previous destination register
  Rd_mem_pip		 			: in std_logic_vector(4 downto 0) ;
  Rd_wb_pip		 				: in std_logic_vector(4 downto 0) ;
  Rs1 			 					: in std_logic_vector(4 downto 0) ;
  Rs2 			 					: in std_logic_vector(4 downto 0) ;
  Rd_bypass1 		: out std_logic;
  Rd_bypass2 		: out std_logic;
	stall 		 		: out std_logic;
	PC_Write			: out std_logic;
	IF_ID_Write		: out std_logic;
	iram_read_en	: out std_logic
  ) ;
end entity ; -- hazard_detection_unit

architecture rtl of hazard_detection_unit is

begin

hdu : process(Rd_ex_pip,Rd_mem_pip,Rd_wb_pip,regWrite,Rs1,Rs2,branch_sel,branch_sel_ex_pip,branch_sel_mem_pip,jump_sel,jump_sel_ex_pip,jump_sel_mem_pip, MemRead_ex_pip,MemRead_mem_pip,MemRead_wb_pip,branch_sel_wb_pip)
begin
	stall <= '0';
	PC_Write <= '1';
	IF_ID_Write <= '1';
	iram_read_en <= '1';
	Rd_bypass1 <= '0';
	Rd_bypass2 <= '0';
	--Case of BEQ
	if(branch_sel = '1') or (jump_sel = '1') then
	--	stall <= '1';
			PC_Write <= '0';
	elsif (branch_sel_ex_pip = '1') or (jump_sel_ex_pip = '1') then
		stall <= '1';
		iram_read_en <= '0';
		PC_Write <= '0';
		--IF_ID_Write <= '0';
	elsif (branch_sel_mem_pip = '1')	then
			--IF_ID_Write <= '0'; --Double check
			iram_read_en <= '0';
			stall <= '1';
	elsif (branch_sel_wb_pip = '1') then
			stall <= '1';
	else
		stall <= '0';
	end if;
	--LW
	if(Rs1 /= "00000") then
		if(Rs1 = Rd_ex_pip) and (MemRead_ex_pip = '1')then
			stall <= '1';	
			PC_Write <= '0';
			iram_read_en <= '0';
			--IF_ID_Write <= '0';
		elsif(Rs1 = Rd_mem_pip) and (MemRead_mem_pip = '1')then
			stall <= '1';
			PC_Write <= '0';
			iram_read_en <= '0';
			--IF_ID_Write <= '0';
		elsif(Rs1 = Rd_wb_pip) and (MemRead_wb_pip = '1')then
			stall <= '1';
			PC_Write <= '0';
			iram_read_en <= '0';
			--IF_ID_Write <= '0';
		end if;
	elsif(Rs2 /= "00000") then
		if(Rs2 = Rd_ex_pip) and (MemRead_ex_pip = '1')then
			stall <= '1';
			PC_Write <= '0';
			iram_read_en <= '0';
			--IF_ID_Write <= '0';
		elsif(Rs2 = Rd_mem_pip) and (MemRead_mem_pip = '1')then
			stall <= '1';
			PC_Write <= '0';
			iram_read_en <= '0';
			--IF_ID_Write <= '0';
		elsif(Rs2 = Rd_wb_pip) and (MemRead_wb_pip = '1')then
			stall <= '1';
			PC_Write <= '0';
			iram_read_en <= '0';
			--IF_ID_Write <= '0';
		end if;
	end if;

	if (Rs1 /= "00000") and (Rs1 = Rd_wb_pip) then
		Rd_bypass1 <= '1';
	else
	end if ;

	if (Rs2 /= "00000") and (Rs2 = Rd_wb_pip) then
		Rd_bypass2 <= '1';
	else
	end if ;

end process ; -- hdu

end architecture ; -- rtl