
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;


entity IIR_filter is
	port (
		CLK     : in  std_logic;
		RST_n   : in  std_logic;
		H0     	: in std_logic_vector(8 downto 0);--b0
		H1     	: in std_logic_vector(8 downto 0);--b1
		H2     	: in std_logic_vector(8 downto 0);--a0
		H3     	: in std_logic_vector(8 downto 0);--a1
		VIN     : in std_logic;
		VOUT    : out std_logic;
		DIN     : in std_logic_vector(8 downto 0);
		DOUT    : out std_logic_vector(8 downto 0));
end IIR_filter;

architecture rtl of IIR_filter is
--Delay register output
signal wDelayRegOut,w1DelayRegOut,xDelayRegOut : signed(7 downto 0);
signal w,y : signed(7 downto 0);

--Coefficients
signal in_multa1, in_multb0,in_multb1: signed(7 downto 0);
signal in_multa1Squared: signed(7 downto 0);

--Mux signals
signal muxM1Output,muxM2Output: signed(7 downto 0);
signal M1Sel,M2Sel: std_logic;

--Multiplication result signals
signal multa1, multb0, multb1, multMuxRes : signed(15 downto 0);
--Multiplication saturated signals
signal multa1Sat,multb0Sat,multb1Sat,multMuxResSat: signed(7 downto 0);

--Addition results signals
signal subRes,wRes,yRes : signed(7 downto 0);
--Addition saturated signal
signal subResSat: signed(7 downto 0);

signal Din_8bit, DinRegOut, DoutRegOut,  PipReg1Out, PipReg3bOut, PipReg3aOut, PipReg2aOut, PipReg2bOut : signed(7 downto 0);
--Load pipeline signals
signal LOAD_CU,loadPip1,loadPip2,loadPip3 : std_logic;
--Load a1squared
signal LOAD_a1squared: std_logic;
--Vout pipeline signals
signal VOUT_CU,voutPip1,voutPip2: std_logic;
 
type CU_state is (RESET, RESTART, IDLE, RUN, RUNNING_RESTART, CONTINUOS_RUN, DONE);
signal current_state, next_state : CU_state;

COMPONENT regn_ld IS
	GENERIC ( N : integer := 8);
	PORT (R 	    : IN signed(N-1 DOWNTO 0);
	      Clock, Resetn, Load : IN STD_LOGIC;
	      Q 	    : out signed(N-1 DOWNTO 0));
END COMPONENT regn_ld;

component regn IS
	GENERIC ( N : integer:=8);
	PORT (R 	    : IN SIGNED(N-1 DOWNTO 0);
	      Clock, Resetn : IN STD_LOGIC;
	      Q 	    : OUT SIGNED(N-1 DOWNTO 0));
end component regn;

component check_overflow_add is
	port(Add_result	:IN signed (7 downto 0);
		Add1_MSB: IN STD_LOGIC;
		Add2_MSB: IN STD_LOGIC;
		Output	:OUT signed (7 downto 0));
end component check_overflow_add;

component check_overflow_mult is
	port(Mult_result: IN signed(15 downto 0);
		 Mult1_MSB	:IN std_logic;
		 Mult2_MSB  :IN std_logic;
		 Output	:OUT signed (7 downto 0));
end component check_overflow_mult;

component check_overflow_sub is
	port(Sub_result	:IN signed (7 downto 0);
		Add1_MSB: IN STD_LOGIC;
		Add2_MSB: IN STD_LOGIC;
		Output	:OUT signed (7 downto 0));
end component check_overflow_sub;

component flipflop is
	port( D, Clock, Resetn : IN STD_LOGIC;
			     Q : OUT STD_LOGIC);
end component flipflop;

component muxnbit_2to1 IS
	GENERIC(N : INTEGER := 7);
	PORT(X,Y : IN SIGNED(N-1 DOWNTO 0);
		s: IN STD_LOGIC;
    	     M : OUT SIGNED(N-1 DOWNTO 0));				 
