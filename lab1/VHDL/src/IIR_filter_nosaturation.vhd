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
signal delayRegOut : signed(7 downto 0);
signal w : signed(7 downto 0);
signal multb0 : signed(15 downto 0);
signal in_multa, in_multb0, in_multb1 : signed(7 downto 0);
signal DOUT_s : signed(7 downto 0);
signal Din_8bit, DinRegOut, DoutRegOut : signed(7 downto 0);
signal reg_enable : std_logic;
signal din_reg_enable : std_logic;

type CU_state is (RESET, IDLE, RUN, CONTINUOS_RUN, DONE);
signal current_state, next_state : CU_state;

COMPONENT regn_ld IS
	GENERIC ( N : integer := 8);
	PORT (R 	    : IN signed(N-1 DOWNTO 0);
	      Clock, Resetn, Load : IN STD_LOGIC;
	      Q 	    : out signed(N-1 DOWNTO 0));
END COMPONENT regn_ld;

begin

DinReg : regn_ld generic map(N => 8) port map(R => Din_8bit, Clock => CLK, Resetn => RST_n, Load => din_reg_enable, Q => DinRegOut);
delayReg : regn_ld generic map(N => 8) port map(R => w, Clock => CLK, Resetn => RST_n, Load => reg_enable, Q => delayRegOut);
DoutReg : regn_ld generic map(N => 8) port map(R => DOUT_s, Clock => CLK, Resetn => RST_n, Load => reg_enable, Q => DoutRegOut);

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
			next_state <= IDLE;

	end case;
end process;

CU_Outputs : process(current_state)
	begin
	reg_enable <= '0';
	din_reg_enable <= '1';   --E' da rimuovere e mettere un registro normale AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
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

	end case;
end process;

   	Din_8bit<=signed(DIN(8 downto 1));
	in_multa(7 downto 0) <= signed(H3(8 downto 1));
	in_multb0(7 downto 0) <= signed(H0(8 downto 1));
	in_multb1(7 downto 0) <= signed(H1(8 downto 1));
	--begin 
	--sign_extend:
	--for i in 8 to 15 generate
	--	in_multa(i) <= in_multa(7);
	--end for
   	feedback <= delayRegOut * signed(H3(8 downto 1));
	feedforward <= delayRegOut * signed(H1(8 downto 1));
	w <= DinRegOut - feedback(14 downto 7);
	multb0 <= w*signed(H0(8 downto 1));
	DOUT_s <= multb0(14 downto 7) + feedforward(14 downto 7);
	DOUT(8 downto 1) <= std_logic_vector(DoutRegOut);
	DOUT(0) <= '0';

end rtl;

