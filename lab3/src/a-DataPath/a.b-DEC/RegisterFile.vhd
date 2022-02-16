LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY RegisterFile IS
   PORT(
      clk:  in std_logic;
      RESET_n:      in    std_logic;
      RegWrite:   in    std_logic;
      ADD_RA:     in  std_logic_vector(4 downto 0);
      ADD_RB:     in  std_logic_vector(4 downto 0);
      ADD_W:      in  std_logic_vector(4 downto 0);
      RF_DataIn:  in  std_logic_vector(31 downto 0);
      RA:         out std_logic_vector(31 downto 0);
      RB:      out std_logic_vector(31 downto 0)
      );
END ENTITY RegisterFile;

ARCHITECTURE rtl OF RegisterFile IS

   TYPE mem IS ARRAY(0 TO 31) OF std_logic_vector(31 DOWNTO 0);
   SIGNAL reg_block : mem;

BEGIN
   PROCESS(clk,RESET_n)
   BEGIN
         IF (RESET_n = '0') THEN
            reg_block <= (OTHERS => (OTHERS => '0'));
         ELSE
            if(rising_edge(clk)) then
               if (RegWrite = '1') and (ADD_W /= "00000") then
                  reg_block(to_integer(unsigned(ADD_W))) <= RF_DataIn;
               --else
               --   reg_block(to_integer(unsigned(ADD_W))) <= reg_block(to_integer(unsigned(ADD_W)));
               end if ;
               --RA <= reg_block(to_integer(unsigned(ADD_RA)));
               --RB <= reg_block(to_integer(unsigned(ADD_RB)));
            end if;
         END IF;
   END PROCESS;

   RA <= reg_block(to_integer(unsigned(ADD_RA)));
   RB <= reg_block(to_integer(unsigned(ADD_RB)));

END ARCHITECTURE rtl;
