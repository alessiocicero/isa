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

signal feedback, feedforward : signed(15 downto 0);
--Eventually saturated signals
signal feedback_sat,feedforward_sat: signed(7 downto 0);
signal delayRegOut : signed(7 downto 0);
signal w : signed(7 downto 0);
signal w_sat: signed (7 downto 0);

signal multb0 : signed(15 downto 0);
signal multb0_sat: signed(7 downto 0);
signal in_multa, in_multb0, in_multb1 : signed(7 downto 0);
signal DOUT_s : signed(7 downto 0);
--Addition saturated signal
signal DOUT_s_sat: signed(7 downto 0);

signal Din_8bit, DinRegOut, DoutRegOut : signed(7 downto 0);
signal reg_enable : std_logic;

type CU_state is (RESET, IDLE, RUN, CONTINUOS_RUN, DONE);
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

begin

DinReg : regn generic map(N => 8) port map(R => Din_8bit, Clock => CLK, Resetn => RST_n, Q => DinRegOut);
delayReg : regn_ld generic map(N => 8) port map(R => w_sat, Clock => CLK, Resetn => RST_n, Load => reg_enable, Q => delayRegOut);
DoutReg : regn_ld generic map(N => 8) port map(R => DOUT_s_sat, Clock => CLK, Resetn => RST_n, Load => reg_enable, Q => DoutRegOut);

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
				next_state<=RUN;
			else
				next_state<=IDLE;
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
	reg_enable <= '0';
	VOUT <= '0';
	case current_state is
		when RESET =>
		when IDLE =>
			
		when RUN =>
			reg_enable <= '1';

		when CONTINUOS_RUN =>
			reg_enable <= '1';
			VOUT <= '1';

		when DONE =>
			VOUT <= '1';
			
		when others =>
	end case;
end process;

   	Din_8bit<=signed(DIN(8 downto 1));
	in_multa(7 downto 0) <= signed(H3(8 downto 1));
	in_multb0(7 downto 0) <= signed(H0(8 downto 1));
	in_multb1(7 downto 0) <= signed(H1(8 downto 1));

   	feedback <= delayRegOut * signed(H3(8 downto 1));
	feedforward <= delayRegOut * signed(H1(8 downto 1));
--check the multiplication results
chk_ovf_fb: check_overflow_mult port map(Mult_result => feedback, Mult1_MSB => delayRegOut(7), Mult2_MSB => H3(8), Output=> feedback_sat);

chk_ovf_ff: check_overflow_mult port map(Mult_result => feedforward, Mult1_MSB => delayRegOut(7), Mult2_MSB => H1(8), Output=> feedforward_sat);


	w <= DinRegOut - feedback_sat;--To fix because I didn't do for subtraction

chk_ovf_w: check_overflow_sub port map(Sub_result => w, Add1_MSB=>DinRegOut(7),Add2_MSB =>feedback_sat(7),Output=>w_sat);
	multb0 <= w_sat*signed(H0(8 downto 1));

chk_ovf_multb0: check_overflow_mult port map(Mult_result => multb0, Mult1_MSB => w(7), Mult2_MSB => H0(8), Output=> multb0_sat);

	--DOUT_s <= (multb0_sat(7) & multb0_sat) + (feedforward_sat(7) & feedforward_sat);
	DOUT_s <= multb0_sat + feedforward_sat;

chk_ovf_douts: check_overflow_add port map(Add_result => DOUT_s, Add1_MSB => multb0_sat(7), Add2_MSB => feedforward_sat(7), Output=> DOUT_s_sat);


	DOUT(8 downto 1) <= std_logic_vector(DoutRegOut);
	DOUT(0) <= '0';

end rtl;

