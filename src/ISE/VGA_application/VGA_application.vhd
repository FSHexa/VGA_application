-- ============================================================================================================= --
-- Название     : VGA_application
-- Проект       : VGA_application
-- Версия       : 1.0.0
-- Автор        : FSHexa
-- Компания     : 
-- Файл         : VGA_application.vhd
-- Создано      : 06.08.2017
-- ------------------------------------------------------------------------------------------------------------- --
-- Описание файла:
--      
-- UPD  
-- ============================================================================================================= --
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity VGA_application is
Port(   CLK                         : in    std_logic;
        
        VGA_VSYNC                   : out   std_logic;
        VGA_HSYNC                   : out   std_logic;
        VGA_RED                     : out   std_logic_vector(4 downto 0);
        VGA_GREEN                   : out   std_logic_vector(5 downto 0);
        VGA_BLUE                    : out   std_logic_vector(4 downto 0));
end VGA_application;

architecture Behavioral of VGA_application is
-- ============================================================================ --
--                                  Components                                  --
-- ============================================================================ --
component VGA_Generate
Port(   CLK                         : in    std_logic;
        
        VGA_BRAM_clk                : in    std_logic;
        VGA_BRAM_en                 : in    std_logic;
        VGA_BRAM_we                 : in    std_logic_vector(0 downto 0);
        VGA_BRAM_addr               : in    std_logic_vector(10 downto 0);
        VGA_BRAM_din                : in    std_logic_vector(23 downto 0);
        
        BUSY_MEMORY                 : out   std_logic;
        END_FRAME                   : out   std_logic;
        
        VGA_VSYNC                   : out   std_logic;
        VGA_HSYNC                   : out   std_logic;
        VGA_RED                     : out   std_logic_vector(7 downto 0);
        VGA_GREEN                   : out   std_logic_vector(7 downto 0);
        VGA_BLUE                    : out   std_logic_vector(7 downto 0));
end component;

component bram_plane
port(   clka                        : in    std_logic;
        addra                       : in    std_logic_vector(6 downto 0);
        douta                       : out   std_logic_vector(63 downto 0));
end component;

component clk_gen
Port(   clk_in1                     : in    std_logic;
        CLK_out1                    : out   std_logic);
end component;
-- ============================================================================ --
--                                    Signal                                    --
-- ============================================================================ --
signal clk_vga                      : std_logic := '0';

signal s_vga_vsync                  : std_logic := '1';
signal s_vga_hsync                  : std_logic := '1';
signal s_vga_red                    : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_green                  : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_blue                   : std_logic_vector(7 downto 0)  := X"00";

signal not_clk_vga                  : std_logic := '0';
signal vga_bram_en                  : std_logic := '0';
signal vga_bram_we                  : std_logic_vector(0 downto 0)  := "0";
signal vga_bram_addr                : std_logic_vector(10 downto 0) := (others => '0');
signal s_vga_bram_addr              : std_logic_vector(9 downto 0)  := (others => '0');
signal f_vga_bram_addr              : std_logic := '0';
signal vga_bram_din                 : std_logic_vector(23 downto 0) := (others => '0');

signal plane_en                     : std_logic := '0';
signal plane_addr                   : std_logic_vector(6 downto 0)  := (others => '0');
signal plane_dout                   : std_logic_vector(63 downto 0) := (others => '0');

signal busy_memory                  : std_logic:= '0';
signal end_frame                    : std_logic:= '0';

signal coord_x                      : integer range 0 to 1023   := 0;
signal coord_y                      : integer range 0 to 727    := 0;

signal coord_plane_x                : integer range 0 to 1023   := 50;
signal coord_plane_y                : integer range 0 to 727    := 50;

type t_type                         is array (0 to 1023)    of std_logic_vector (7 downto 0);
signal string_plane                 : t_type := (others => (others => '0'));

type state_type                     is (GENERATE_STRING, WRITE_STRING);
signal state                        : state_type    := GENERATE_STRING;

signal f_frame                      : std_logic := '0';

signal state_plane                  : integer   := 0;
-- ============================================================================ --
--                                   Programm                                   --
-- ============================================================================ --
begin
-- ---------------------------------------------------------------------------- --
--                                  Components                                  --
-- ---------------------------------------------------------------------------- --
VGA_VSYNC   <= s_vga_vsync;
VGA_HSYNC   <= s_vga_hsync;
VGA_RED     <= s_vga_red(7 downto 3);
VGA_GREEN   <= s_vga_green(7 downto 2);
VGA_BLUE    <= s_vga_blue(7 downto 3);

VGA_Generate_inst: VGA_Generate
port map(   CLK                     => clk_vga,
            
            VGA_BRAM_clk            => not_clk_vga,
            VGA_BRAM_en             => vga_bram_en,
            VGA_BRAM_we             => vga_bram_we,
            VGA_BRAM_addr           => vga_bram_addr,
            VGA_BRAM_din            => vga_bram_din,
            
            BUSY_MEMORY             => busy_memory,
            END_FRAME               => end_frame,
            
            VGA_VSYNC               => s_vga_vsync,
            VGA_HSYNC               => s_vga_hsync,
            VGA_RED                 => s_vga_red,
            VGA_GREEN               => s_vga_green,
            VGA_BLUE                => s_vga_blue);

bram_plane_inst: bram_plane
port map(   clka                    => not_clk_vga,
            addra                   => plane_addr,
            douta                   => plane_dout);

vga_bram_addr   <= f_vga_bram_addr & s_vga_bram_addr;
not_clk_vga     <= not(clk_vga);

