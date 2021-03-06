-- ============================================================================================================= --
-- ��������     : VGA_Generate
-- ������       : VGA_application
-- ������       : 1.0.0
-- �����        : FSS
-- ��������     : FSHexa
-- ����         : VGA_Generate.vhd
-- �������      : 24.07.2017
-- ------------------------------------------------------------------------------------------------------------- --
-- �������� �����:
--      ��������� �������������� ��� VGA � ������� ������.
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
end VGA_Generate;

architecture Behavioral of VGA_Generate is
-- ============================================================================ --
--                                  Components                                  --
-- ============================================================================ --
component VGA_BRAM
port(   clka                        : in    std_logic;
        ena                         : in    std_logic;
        wea                         : in    std_logic_vector(0 downto 0);
        addra                       : in    std_logic_vector(10 downto 0);
        dina                        : in    std_logic_vector(23 downto 0);
        
        clkb                        : in    std_logic;
        enb                         : in    std_logic;
        addrb                       : in    std_logic_vector(10 downto 0);
        doutb                       : out   std_logic_vector(23 downto 0));
end component;
-- ============================================================================ --
--                                    Signal                                    --
-- ============================================================================ --
signal not_vga_bram_clk             : std_logic := '0';
signal str_bram_en                  : std_logic := '0';
signal str_bram_addr                : std_logic_vector(10 downto 0) := (others => '0');
signal s_str_bram_addr              : std_logic_vector(9 downto 0)  := (others => '0');
signal f_str_bram_addr              : std_logic := '0';
signal str_bram_dout                : std_logic_vector(23 downto 0) := (others => '0');

signal s_vga_vsync                  : std_logic := '1';
signal s_vga_hsync                  : std_logic := '1';
signal s_vga_red                    : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_green                  : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_blue                   : std_logic_vector(7 downto 0)  := X"00";

type t_data_vga                     is array (0 to 1023)  of std_logic_vector (23 downto 0);
signal data_vga_1                   : t_data_vga    := (others => X"053F61");
signal data_vga_2                   : t_data_vga    := (others => X"7F7F7F");
-- ==================================================== --
-- Vertical_sync
-- ---------------------------------------------------- --
type t_state                        is (SYNC, SYNC_DEL, DATA, DATA_DEL);
signal v_state                      : t_state   := SYNC;
signal h_state                      : t_state   := SYNC;

signal c_vga_vsync                  : integer range 0 to 1000 := 0;
signal c_vga_hsync                  : integer range 0 to 1500 := 0;

signal end_string                   : std_logic := '0';
signal write_data                   : std_logic := '0';
signal c_write_data                 : integer   := 0;

signal s_end_frame                  : std_logic := '0';
signal s_busy_memory                : std_logic := '0';
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
            wea                     => VGA_BRAM_we,
            addra                   => VGA_BRAM_addr,
            dina                    => VGA_BRAM_din,
            
            clkb                    => not_vga_bram_clk,
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

not_vga_bram_clk    <= not(CLK);
str_bram_addr   <= f_str_bram_addr & s_str_bram_addr;

END_FRAME   <= s_end_frame;
BUSY_MEMORY <= s_busy_memory;
-- ==================================================== --
-- Process info                                         --
-- ==================================================== --
process(CLK)
begin
    if(rising_edge(CLK)) then
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
                            c_vga_vsync     <= 0;
                            v_state         <= DATA;
                            f_str_bram_addr <= '0';
                        else
                            c_vga_vsync     <= c_vga_vsync + 1;
                            if(c_vga_vsync = 27) then
                                s_end_frame <= '1';
                            end if;
                        end if;
                    -- =================================================================== --
                ----------------------
                when DATA           =>
                ----------------------
                    -- =================================================================== --
                        if(c_vga_vsync = 767) then
                            c_vga_vsync     <= 0;
                            v_state         <= DATA_DEL;
                            s_end_frame     <= '0';
                            f_str_bram_addr <= not(f_str_bram_addr);
                        else
                            c_vga_vsync     <= c_vga_vsync + 1;
                            f_str_bram_addr <= not(f_str_bram_addr);
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
                    
                    if(c_vga_hsync = 135) then
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
                    
                    if(c_vga_hsync = 159) then
                        c_vga_hsync     <= 0;
                        h_state         <= DATA;
                        s_busy_memory   <= '1';
                        s_vga_hsync     <= '1';
                        str_bram_en     <= '1';
                        s_str_bram_addr   <= (others => '0');
                    else
                        c_vga_hsync <= c_vga_hsync + 1;
                    end if;
                -- =================================================================== --
            ----------------------
            when DATA           =>
            ----------------------
                -- =================================================================== --
                    if(c_vga_hsync = 1023) then
                        c_vga_hsync     <= 0;
                        h_state         <= DATA_DEL;
                        s_busy_memory   <= '0';
                        s_vga_hsync     <= '1';
                    else
                        c_vga_hsync     <= c_vga_hsync + 1;
                        s_str_bram_addr <= s_str_bram_addr + 1;
                    end if;
                    
                    if(v_state /= DATA) then
                        s_vga_red   <= X"00";
                        s_vga_green <= X"00";
                        s_vga_blue  <= X"00";
                    else
                        s_vga_red   <= str_bram_dout(23 downto 16);
                        s_vga_green <= str_bram_dout(15 downto 8);
                        s_vga_blue  <= str_bram_dout(7 downto 0);
                    end if;
                -- =================================================================== --
            ----------------------
            when DATA_DEL       =>
            ----------------------
                -- =================================================================== --
                    s_vga_red   <= X"00";
                    s_vga_green <= X"00";
                    s_vga_blue  <= X"00";
                    
                    if(c_vga_hsync = 23) then
                        c_vga_hsync <= 0;
                        end_string  <= '0';
                        h_state     <= SYNC;
                        s_vga_hsync <= '0';
                    else
                        c_vga_hsync <= c_vga_hsync + 1;
                        if(c_vga_hsync = 22) then
                            end_string  <= '1';
                        end if;
                    end if;
                -- =================================================================== --
        end case;
    end if;
end process;
    
end Behavioral;