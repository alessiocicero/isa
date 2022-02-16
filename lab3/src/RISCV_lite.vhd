library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.myTypes.all;


entity RISCV_lite is
    --GENERIC();
    PORT(
		  clock    :		IN std_logic;
      reset_n  :		IN std_logic;
        
      DRAM_data_out: IN		std_logic_vector(31 downto 0); 	--data coming from the DRAM
      IRAM_data_out: 	 	IN    	std_logic_vector(31 downto 0);		--data coming from the IRAM
        
      DRAM_addr: 	 	OUT 	std_logic_vector((DRAM_ADDRESS_LENGTH-1) downto 0);		--DRAM address where to read/write
      IRAM_addr: 	 	OUT 	std_logic_vector((IRAM_ADDRESS_LENGTH-1) downto 0);		--DRAM address where to read from
      DRAM_data_in: 	OUT 	std_logic_vector(31 downto 0);		--data sent to the DRAM to be written in it
         
      DRAM_Read_EN:	OUT		std_logic; 									--enable signal for Reading from the DRAM
		  DRAM_Write_EN:	OUT		std_logic; 									--enable signal for Writing to the DRAM
      IRAM_Read_EN: OUT   std_logic                  --enable signal for Reading from the DRAM
    );


end RISCV_lite ;

architecture Structural of RISCV_lite is

component control_unit is
port(
    clk: IN std_logic;
    rst: IN std_logic;
    
    opcode: IN std_logic_vector(6 downto 0);
    func3:  IN std_logic_vector(2 downto 0);
    func7:  IN std_logic_vector(6 downto 0);
    
    --  EXE
    ALUSrc1:  OUT std_logic;
    ALUSrc2:  OUT std_logic_vector(1 downto 0);
    ALUOp:      OUT std_logic_vector(2 downto 0);

    --  MEM
    MemRead:    OUT std_logic;
    MemWrite:   OUT std_logic;
    Jump:     OUT std_logic;
    Branch:   OUT std_logic;
  
    --  WB
    MemtoReg:   OUT std_logic;
    RegWrite: OUT std_logic       
  );
end component;

component Datapath is
  port (
  clock, rst_n    : in std_logic;
  --Control_Unit signals  
  opcode      :   out std_logic_vector(6 downto 0);
  func3     :   out std_logic_vector(2 downto 0);
  func7     :   out std_logic_vector(6 downto 0);
  --  EXE
  ALUSrc1:  in std_logic;
  ALUSrc2:  in std_logic_vector(1 downto 0);
  ALUOp     :   in std_logic_vector(2 downto 0);
  --  MEM
  MemRead     :   in std_logic;
  MemWrite    :   in std_logic;
  Jump:   in std_logic;
  Branch      : in std_logic;
  --  WB
  MemtoReg    :   in std_logic;
  RegWrite    : in std_logic; 

  --IRAM & DRAM
  instr_mem_out   : in std_logic_vector(31 downto 0) ;
  data_mem_out    : in std_logic_vector(31 downto 0) ;
  instr_mem_addr  : out std_logic_vector((IRAM_ADDRESS_LENGTH - 1) downto 0);
  data_mem_addr : out std_logic_vector((DRAM_ADDRESS_LENGTH - 1) downto 0);
  data_mem_write : out std_logic;
  data_mem_read : out std_logic;
  data_mem_in : out std_logic_vector(31 downto 0);
  iram_read_en: out std_logic
  );
end component ; -- Datapath
  signal ALUSrc1,MemRead,MemWrite,Jump,Branch,MemtoReg,RegWrite: std_logic;
  signal AlUSrc2: std_logic_vector(1 downto 0);
  signal ALUOp: std_logic_vector(2 downto 0);
  signal opcode: std_logic_vector(6 downto 0);
  signal func3: std_logic_vector(2 downto 0);
  signal func7: std_logic_vector(6 downto 0);

begin

CU : control_unit 
  port map(
    clk=>clock,
    rst=>reset_n,
    opcode=>opcode,
    func3=>func3,
    func7=>func7,
    --  EXE
    ALUSrc1 => ALUSrc1,
    ALUSrc2 => ALUSrc2,
    ALUOp => ALUOp,
    --  MEM
    MemRead => MemRead,
    MemWrite => MemWrite,
    Jump => Jump,
    Branch => Branch,
  
    --  WB
    MemtoReg => MemtoReg,
    RegWrite => RegWrite
  );

DP : Datapath
  port map(
    clock => clock,
    rst_n => reset_n,
    --Control_Unit signals  
    opcode =>opcode,
    func3 =>func3,
    func7 =>func7,
    --  EXE
    ALUSrc1 => ALUSrc1,
    ALUSrc2 => ALUSrc2,
    ALUOp => ALUOp,
    --  MEM
    MemRead => MemRead,
    MemWrite => MemWrite,
    Jump => Jump,
    Branch => Branch,
    --  WB
    MemtoReg => MemtoReg,
    RegWrite => RegWrite,


    instr_mem_out => IRAM_data_out,
    data_mem_out  => DRAM_data_out,
    instr_mem_addr => IRAM_addr,
    data_mem_addr => DRAM_addr,
    data_mem_write => DRAM_Write_EN,
    data_mem_read => DRAM_Read_EN,
    data_mem_in => DRAM_data_in,
    iram_read_en => IRAM_Read_EN
  );

end architecture Structural;
