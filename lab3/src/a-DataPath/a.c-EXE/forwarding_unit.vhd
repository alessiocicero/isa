library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is
	port(	rs1:	in std_logic_vector(4 downto 0);
			rs2:	in std_logic_vector(4 downto 0);
			rd_wb_pip: in std_logic_vector(4 downto 0);
			rd_mem_pip: in std_logic_vector(4 downto 0);
			RFWrite_mem_pip: in std_logic;
			RFWrite_wb_pip: in std_logic;
			forwardA:	out std_logic_vector(1 downto 0);
			forwardB:	out std_logic_vector(1 downto 0));
end entity;

architecture beh of forwarding_unit is
begin
forward_process:process(rs1,rs2,rd_wb_pip,rd_mem_pip,RFWrite_mem_pip,RFWrite_wb_pip)
	begin	
		forwardA <= "00";
		forwardB <= "00";
		if(rs1 = "00000") then
		else
			if (rs1 = rd_mem_pip) AND (RFWrite_mem_pip = '1') then
				--Pipelined value of the ALU
				forwardA <= "10";
			elsif(rs1 = rd_wb_pip) 	AND (RFWrite_wb_pip = '1')then
				--Pipelined value of the data memory
				forwardA <= "01";
			end if;
		end if;
		if(rs2 = "00000") then
		else
			if (rs2 = rd_mem_pip) AND (RFWrite_mem_pip = '1') then
				--Pipelined value of the ALU
				forwardB <= "01";
			elsif(rs2 = rd_wb_pip) AND (RFWrite_wb_pip = '1')	then
				--Pipelined value of the data memory
				forwardB <= "10";
			end if;
		end if;
	end process;
end architecture;
