library verilog;
use verilog.vl_types.all;
entity keyscan is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        row             : out    vl_logic_vector(3 downto 0);
        col             : in     vl_logic_vector(3 downto 0);
        led             : out    vl_logic_vector(3 downto 0)
    );
end keyscan;
