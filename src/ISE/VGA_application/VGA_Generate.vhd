-- ============================================================================================================= --
-- Название     : VGA_Generate
-- Проект       : VGA_application
-- Версия       : 1.0.0
-- Автор        : FSS
-- Компания     : FSHexa
-- Файл         : VGA_Generate.vhd
-- Создано      : 24.07.2017
-- ------------------------------------------------------------------------------------------------------------- --
-- Описание файла:
--      Формирует синхроимпульсы для VGA и выводит строку.
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

entity VGA_Generate is
Port(   CLK                         : in    std_logic;
        
        VGA_BRAM_clk                : in    std_logic;
        VGA_BRAM_en                 : in    std_logic;
        VGA_BRAM_addr               : in    std_logic_vector(9 downto 0);
        VGA_BRAM_din                : in    std_logic_vector(23 downto 0);
        
        BUSY_MEMORY                 : out   std_logic;
        END_FRAME                   : out   std_logic;
        
        VGA_VSYNC                   : out   std_logic;
        VGA_HSYNC                   : out   std_logic;
        VGA_RED                     : out   std_logic_vector(4 downto 0);
        VGA_GREEN                   : out   std_logic_vector(5 downto 0);
        VGA_BLUE                    : out   std_logic_vector(4 downto 0));
end VGA_Generate;

architecture Behavioral of VGA_Generate is
-- ============================================================================ --
--                                  Components                                  --
-- ============================================================================ --
component VGA_BRAM
port(   clka                        : in    std_logic;
        ena                         : in    std_logic;
        addra                       : in    std_logic_vector(9 downto 0);
        dina                        : in    std_logic_vector(23 downto 0);
        
        clkb                        : in    std_logic;
        enb                         : in    std_logic;
        addrb                       : in    std_logic_vector(9 downto 0);
        doutb                       : out   std_logic_vector(23 downto 0));
end component;
-- ============================================================================ --
--                                    Signal                                    --
-- ============================================================================ --
signal str_bram_clk                 : std_logic := '0';
signal str_bram_en                  : std_logic := '0';
signal str_bram_addr                : std_logic_vector(9 downto 0)  := (others => '0');
signal str_bram_dout                : std_logic_vector(23 downto 0) := (others => '0');

signal s_vga_vsync                  : std_logic := '1';
signal s_vga_hsync                  : std_logic := '1';
signal s_vga_red                    : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_green                  : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_blue                   : std_logic_vector(7 downto 0)  := X"00";
-- ==================================================== --
-- Vertical_sync
-- ---------------------------------------------------- --
type t_state                        is (SYNC, SYNC_DEL, DATA, DATA_DEL);
signal v_state                      : t_state   := SYNC;
signal h_state                      : t_state   := SYNC;

signal c_vga_vsync                  : integer   := 0;
signal c_vga_hsync                  : integer   := 0;
-- ============================================================================ --
--                                   Programm                                   --
-- ============================================================================ --
begin
-- ---------------------------------------------------------------------------- --
--                                  Components                                  --
-- ---------------------------------------------------------------------------- --
VGA_BRAM_inst: VGA_BRAM
port map(   clka                    => VGA_BRAM_clk,
            ena                     => VGA_BRAM_en,
            addra                   => VGA_BRAM_addr,
            dina                    => VGA_BRAM_din,
            
            clkb                    => str_bram_clk,
            enb                     => str_bram_en,
            addrb                   => str_bram_addr,
            doutb                   => str_bram_dout);
-- ---------------------------------------------------------------------------- --
--                                   Programm                                   --
-- ---------------------------------------------------------------------------- --

-- ==================================================== --
-- Process info                                         --
-- ==================================================== --
process(VGA_BRAM_clk)
begin
    if(rising_edge(VGA_BRAM_clk)) then
    
        case v_state is
            ----------------------
            when SYNC           =>
            ----------------------
                -- =================================================================== --
                    
                -- =================================================================== --
            ----------------------
            when SYNC_DEL       =>
            ----------------------
                -- =================================================================== --
                    
                -- =================================================================== --
            ----------------------
            when DATA           =>
            ----------------------
                -- =================================================================== --
                    
                -- =================================================================== --
            ----------------------
            when DATA_DEL       =>
            ----------------------
                -- =================================================================== --
                    
                -- =================================================================== --
        end case;
        
    end if;
end process;
    
end Behavioral;