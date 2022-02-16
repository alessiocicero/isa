library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity Datapath is
  port (
	clock, rst_n 		:	in std_logic;
	--Control_Unit signals	
	opcode			: 	out std_logic_vector(6 downto 0);
	func3			:  	out std_logic_vector(2 downto 0);
	func7			:  	out std_logic_vector(6 downto 0);
	--	EXE
	ALUSrc1:  in std_logic;
  ALUSrc2:  in std_logic_vector(1 downto 0);
	ALUOp			:   in std_logic_vector(2 downto 0);
	--	MEM
	MemRead			:  	in std_logic;
	MemWrite		: 	in std_logic;
	Jump 				:		in std_logic;
	Branch			:	in std_logic;
	--	WB
	MemtoReg		:  	in std_logic;
	RegWrite		:	in std_logic;	

	--IRAM & DRAM
	instr_mem_out		:	in std_logic_vector(31 downto 0) ;
	data_mem_out		:	in std_logic_vector(31 downto 0) ;
	instr_mem_addr	: out std_logic_vector((IRAM_ADDRESS_LENGTH - 1) downto 0);
	data_mem_addr	: out std_logic_vector((DRAM_ADDRESS_LENGTH - 1) downto 0);
	data_mem_write : out std_logic;
	data_mem_read : out std_logic;
	data_mem_in : out std_logic_vector(31 downto 0);
	iram_read_en: out std_logic
  );
end entity ; -- Datapath

architecture beh of DataPath is

	component fetch_stage is
	port( 
						 clk : in std_logic;
					 rst_n : in std_logic;
		  branch_sel : in std_logic;
		     PCWrite : in std_logic;
		pc_jump_addr : in std_logic_vector((IRAM_ADDRESS_LENGTH-1) downto 0);
			  pc_out : out std_logic_vector((IRAM_ADDRESS_LENGTH-1) downto 0)
 	   );
	end component fetch_stage;

	component decode_stage is
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
			RSB_iram: 	out std_logic_vector(4 downto 0)
		);
	end component decode_stage;

	component execute_stage is
	port(	
			ALUSrc1:						in std_logic;
			ALUSrc2:						in std_logic_vector(1 downto 0);
			ALUOp:	in std_logic_vector(2 downto 0);
			execute_data_in1:	in std_logic_vector(31 downto 0);
			execute_data_in2:	in std_logic_vector(31 downto 0);
			immediate_in:			in std_logic_vector(31 downto 0);
			rs1:							in std_logic_vector(4 downto 0);
			rs2:							in std_logic_vector(4 downto 0);
			--Signals from previous stage
			pc_out						: 	in std_logic_vector((IRAM_ADDRESS_LENGTH - 1) downto 0) ;
			--Signal from next stage
			writeback_data_out : in std_logic_vector(31 downto 0) ;
			ALU_result_in 		 : in std_logic_vector(31 downto 0) ;
			--Signals for Forwarding unit
			rd_mem_pip:			in std_logic_vector(4 downto 0);
			rd_wb_pip:			in std_logic_vector(4 downto 0);
			--Control signals for forwarding unit
			RFWrite_mem_pip: in std_logic;
			RFWrite_wb_pip: in std_logic;
			--
			address_result:		out std_logic_vector((IRAM_ADDRESS_LENGTH - 1) downto 0);
			DRAM_data_in: out std_logic_vector(31 downto 0);
			--Alu signals
			ALU_result:				out std_logic_vector(31 downto 0);
			zero:							out std_logic
			);
	end component execute_stage;

	component memory_stage is
			port(	
				zero_mem_pip 		: in std_logic;
				branch_mem_pip 	: in std_logic;
				jump_sel 			: in std_logic;
				branch_sel 			: out std_logic
				);
	end component memory_stage;

	component writeback_stage is
			port(	
			data_memory_out		:	in std_logic_vector(31 downto 0);
			data_memory_bypass 	:	in std_logic_vector(31 downto 0);
			mem_to_reg 		  	:	in std_logic;
			writeback_data_out	:	out std_logic_vector(31 downto 0)
			);
	end component writeback_stage;

	component regn_ld is
	generic ( N : integer := 8);
	port (R 	    : in std_logic_vector(N-1 downto 0);
	      Clock, Resetn, Load : in std_logic;
	      Q 	    : buffer std_logic_vector(N-1 downto 0));
	end component;