END component muxnbit_2to1;

begin

State_register : process(CLK)
	begin
		if CLK'event and CLK = '1' then
			if RST_n = '0' then
				current_state <= RESET;
			else 
				current_state <= next_state;
			end if;
		end if;
end process;

State_transition : process(current_state, VIN)
	begin
	case current_state is
		when RESET =>
			if RST_n = '0' then
				next_state <=RESET;
			elsif VIN = '1' then
				next_state<=RUNNING_RESTART;
			else
				next_state<=RESTART;
			end if;

		when RESTART =>
			if VIN = '1' then
				next_state <= RUN;
			else
				next_state <= IDLE;	
			end if;	
				
		when RUNNING_RESTART =>
			if VIN = '1' then
				next_state <= CONTINUOS_RUN;
			else
				next_state <= DONE;	
			end if;
			
		when IDLE =>
			if VIN = '1' then
				next_state <= RUN;
			else
				next_state <= IDLE;	
			end if;

		when RUN =>
			if VIN = '1' then
				next_state <= CONTINUOS_RUN;
			else
				next_state <= DONE;
			end if;

		when  CONTINUOS_RUN =>
			if VIN = '1' then
				next_state <= CONTINUOS_RUN;
			else
				next_state <= DONE;
			end if;

		when DONE => 
			if VIN = '1' then
				next_state <= RUN;
			else
				next_state <= IDLE;	
			end if;
			
		when others =>
			if VIN = '1' then
				next_state <= RUN;
			else
				next_state <= IDLE;	
			end if;
	end case;
end process;

CU_Outputs : process(current_state)
	begin
	LOAD_CU <= '0';
	VOUT_CU <= '0';
	M1Sel <= '0';
	M2Sel <= '0';
	LOAD_a1squared <= '0';
	case current_state is
		when RESET =>
		
		when RESTART =>
			M1Sel <= '1';
			M2Sel <= '1';
			LOAD_a1squared <= '1';
			
		when RUNNING_RESTART =>
			M1Sel <= '1';
			M2Sel <= '1';
			LOAD_a1squared <= '1';
			LOAD_CU <= '1';
			
		when IDLE =>
			
		when RUN =>
			LOAD_CU <= '1';

		when CONTINUOS_RUN =>
			LOAD_CU <= '1';
			VOUT_CU <= '1';

		when DONE =>
			VOUT_CU <= '1';
			
		when others =>

	end case;
end process;

   	Din_8bit<=signed(DIN(8 downto 1));
	in_multa1(7 downto 0) <= signed(H3(8 downto 1));
	in_multb0(7 downto 0) <= signed(H0(8 downto 1));
	in_multb1(7 downto 0) <= signed(H1(8 downto 1));

DinReg : regn generic map(N => 8) port map(R => Din_8bit, Clock => CLK, Resetn => RST_n, Q => DinRegOut);

	multa1 <= DinRegOut * in_multa1;
chk_ovf_multa1: check_overflow_mult port map(Mult_result => multa1, Mult1_MSB => DinRegOut(7), Mult2_MSB => in_multa1(7), Output=> multa1Sat);

xDelayReg: regn_ld generic map(N=>8) port map(R => multa1Sat, Clock => CLK, Resetn => RST_n, Load => LOAD_CU, Q => xDelayRegOut);

	subRes <= DinRegOut - xDelayRegOut;
chk_ovf_sub1: check_overflow_sub port map(Sub_result => subRes, Add1_MSB=>DinRegOut(7),Add2_MSB =>xDelayRegOut(7),Output=>subResSat);

--Pipeline1
PipelineReg1 : regn generic map(N => 8) port map(R => subResSat, Clock => CLK, Resetn => RST_n, Q => PipReg1Out);

--Calculate w
	wRes <= PipReg1Out + w1DelayRegOut;
chk_ovf_wRes: check_overflow_add port map(Add_result => wRes, Add1_MSB => PipReg1Out(7), Add2_MSB => w1DelayRegOut(7), Output=> w);

