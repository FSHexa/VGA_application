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
        VGA_RED                     : out   std_logic_vector(7 downto 0);
        VGA_GREEN                   : out   std_logic_vector(7 downto 0);
        VGA_BLUE                    : out   std_logic_vector(7 downto 0));
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

signal end_string                   : std_logic := '0';
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
VGA_VSYNC   <= s_vga_vsync;
VGA_HSYNC   <= s_vga_hsync;
VGA_RED     <= s_vga_red;
VGA_GREEN   <= s_vga_green;
VGA_BLUE    <= s_vga_blue;

-- ==================================================== --
-- Process info                                         --
-- ==================================================== --
process(VGA_BRAM_clk)
begin
    if(rising_edge(VGA_BRAM_clk)) then
        if(end_string = '1') then
            case v_state is
                ----------------------
                when SYNC           =>
                ----------------------
                    -- =================================================================== --
                        if(c_vga_vsync = 5) then
                            c_vga_vsync <= 0;
                            v_state     <= SYNC_DEL;
                            s_vga_vsync <= '1';
                        else
                            c_vga_vsync <= c_vga_vsync + 1;
                        end if;
                    -- =================================================================== --
                ----------------------
                when SYNC_DEL       =>
                ----------------------
                    -- =================================================================== --
                        if(c_vga_vsync = 28) then
                            c_vga_vsync <= 0;
                            v_state     <= DATA;
                        else
                            c_vga_vsync <= c_vga_vsync + 1;
                        end if;
                    -- =================================================================== --
                ----------------------
                when DATA           =>
                ----------------------
                    -- =================================================================== --
                        if(c_vga_vsync = 767) then
                            c_vga_vsync <= 0;
                            v_state     <= DATA_DEL;
                        else
                            c_vga_vsync <= c_vga_vsync + 1;
                        end if;
                    -- =================================================================== --
                ----------------------
                when DATA_DEL       =>
                ----------------------
                    -- =================================================================== --
                        if(c_vga_vsync = 2) then
                            c_vga_vsync <= 0;
                            v_state     <= SYNC;
                            s_vga_vsync <= '0';
                        else
                            c_vga_vsync <= c_vga_vsync + 1;
                        end if;
                    -- =================================================================== --
            end case;
        end if;
        
        case h_state is
            ----------------------
            when SYNC           =>
            ----------------------
                -- =================================================================== --
                    s_vga_red   <= X"00";
                    s_vga_green <= X"00";
                    s_vga_blue  <= X"00";
                    
                    if(c_vga_hsync = 136) then
                        c_vga_hsync <= 0;
                        h_state     <= SYNC_DEL;
                        s_vga_hsync <= '1';
                    else
                        c_vga_hsync <= c_vga_hsync + 1;
                    end if;
                -- =================================================================== --
            ----------------------
            when SYNC_DEL       =>
            ----------------------
                -- =================================================================== --
                    s_vga_red   <= X"00";
                    s_vga_green <= X"00";
                    s_vga_blue  <= X"00";
                    
                    if(c_vga_hsync = 162) then
                        c_vga_hsync <= 0;
                        h_state     <= DATA;
                        s_vga_hsync <= '1';
                    else
                        c_vga_hsync <= c_vga_hsync + 1;
                    end if;
                -- =================================================================== --
            ----------------------
            when DATA           =>
            ----------------------
                -- =================================================================== --
                    if(c_vga_hsync = 1023) then
                        c_vga_hsync <= 0;
                        h_state     <= DATA_DEL;
                        s_vga_hsync <= '1';
                    else
                        c_vga_hsync <= c_vga_hsync + 1;
                    end if;
                    
                    -- if(v_state /= DATA) then                                     -- править
                        -- s_vga_red   <= X"00";
                        -- s_vga_green <= X"00";
                        -- s_vga_blue  <= X"00";
                    -- else
                        -- if(write_data = '0') then
                            -- s_vga_red   <= data_vga_1(c_vga_hsync)(23 downto 16);
                            -- s_vga_green <= data_vga_1(c_vga_hsync)(15 downto 8);
                            -- s_vga_blue  <= data_vga_1(c_vga_hsync)(7 downto 0);
                        -- else
                            -- s_vga_red   <= data_vga_2(c_vga_hsync)(23 downto 16);
                            -- s_vga_green <= data_vga_2(c_vga_hsync)(15 downto 8);
                            -- s_vga_blue  <= data_vga_2(c_vga_hsync)(7 downto 0);
                        -- end if;
                    -- end if;
                -- =================================================================== --
            ----------------------
            when DATA_DEL       =>
            ----------------------
                -- =================================================================== --
                    s_vga_red   <= X"00";
                    s_vga_green <= X"00";
                    s_vga_blue  <= X"00";
                    
                    if(c_vga_hsync = 25) then
                        c_vga_hsync <= 0;
                        end_string  <= '0';
                        h_state     <= SYNC;
                        s_vga_hsync <= '0';
                        if(c_write_data = 7) then
                            write_data  <= not(write_data);                     -- править
                            c_write_data<= 0;
                        else
                            c_write_data    <= c_write_data + 1;
                        end if;
                    else
                        c_vga_hsync <= c_vga_hsync + 1;
                        if(c_vga_hsync = 24) then
                            end_string  <= '1';
                        end if;
                    end if;
                -- =================================================================== --
        end case;
    end if;
end process;
    
end Behavioral;