component hazard_detection_unit is
  port (
  regWrite	 					: in std_logic ; -- register write '1' in the previous instruction
  branch_sel 					: in std_logic;
  branch_sel_ex_pip		: in std_logic;
  branch_sel_mem_pip	: in std_logic;
  branch_sel_wb_pip		: in std_logic;
  jump_sel						:in std_logic;
  jump_sel_ex_pip			:in std_logic;
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
  end component;

  --HDU unit signals----------------------------------------------------------------

  signal iram_read_en_HDU : std_logic;
  signal Rd_bypass1, Rd_bypass2 : std_logic;

	--Fetch unit signals--------------------------------------------------------------
	signal pc_out : std_logic_vector((IRAM_ADDRESS_LENGTH -1) downto 0) ;
	signal PC_Write :std_logic;

	--Decode unit signals--------------------------------------------------------------
	signal pc_out_id_pip :std_logic_vector((IRAM_ADDRESS_LENGTH -1) downto 0) ;
	signal read_data_out1 : std_logic_vector(31 downto 0) ;
	signal read_data_out2 : std_logic_vector(31 downto 0) ;
	signal read_data_out1_mux : std_logic_vector(31 downto 0) ;
	signal read_data_out2_mux : std_logic_vector(31 downto 0) ;

	signal immediate_out : std_logic_vector(31 downto 0) ;
	signal IF_ID_write: std_logic;
	signal rs1,rs2, rd,RSA_iram,RSB_iram: std_logic_vector(4 downto 0);

  signal ALUSrc1_CUmux,MemRead_CUmux,MemWrite_CUmux,Jump_CUmux,Branch_CUmux,MemtoReg_CUmux,RegWrite_CUmux: std_logic;
  signal ALUSrc2_CUmux: std_logic_vector(1 downto 0);
  signal ALUOp_CUmux: std_logic_vector(2 downto 0);


	--Execute unit signals--------------------------------------------------------------
	signal immediate_in : std_logic_vector(31 downto 0) ;
	signal execute_data_in1 : std_logic_vector(31 downto 0) ;
	signal execute_data_in2 : std_logic_vector(31 downto 0) ;
	signal ALU_result_mem_pip : std_logic_vector(31 downto 0) ;
	signal address_result : std_logic_vector((IRAM_ADDRESS_LENGTH -1) downto 0) ;
	signal ALU_result : std_logic_vector(31 downto 0) ;
	signal DRAM_data_in_exe : std_logic_vector(31 downto 0) ;
	signal zero : std_logic;

	signal pc_out_ex_pip :std_logic_vector((IRAM_ADDRESS_LENGTH -1) downto 0) ;

	signal rs1_ex_pip,rs2_ex_pip,rd_ex_pip: std_logic_vector(4 downto 0);

  signal ALUSrc1_ex_pip,MemRead_ex_pip,MemWrite_ex_pip,Jump_ex_pip,Branch_ex_pip,MemtoReg_ex_pip,RegWrite_ex_pip: std_logic;
  signal ALUSrc2_ex_pip: std_logic_vector(1 downto 0);
  signal ALUOp_ex_pip: std_logic_vector(2 downto 0);


	--Memory unit signals--------------------------------------------------------------
	signal zero_mem_pip : std_logic;
	signal branch_sel: std_logic;
	signal DRAM_data_in_mem_pip : std_logic_vector(31 downto 0);
	signal pc_jump_addr_mem_pip: std_logic_vector((IRAM_ADDRESS_LENGTH - 1) downto 0);
  
	signal MemRead_mem_pip,MemWrite_mem_pip,Jump_mem_pip,Branch_mem_pip,MemtoReg_mem_pip,RegWrite_mem_pip: std_logic;

  signal rd_mem_pip: std_logic_vector(4 downto 0);
	--Writeback unit signals--------------------------------------------------------------
	signal writeback_data_out : std_logic_vector(31 downto 0) ;
	signal data_mem_out_wb_pip : std_logic_vector(31 downto 0) ;
	signal data_memory_bypass : std_logic_vector(31 downto 0) ;

	signal rd_wb_pip: std_logic_vector(4 downto 0);

	signal MemRead_wb_pip,MemtoReg_wb_pip,RegWrite_wb_pip: std_logic;
	signal Branch_sel_wb_pip: std_logic; 
	signal stall : std_logic;

begin
HDU: hazard_detection_unit
  port map(
  regWrite => RegWrite,
  branch_sel => Branch,
  branch_sel_ex_pip => Branch_ex_pip,
  branch_sel_mem_pip => Branch_sel,
  branch_sel_wb_pip => Branch_sel_wb_pip,  
  jump_sel => Jump,
  jump_sel_ex_pip	=> Jump_ex_pip,
  jump_sel_mem_pip => Jump_mem_pip,
  MemRead_ex_pip => MemRead_ex_pip,
  MemRead_mem_pip => MemRead_mem_pip,
  MemRead_wb_pip => MemRead_wb_pip,
  Rd_ex_pip => rd_ex_pip,
  Rd_mem_pip => rd_mem_pip,
  Rd_wb_pip => rd_wb_pip,
  Rs1 => RSA_iram,--rs1,
  Rs2 => RSB_iram,--rs2,
  Rd_bypass1 => Rd_bypass1,
  Rd_bypass2 => Rd_bypass2,
  stall => stall,
  PC_Write => PC_Write,
  IF_ID_write => IF_ID_write,
  iram_read_en => iram_read_en_HDU
  );

  --Used to ensure that the system can be initialised after a reset
  iram_read_en <= iram_read_en_HDU or (not(rst_n));

--Fetch unit--------------------------------------------------------------
Fetch : fetch_stage port map(
		clk => clock, 
		rst_n=>rst_n, 
		branch_sel=> branch_sel, 
		PCWrite=> PC_Write, 
		pc_jump_addr=> pc_jump_addr_mem_pip, 
		pc_out=>pc_out);

instr_mem_addr<=pc_out;

--IF PIPELINE
IF_ID : regn_ld generic map(N => 32) port map(
		R(31 downto 0)=>pc_out, 
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>IF_ID_write, 
		Q(31 downto 0)=>pc_out_id_pip);


--Decode unit--------------------------------------------------------------
Decode : decode_stage port map(
		clk => clock,
		instruction => instr_mem_out(31 downto 0),	
		RF_DataIn => writeback_data_out,
		RF_WA => rd_wb_pip,
		rst =>	rst_n,
		stall => stall,		
		--control
		RegWrite => RegWrite_wb_pip,
		opcode => opcode, 	
		func3 => func3,
		func7 => func7,
		--outputs decoded
		RA => read_data_out1_mux, 			
		RB => read_data_out2_mux,
		RSA => rs1,		
		RSB => rs2,			
		RD => rd,		
		IMM32 => immediate_out,
		--outputs from instruction
		RSA_iram => RSA_iram,
		RSB_iram => RSB_iram
		);

RF_bypass_mux : process( read_data_out1_mux,read_data_out2_mux,writeback_data_out,Rd_bypass1,Rd_bypass2 )
begin
	if (Rd_bypass1 = '0') then
		read_data_out1 <= read_data_out1_mux;
	else
		read_data_out1 <= writeback_data_out;
	end if ;

	if (Rd_bypass2 = '0') then
		read_data_out2 <= read_data_out2_mux;
	else
		read_data_out2 <= writeback_data_out;
	end if ;

end process ; -- RF_bypass_mux

CU_mux_proc : process (stall,ALUSrc1,ALUSrc2,ALUOp,MemRead,MemWrite,Jump,Branch,MemtoReg,RegWrite)
	begin
  if(stall = '0') then
		ALUSrc1_CUmux		<= 	ALUSrc1;
		ALUSrc2_CUmux 	<= 	ALUSrc2;
		ALUOp_CUmux			<= 	ALUOp;
		MemRead_CUmux		<= 	MemRead;
		MemWrite_CUmux	<= 	MemWrite;
		Jump_CUmux 			<= 	Jump;
		Branch_CUmux		<= 	Branch;
		MemtoReg_CUmux	<= 	MemtoReg;
		RegWrite_CUmux	<= 	RegWrite;
  else
    ALUSrc1_CUmux		<='0'; 
		ALUSrc2_CUmux 	<="01";
		ALUOp_CUmux			<="000"; 
		MemRead_CUmux		<='0';
		MemWrite_CUmux	<='0';
		Jump_CUmux 			<='0'; 
		Branch_CUmux		<='0'; 
		MemtoReg_CUmux	<='1';
		RegWrite_CUmux	<='1';
  end if;
  end process;




--DECODE PIPELINE
ID_EX : regn_ld generic map(N => 143) 
	port map(
		R(4 downto 0)=>rd,
		R(9 downto 5)=>rs1,
		R(14 downto 10)=>rs2,
		R(46 downto 15)=>immediate_out,
		R(78 downto 47)=>read_data_out2,
		R(110 downto 79)=>read_data_out1,
		R(142 downto 111)=> pc_out_id_pip,
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>'1', 
		Q(4 downto 0)=>rd_ex_pip,
		Q(9 downto 5)=> rs1_ex_pip,
		Q(14 downto 10)=> rs2_ex_pip,
		Q(46 downto 15)=>immediate_in,
		Q(78 downto 47)=>execute_data_in2,
		Q(110 downto 79)=>execute_data_in1,
		Q(142 downto 111)=>pc_out_ex_pip);

--DECODE Control Pipeline
ID_EX_CTRL: regn_ld generic map(N => 12)
	port map (
		--Signals for WB stage
		R(0) => MemtoReg_CUmux,
		R(1) => RegWrite_CUmux,
		--Signals for MEM stage
		R(2) => MemRead_CUmux,
		R(3) => MemWrite_CUmux,
		R(4) => Jump_CUmux,
		R(5) => Branch_CUmux,
		--Signals for EXE stage
		R(6) => ALUSrc1_CUmux,
		R(8 downto 7) => ALUSrc2_CUmux,
		R(11 downto 9) => ALUOp_CUmux,
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>'1',		
		--Signals for WB stage
		Q(0) => MemtoReg_ex_pip,
		Q(1) => RegWrite_ex_pip,
		--Signals for MEM stage
		Q(2) => MemRead_ex_pip,
		Q(3) => MemWrite_ex_pip,
		Q(4) => Jump_ex_pip,
		Q(5) => Branch_ex_pip,
		--Signals for EXE stage
		Q(6) => ALUSrc1_ex_pip,
		Q(8 downto 7) => ALUSrc2_ex_pip,
		Q(11 downto 9) => ALUOp_ex_pip);

--Execute unit--------------------------------------------------------------
Execute : execute_stage 
	port map(
		ALUSrc1=>ALUSrc1_ex_pip,
		ALUSrc2=>ALUSrc2_ex_pip,
		ALUOp=>ALUOp_ex_pip,
		execute_data_in1=>execute_data_in1,
		execute_data_in2=>execute_data_in2,
		immediate_in=>immediate_in,
		rs1=>rs1_ex_pip,
		rs2=>rs2_ex_pip,

		pc_out=>pc_out_ex_pip,
		
		writeback_data_out=>writeback_data_out,
		ALU_result_in=>ALU_result_mem_pip,
		
		rd_mem_pip=>rd_mem_pip,
		rd_wb_pip=>rd_wb_pip,
		
		RFWrite_mem_pip => RegWrite_mem_pip,
		RFWrite_wb_pip => RegWrite_wb_pip,
		
		address_result=>address_result,
		DRAM_data_in => DRAM_data_in_exe,
		
		ALU_result=>ALU_result,
		zero=>zero
		);
--
EX_MEM : regn_ld generic map(N => 102) 
	port map(
		R(4 downto 0)=>rd_ex_pip,
		R(36 downto 5)=> DRAM_data_in_exe,
		R(68 downto 37)=>ALU_result,
		R(69)=>zero,
		R(101 downto 70)=>address_result,
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>'1', 
		Q(4 downto 0)=>rd_mem_pip,
		Q(36 downto 5)=>DRAM_data_in_mem_pip,
		Q(68 downto 37)=>ALU_result_mem_pip,
		Q(69)=>zero_mem_pip,
		Q(101 downto 70)=>pc_jump_addr_mem_pip);

--MEM Control Pipeline
EX_MEM_CTRL: regn_ld generic map(N => 6)
	port map (
		--Signals for WB stage
		R(0) => MemtoReg_ex_pip,
		R(1) => RegWrite_ex_pip,
		--Signals for MEM stage
		R(2) => MemRead_ex_pip,
		R(3) => MemWrite_ex_pip,
		R(4) => Jump_ex_pip,
		R(5) => Branch_ex_pip,
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>'1',		
		--Signals for WB stage
		Q(0) => MemtoReg_mem_pip,
		Q(1) => RegWrite_mem_pip,
		--Signals for MEM stage
		Q(2) => MemRead_mem_pip,
		Q(3) => MemWrite_mem_pip,
		Q(4) => Jump_mem_pip,
		Q(5) => Branch_mem_pip);




--Memory unit--------------------------------------------------------------
Memory : memory_stage 
	port map(
		zero_mem_pip=>zero_mem_pip,
		Branch_mem_pip=>Branch_mem_pip,
		jump_sel => Jump_mem_pip,
		branch_sel=>branch_sel
	);
 
data_mem_read <= MemRead_mem_pip;
data_mem_write <= MemWrite_mem_pip;
data_mem_addr <=ALU_result_mem_pip;
data_mem_in <= DRAM_data_in_mem_pip;

MEM_WB : regn_ld generic map(N => 38) 
	port map(
		R(4 downto 0) => rd_mem_pip, 
		R(36 downto 5) => ALU_result_mem_pip,
		R(37) => Branch_sel, 
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>'1', 
		Q(4 downto 0) => rd_wb_pip,
		Q(36 downto 5) => data_memory_bypass,
		Q(37) => Branch_sel_wb_pip
	);
data_mem_out_wb_pip<=data_mem_out;


--WB Control Pipeline
MEM_WB_CTRL: regn_ld generic map(N => 3)
	port map (
		--Signals for WB stage
		R(0) => MemtoReg_mem_pip,
		R(1) => RegWrite_mem_pip,
		R(2) => MemRead_mem_pip,
		Clock=>clock, 
		Resetn=>rst_n, 
		Load=>'1',		
		--Signals for WB stage
		Q(0) => MemtoReg_wb_pip,
		Q(1) => RegWrite_wb_pip,
		Q(2) => MemRead_wb_pip
		);


--Writeback unit--------------------------------------------------------------
Writeback : writeback_stage
	port map(
		data_memory_out=>data_mem_out_wb_pip,
		data_memory_bypass=>data_memory_bypass,
		mem_to_reg=>MemtoReg_wb_pip,
		writeback_data_out=>writeback_data_out
	);
--


end architecture beh;