clk_gen_vga: clk_gen
Port map(   clk_in1                 => CLK,
            clk_out1                => clk_vga);
-- ---------------------------------------------------------------------------- --
--                                   Programm                                   --
-- ---------------------------------------------------------------------------- --
process(clk_vga)
begin
    if(rising_edge(clk_vga)) then
        if(end_frame = '0') then
            f_vga_bram_addr <= '0';
            s_vga_bram_addr <= (others => '0');
            plane_addr      <= (others => '0');
            coord_y         <= 0;
        else
            if(busy_memory = '1') then
                state_plane     <= 0;
                vga_bram_en     <= '1';
                vga_bram_we     <= "1";
                s_vga_bram_addr <= s_vga_bram_addr + 1;
                case string_plane(conv_integer(s_vga_bram_addr)) is
                    when x"00" => vga_bram_din <= X"FFFFFF";
                    when x"01" => vga_bram_din <= X"2A2A2A";
                    when x"02" => vga_bram_din <= X"4b4b4b";
                    when x"03" => vga_bram_din <= X"7f7f7f";
                    when x"04" => vga_bram_din <= X"000000";
                    when x"05" => vga_bram_din <= X"053f61";
                    when x"06" => vga_bram_din <= X"20839b";
                    when x"07" => vga_bram_din <= X"99d9ea";
                    when x"08" => vga_bram_din <= X"fb6d04";
                    when others => vga_bram_din <= X"FFFFFF";
                end case;
                -- vga_bram_din    <= string_plane(conv_integer(s_vga_bram_addr));
                if(s_vga_bram_addr = "1111111111") then
                    f_vga_bram_addr <= not(f_vga_bram_addr);
                    coord_y         <= coord_y + 1;
                end if;
            else
                if(coord_y >= coord_plane_y and coord_y < coord_plane_y + 63) then
                    -- plane_addr  <= conv_std_logic_vector((coord_y - coord_plane_y), 7);
                    case state_plane is
                        when 0  => 
                            string_plane(coord_plane_x)         <= plane_dout(63 downto 56);
                            string_plane(coord_plane_x + 1)     <= plane_dout(55 downto 48);
                            string_plane(coord_plane_x + 2)     <= plane_dout(47 downto 40);
                            string_plane(coord_plane_x + 3)     <= plane_dout(39 downto 32);
                            string_plane(coord_plane_x + 4)     <= plane_dout(31 downto 24);
                            string_plane(coord_plane_x + 5)     <= plane_dout(23 downto 16);
                            string_plane(coord_plane_x + 6)     <= plane_dout(15 downto 8);
                            string_plane(coord_plane_x + 7)     <= plane_dout(7 downto 0);
                            string_plane(coord_plane_x + 31)    <= plane_dout(63 downto 56);
                            string_plane(coord_plane_x + 30)    <= plane_dout(55 downto 48);
                            string_plane(coord_plane_x + 29)    <= plane_dout(47 downto 40);
                            string_plane(coord_plane_x + 28)    <= plane_dout(39 downto 32);
                            string_plane(coord_plane_x + 27)    <= plane_dout(31 downto 24);
                            string_plane(coord_plane_x + 26)    <= plane_dout(23 downto 16);
                            string_plane(coord_plane_x + 25)    <= plane_dout(15 downto 8);
                            string_plane(coord_plane_x + 24)    <= plane_dout(7 downto 0);
                            state_plane                         <= 1;
                            plane_addr  <= plane_addr + 1;
                        when 1  => 
                            string_plane(coord_plane_x + 8)     <= plane_dout(63 downto 56);
                            string_plane(coord_plane_x + 9)     <= plane_dout(55 downto 48);
                            string_plane(coord_plane_x + 10)    <= plane_dout(47 downto 40);
                            string_plane(coord_plane_x + 11)    <= plane_dout(39 downto 32);
                            string_plane(coord_plane_x + 12)    <= plane_dout(31 downto 24);
                            string_plane(coord_plane_x + 13)    <= plane_dout(23 downto 16);
                            string_plane(coord_plane_x + 14)    <= plane_dout(15 downto 8);
                            string_plane(coord_plane_x + 15)    <= plane_dout(7 downto 0);
                            string_plane(coord_plane_x + 23)    <= plane_dout(63 downto 56);
                            string_plane(coord_plane_x + 22)    <= plane_dout(55 downto 48);
                            string_plane(coord_plane_x + 21)    <= plane_dout(47 downto 40);
                            string_plane(coord_plane_x + 20)    <= plane_dout(39 downto 32);
                            string_plane(coord_plane_x + 19)    <= plane_dout(31 downto 24);
                            string_plane(coord_plane_x + 18)    <= plane_dout(23 downto 16);
                            string_plane(coord_plane_x + 17)    <= plane_dout(15 downto 8);
                            string_plane(coord_plane_x + 16)    <= plane_dout(7 downto 0);
                            state_plane                         <= 2;
                            plane_addr  <= conv_std_logic_vector((coord_y - coord_plane_y), 6) & '0';
                        when others => null;
                    end case;
                else
                    string_plane    <= (others => (others => '0'));
                end if;
            end if;
            
            -- case state is
                -- --------------------------
                -- when GENERATE_STRING    =>
                -- --------------------------
                    -- -- =================================================================== --
                        -- if(
                    -- -- =================================================================== --
                -- --------------------------
                -- when WRITE_STRING       =>
                -- --------------------------
                    -- -- =================================================================== --
                        -- string_plane    <= ;
                    -- -- =================================================================== --
            -- end case;
        end if;
    end if;
end process;

end Behavioral;