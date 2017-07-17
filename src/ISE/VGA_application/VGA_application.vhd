library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_application is
Port(   CLK                     : in    std_logic;
        
        VGA_VSYNC               : out   std_logic;
        VGA_HSYNC               : out   std_logic;
        VGA_RED                 : out   std_logic_vector(4 downto 0);
        VGA_GREEN               : out   std_logic_vector(5 downto 0);
        VGA_BLUE                : out   std_logic_vector(4 downto 0));
end VGA_application;

architecture Behavioral of VGA_application is
component clk_gen
Port(   clk_in1                 : in    std_logic;
        CLK_out1                : out   std_logic);
end component;

component bram_plane
Port(   clk                     : in    std_logic;
        addr                    : in    std_logic_vector(9 downto 0);
        dout                    : out   std_logic_vector(23 downto 0));
end component;

signal clk_vga                  : std_logic := '0';
signal addr                     : std_logic_vector(9 downto 0)  := (others => '0');
signal bram_data                : std_logic_vector(23 downto 0) := (others => '0');

type t_state                    is (SYNC, SYNC_DEL, DATA, DATA_DEL); 
signal v_state                  : t_state   := SYNC;
signal h_state                  : t_state   := SYNC;

signal s_vga_vsync              : std_logic := '1';
signal s_vga_hsync              : std_logic := '1';
signal s_vga_red                : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_green              : std_logic_vector(7 downto 0)  := X"00";
signal s_vga_blue               : std_logic_vector(7 downto 0)  := X"00";

signal c_vga_vsync              : integer   := 0;
signal c_vga_hsync              : integer   := 0;

begin
clk_gen_vga: clk_gen
Port map(clk_in1                => CLK,
         clk_out1               => clk_vga);
         
bram_plane_vga: bram_plane
Port map(clk                    => clk_vga,
         addr                   => addr,
         dout                   => bram_data);

process(clk_vga)
begin
    if(rising_edge(clk_vga)) then
        case v_state is
            when SYNC       =>
                if(c_vga_vsync = 5) then
                    c_vga_vsync <= 0;
                    v_state     <= SYNC_DEL;
                    s_vga_vsync <= '1';
                else
                    c_vga_vsync <= c_vga_vsync + 1;
                end if;
            when SYNC_DEL   =>
                if(c_vga_vsync = 28) then
                    c_vga_vsync <= 0;
                    v_state     <= DATA;
                else
                    c_vga_vsync <= c_vga_vsync + 1;
                end if;
            when DATA       =>
                if(c_vga_vsync = 767) then
                    c_vga_vsync <= 0;
                    v_state     <= DATA_DEL;
                else
                    c_vga_vsync <= c_vga_vsync + 1;
                end if;
            when DATA_DEL   =>
                if(c_vga_vsync = 2) then
                    c_vga_vsync <= 0;
                    v_state     <= SYNC;
                    s_vga_vsync <= '0';
                else
                    c_vga_vsync <= c_vga_vsync + 1;
                end if;
        end case;
        
        case h_state is
            when SYNC       =>
                s_vga_red   <= X"00";
                s_vga_green <= X"00";
                s_vga_blue  <= X"00";
                
                if(c_vga_hsync = 137) then
                    c_vga_hsync <= 0;
                    h_state     <= SYNC_DEL;
                    s_vga_hsync <= '1';
                else
                    c_vga_hsync <= c_vga_hsync + 1;
                end if;
            when SYNC_DEL   =>
                s_vga_red   <= X"00";
                s_vga_green <= X"00";
                s_vga_blue  <= X"00";
                
                if(c_vga_hsync = 161) then
                    c_vga_hsync <= 0;
                    h_state     <= DATA;
                    s_vga_hsync <= '1';
                else
                    c_vga_hsync <= c_vga_hsync + 1;
                end if;
            when DATA       =>
                if(c_vga_hsync = 1023) then
                    c_vga_hsync <= 0;
                    h_state     <= DATA_DEL;
                    s_vga_hsync <= '1';
                else
                    c_vga_hsync <= c_vga_hsync + 1;
                end if;
                
                -- и вот здесь я буду писать основной код
                if(v_state /= DATA) then
                    s_vga_red   <= X"00";
                    s_vga_green <= X"00";
                    s_vga_blue  <= X"00";
                else
                
                end if;
                
            when DATA_DEL   =>
                s_vga_red   <= X"00";
                s_vga_green <= X"00";
                s_vga_blue  <= X"00";
                
                if(c_vga_hsync = 25) then
                    c_vga_hsync <= 0;
                    h_state     <= SYNC;
                    s_vga_hsync <= '0';
                else
                    c_vga_hsync <= c_vga_hsync + 1;
                end if;
        end case;
    end if;
end process;

end Behavioral;