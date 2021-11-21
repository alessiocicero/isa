library verilog;
use verilog.vl_types.all;
entity IIR_filter is
    port(
        CLK             : in     vl_logic;
        RST_n           : in     vl_logic;
        H0              : in     vl_logic_vector(8 downto 0);
        H1              : in     vl_logic_vector(8 downto 0);
        H2              : in     vl_logic_vector(8 downto 0);
        H3              : in     vl_logic_vector(8 downto 0);
        VIN             : in     vl_logic;
        VOUT            : out    vl_logic;
        DIN             : in     vl_logic_vector(8 downto 0);
        DOUT            : out    vl_logic_vector(8 downto 0)
    );
end IIR_filter;
