library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
library UNISIM;
use UNISIM.VComponents.all;

entity TEST_VGA_application is
-- Port(   Port_i                      : in    std_logic);
end TEST_VGA_application;

architecture Behavioral of TEST_VGA_application is
-- ============================================================================ --
--                                  Components                                  --
-- ============================================================================ --
component VGA_application
port(   CLK                         : in    std_logic;
        VGA_VSYNC                   : out   std_logic;
        VGA_HSYNC                   : out   std_logic;
        VGA_RED                     : out   std_logic_vector(4 downto 0);
        VGA_GREEN                   : out   std_logic_vector(5 downto 0);
        VGA_BLUE                    : out   std_logic_vector(4 downto 0));
end component;
-- ============================================================================ --
--                                    Signal                                    --
-- ============================================================================ --
constant t_clk                      : time  := 10 ns;
signal clk                          : std_logic := '0';
signal c_1us                        : integer   := 0;

-- ============================================================================ --
--                                   Programm                                   --
-- ============================================================================ --
begin
-- ---------------------------------------------------------------------------- --
--                                  Components                                  --
-- ---------------------------------------------------------------------------- --
VGA_application_inst: VGA_application
port map(   CLK                     => CLK,
            VGA_VSYNC               => open,
            VGA_HSYNC               => open,
            VGA_RED                 => open,
            VGA_GREEN               => open,
            VGA_BLUE                => open);
-- ---------------------------------------------------------------------------- --
--                                   Programm                                   --
-- ---------------------------------------------------------------------------- --
process
begin
    wait for 1 us;
        c_1us   <=  c_1us + 1;
end process;

process
begin
    wait for t_clk/2;
        clk <= not(clk);
end process;
    
-- write_input: 
-- process  
    -- variable fline: line;
    -- file out_file: text open write_mode is "test_file.txt";
-- begin
    -- wait until falling_edge(CLK);
        -- write(fline, conv_integer( sig )));
        -- write(fline,'*');
        -- writeline(out_file, fline);
-- end process;

end Behavioral;