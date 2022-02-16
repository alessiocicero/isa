library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity execute_stage is
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
end entity execute_stage;

architecture rtl of execute_stage is

--shift signals
signal immed_leftshft1 : std_logic_vector(19 downto 0) ;

--mux signals
signal muxdatain1_out,muxdatain2_out : std_logic_vector(31 downto 0);

signal forwardA :	std_logic_vector(1 downto 0) ;
signal forwardB :	std_logic_vector(1 downto 0) ;

--ALU signals
signal ALU_in1,ALU_in2 : std_logic_vector(31 downto 0) ;


component muxnbit_2to1 IS
	GENERIC(N : INTEGER := 7);
	PORT(X,Y : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		s: IN STD_LOGIC;
    	     M : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));				 
end component;

component muxnbit_4to1 is
	generic(N : integer := 7);
	port(
		X,Y,Z,Q : in std_logic_vector(N-1 downto 0);
		  	  s : in std_logic_vector(1 downto 0);
    	  	M : out std_logic_vector(N-1 downto 0)) ;
end component ; -- muxnbit_4to1

component forwarding_unit is
	port(	
		rs1:	in std_logic_vector(4 downto 0);
		rs2:	in std_logic_vector(4 downto 0);
		rd_wb_pip: in std_logic_vector(4 downto 0);
		rd_mem_pip: in std_logic_vector(4 downto 0);
		RFWrite_mem_pip: in std_logic;
		RFWrite_wb_pip: in std_logic;
		forwardA:	out std_logic_vector(1 downto 0);
		forwardB:	out std_logic_vector(1 downto 0));
end component;

component ALU is
  port( A, B : in std_logic_vector(31 downto 0);
        ALU_cmd : in std_logic_vector(2 downto 0);
        result : out std_logic_vector(31 downto 0);
        zero : out std_logic);
end component;

begin

fwd : forwarding_unit
	port map(	
		rs1			=>	rs1, 
		rs2			=>	rs2, 
		rd_wb_pip	=>	rd_wb_pip,
		rd_mem_pip	=>	rd_mem_pip,
		RFWrite_mem_pip => RFWrite_mem_pip,
		RFWrite_wb_pip => RFWrite_wb_pip,
		forwardA	=>	forwardA,
		forwardB	=>	forwardB
	);

muxdatain1 : muxnbit_2to1 generic map(N=>32) 
	port map(
		X=>execute_data_in1, 
		Y=>pc_out, --Used for AUIPC 
		s=>ALUSrc1, 
		M=>muxdatain1_out);

muxdatain2 : muxnbit_4to1 generic map(N=>32) 
	port map(
		X=>execute_data_in2, 
		Y=>ALU_result_in, 
		Z=>writeback_data_out, 
		Q=>(others=>'0'), --unused
		s=>forwardB, 
		M=>muxdatain2_out);
	
DRAM_data_in<=muxdatain2_out;

muxALUin1 : muxnbit_4to1 generic map(N=>32) 
	port map(
		X=>muxdatain1_out, 
		Y=>writeback_data_out, 
		Z=>ALU_result_in, 
		Q=>(others=>'0'),--unused
		s=>forwardA, 
		M=>ALU_in1);

muxALUin2 : muxnbit_4to1 generic map(N=>32) 
	port map(
		X=>muxdatain2_out, 
		Y=>immediate_in, 
		Z=>x"00000004", 
		Q=>(others=>'0'),
		s=>ALUSrc2, 
		M=>ALU_in2);


ALU_1 : ALU port map(
	A=>ALU_in1, 
	B=>ALU_in2, 
	ALU_cmd=>ALUOp, 
	result=>ALU_result, 
	zero=>zero);

immed_leftshft1(19 downto 1) <= immediate_in(18 downto 0);
immed_leftshft1(0) <= '0';

address_result <= std_logic_vector(signed(immed_leftshft1) + signed(pc_out)); 

end architecture rtl;
