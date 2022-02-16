library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity control_unit is
port(
    clk: IN std_logic;
    rst: IN std_logic;
    
    opcode: IN std_logic_vector(6 downto 0);
    func3:  IN std_logic_vector(2 downto 0);
	func7:  IN std_logic_vector(6 downto 0);
    
    --	EXE
    ALUSrc1:	OUT std_logic;
    ALUSrc2:	OUT std_logic_vector(1 downto 0);
    ALUOp:      OUT std_logic_vector(2 downto 0);

    --	MEM
    MemRead:  	OUT std_logic;
    MemWrite: 	OUT std_logic;
    Jump:		OUT std_logic;
	Branch:		OUT std_logic;
	
	--	WB
	MemtoReg:  	OUT std_logic;
	RegWrite:	OUT std_logic				
	);
	
end control_unit;

architecture Behavioral of control_unit is

type micro_mem is array(integer range 0 to uCODE_LUT_SIZE-1) of std_logic_vector(CW_size-1 downto 0);
	signal LUT: micro_mem;

    signal cw:  std_logic_vector(11 downto 0);           -- this is the cw obtained directrly from the LUT(asynchronous).

begin
LUT(0)<="110000000000"; --		0	ADD
LUT(1)<="110000010000"; --		1	SLT
LUT(2)<="110000100000"; --		2	XOR  
LUT(3)<="110000000010"; --		3	ADDI
LUT(4)<="110000101010"; --		4	SRAI
LUT(5)<="110000111010"; --		5	ANDI  
LUT(6)<="010010000010"; --		6	SW  
LUT(7)<="011000010000"; --		7	BEQ  
LUT(8)<="100001000010"; --		8	LW  
LUT(9)<="110100000101"; --		9	JAL
LUT(10)<="110000000011"; --		10	AUIPC
LUT(11)<="110000000010"; --		11	LUI		
LUT(12)<="110000001010";--      12	ABSLT				
LUT(13)<="010000000000"; --		13	





-- concurrent assignement of the output signals considering for each stage the correct cw. cw1,cw2 and cw3 change only at the risign edge of the clock

	--	EXE
	ALUSrc1   	 <=    cw(0); 
	ALUSrc2		 <=    cw(2 downto 1);
    ALUOp    	 <=    cw(5 downto 3); 

    --	MEM
    MemRead		 <=    cw(6);
    MemWrite	 <=    cw(7);
    Jump 		 <=	   cw(8);
	Branch		 <=    cw(9);
	
	--	WB
	MemtoReg	 <=    cw(10);
	RegWrite	 <=    cw(11);
	
cw_proc:Process(opcode, func3, func7,LUT)
		variable i:	integer;
begin
    if(unsigned(opcode) = unsigned(Rtype)) then   --if it is an R-Type instr
        case (to_integer(unsigned(func3))) is          
            when 0 => i := 0 ; 	--ADD
            when 2 => i := 1 ; 	--SLT
            when 4 => i := 2 ;	--XOR
            when others => i := 12 ;     -- nop     
        end case;
	
	elsif(unsigned(opcode) = unsigned(Itype)) then   --if it is an I-Type instr
        case (to_integer(unsigned(func3))) is          
            when 0 => i := 3 ; 	--ADDI
			when 5 => i := 4 ; 	--SRAI
			when 7 => i := 5 ; 	--ANDI
            when others => i := 12 ;     -- nop     
        end case;
    
	elsif(unsigned(opcode) = unsigned(Stype)) then   --if it is an S-Type instr
        case (to_integer(unsigned(func3))) is          
            when 2 => i := 6 ; 	--SW
            when others => i := 12 ;     -- nop     
        end case;
		
	elsif(unsigned(opcode) = unsigned(Btype)) then   --if it is an B-Type instr
        case (to_integer(unsigned(func3))) is          
            when 0 => i := 7 ; 	--BEQ
            when others => i := 12 ;     -- nop     
        end case;

	elsif(unsigned(opcode) = unsigned(Ltype)) then   --if it is an L-Type instr
        case (to_integer(unsigned(func3))) is          
            when 2 => i := 8 ; 	--LW
            when others => i := 12 ;     -- nop     
        end case;
		
	elsif (unsigned(opcode) = unsigned(JAL)) then
		i := 9 ;
	
	elsif (unsigned(opcode) = unsigned(AUIPC)) then
		i := 10 ;
	
	elsif (unsigned(opcode) = unsigned(LUI)) then
		i := 11 ;

	elsif (unsigned(opcode) = unsigned(ABSLT)) then
		i := 12 ;	
	else
		i := 13 ;
	end if;

	cw <= LUT(i);

end process cw_proc;


end Behavioral;