--W[n-1]
wDelayReg : regn_ld generic map(N => 8) port map(R => w, Clock => CLK, Resetn => RST_n, Load => loadPip1, Q => wDelayRegOut);

--Mux
MuxM1: muxnbit_2to1 generic map(N => 8) port map(X => in_multa1Squared, Y=> in_multa1 ,s => M1Sel , M => muxM1Output);
MuxM2: muxnbit_2to1 generic map(N => 8) port map(X => wDelayRegOut, Y=> in_multa1 ,s => M2Sel , M => muxM2Output); 

	multMuxRes <= muxM1Output * MuxM2Output;
chk_ovf_multMux: check_overflow_mult port map(Mult_result => multMuxRes, Mult1_MSB => muxM1Output(7), Mult2_MSB => muxM2Output(7), Output=> multMuxResSat);

--w[n-2]
w1DelayReg : regn_ld generic map(N => 8) port map(R => MultMuxResSat, Clock => CLK, Resetn => RST_n, Load => loadPip1, Q => w1DelayRegOut);

--a1Squared register
a1SquaredReg: regn_ld generic map(N => 8) port map(R => multMuxResSat, Clock => CLK, Resetn => RST_n, Load => LOAD_a1squared, Q => in_multa1Squared);

--Pipeline 2
PipelineReg2a : regn generic map(N => 8) port map(R => w, Clock => CLK, Resetn => RST_n, Q => PipReg2aOut);
PipelineReg2b : regn generic map(N => 8) port map(R => wDelayRegOut, Clock => CLK, Resetn => RST_n, Q => PipReg2bOut);

--Mult b0
	multb0 <= PipReg2aOut * in_multb0;
chk_ovf_multb0: check_overflow_mult port map(Mult_result => multb0, Mult1_MSB => PipReg2aOut(7), Mult2_MSB => in_multb0(7), Output=> multb0Sat);

--Mult b1
	multb1 <= PipReg2bOut * in_multb1;
chk_ovf_multb1: check_overflow_mult port map(Mult_result => multb1, Mult1_MSB => PipReg2bOut(7), Mult2_MSB => in_multb1(7), Output=> multb1Sat);

--Pipeline 3
PipelineReg3a : regn generic map(N => 8) port map(R => multb0Sat, Clock => CLK, Resetn => RST_n, Q => PipReg3aOut);
PipelineReg3b : regn generic map(N => 8) port map(R => multb1Sat, Clock => CLK, Resetn => RST_n, Q => PipReg3bOut);

--Y calculation
	yRes <= PipReg3aOut + PipReg3bOut;
chk_ovf_yRes: check_overflow_add port map(Add_result => yRes, Add1_MSB => PipReg3aOut(7), Add2_MSB => PipReg3bOut(7), Output=> y);

--Save in DoutReg
DoutReg : regn_ld generic map(N => 8) port map(R => y, Clock => CLK, Resetn => RST_n, Load => loadPip3, Q => DoutRegOut);
	DOUT(8 downto 1) <= std_logic_vector(DoutRegOut);
	DOUT(0) <= '0';

--Pipeline Load
LoadPipeline1 : flipflop port map( D => LOAD_CU, Clock => CLK, Resetn => RST_n, Q =>loadPip1);
LoadPipeline2 : flipflop port map( D => loadPip1, Clock => CLK, Resetn => RST_n, Q =>loadPip2);
LoadPipeline3 : flipflop port map( D => loadPip2, Clock => CLK, Resetn => RST_n, Q =>loadPip3);

--Pipeline Vout
VoutPipeline1 : flipflop port map( D => VOUT_CU, Clock => CLK, Resetn => RST_n, Q =>voutPip1);
VoutPipeline2 : flipflop port map( D => voutPip1, Clock => CLK, Resetn => RST_n, Q =>voutPip2);
VoutPipeline3 : flipflop port map( D => voutPip2, Clock => CLK, Resetn => RST_n, Q =>VOUT);

end rtl;

