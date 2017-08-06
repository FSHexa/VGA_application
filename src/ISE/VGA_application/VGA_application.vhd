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
        VGA_BRAM_addr               : in    std_logic_vector(9 downto 0);
        VGA_BRAM_din                : in    std_logic_vector(23 downto 0);
        
        BUSY_MEMORY                 : out   std_logic;
        END_FRAME                   : out   std_logic;
        
        VGA_VSYNC                   : out   std_logic;
        VGA_HSYNC                   : out   std_logic;
        VGA_RED                     : out   std_logic_vector(7 downto 0);
        VGA_GREEN                   : out   std_logic_vector(7 downto 0);
        VGA_BLUE                    : out   std_logic_vector(7 downto 0));
end component;

component clk_gen
Port(   clk_in1                     : in    std_logic;
        CLK_out1                    : out   std_logic);
end component;
-- ============================================================================ --
--                                    Signal                                    --
-- ============================================================================ --
signal clk_vga                      : std_logic := '0';

signal s_vga_vsync              : std_logic := '1';
signal s_vga_hsync              : std_logic := '1';
signal s_vga_red                : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_green              : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_blue               : std_logic_vector(7 downto 0)  := X"00";

-- ============================================================================ --
--                                   Programm                                   --
-- ============================================================================ --
begin
-- ---------------------------------------------------------------------------- --
--                                  Components                                  --
-- ---------------------------------------------------------------------------- --
VGA_VSYNC   <= s_vga_vsync;
VGA_HSYNC   <= s_vga_hsync;
VGA_RED     <= s_vga_red(4 downto 0);
VGA_GREEN   <= s_vga_green(5 downto 0);
VGA_BLUE    <= s_vga_blue(4 downto 0);

VGA_Generate_inst: VGA_Generate
port map(   CLK                     => clk_vga,
            
            VGA_BRAM_clk            => '0',
            VGA_BRAM_en             => '0',
            VGA_BRAM_addr           => (others => '0'),
            VGA_BRAM_din            => (others => '0'),
            
            BUSY_MEMORY             => open,
            END_FRAME               => open,
            
            VGA_VSYNC               => s_vga_vsync,
            VGA_HSYNC               => s_vga_hsync,
            VGA_RED                 => s_vga_red,
            VGA_GREEN               => s_vga_green,
            VGA_BLUE                => s_vga_blue);
            
clk_gen_vga: clk_gen
Port map(clk_in1                => CLK,
         clk_out1               => clk_vga);
-- ---------------------------------------------------------------------------- --
--                                   Programm                                   --
-- ---------------------------------------------------------------------------- --
    
end Behavioral;