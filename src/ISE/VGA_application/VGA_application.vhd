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

-- component bram_plane
-- Port(   clk                     : in    std_logic;
        -- addr                    : in    std_logic_vector(9 downto 0);
        -- dout                    : out   std_logic_vector(23 downto 0));
-- end component;

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

type t_data_vga                 is array (0 to 1023)  of std_logic_vector (23 downto 0);
signal data_vga_1               : t_data_vga    := (others => X"053F61");
signal data_vga_2               : t_data_vga    := (others => X"7F7F7F");

signal end_string               : std_logic := '0';
signal write_data               : std_logic := '0';
signal c_write_data             : integer   := 0;

begin
clk_gen_vga: clk_gen
Port map(clk_in1                => CLK,
         clk_out1               => clk_vga);
         
-- bram_plane_vga: bram_plane
-- Port map(clk                    => clk_vga,
         -- addr                   => addr,
         -- dout                   => bram_data);

VGA_VSYNC   <= s_vga_vsync;
VGA_HSYNC   <= s_vga_hsync;
VGA_RED     <= s_vga_red(4 downto 0);
VGA_GREEN   <= s_vga_green(5 downto 0);
VGA_BLUE    <= s_vga_blue(4 downto 0);

process(clk_vga)
begin
    if(rising_edge(clk_vga)) then
        if(end_string = '1') then
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
        end if;
        
        case h_state is
            when SYNC       =>
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
            when SYNC_DEL   =>
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
            when DATA       =>
                if(c_vga_hsync = 1023) then
                    c_vga_hsync <= 0;
                    h_state     <= DATA_DEL;
                    s_vga_hsync <= '1';
                else
                    c_vga_hsync <= c_vga_hsync + 1;
                end if;
                
                if(v_state /= DATA) then
                    s_vga_red   <= X"00";
                    s_vga_green <= X"00";
                    s_vga_blue  <= X"00";
                else
                    if(write_data = '0') then
                        s_vga_red   <= data_vga_1(c_vga_hsync)(23 downto 16);
                        s_vga_green <= data_vga_1(c_vga_hsync)(15 downto 8);
                        s_vga_blue  <= data_vga_1(c_vga_hsync)(7 downto 0);
                    else
                        s_vga_red   <= data_vga_2(c_vga_hsync)(23 downto 16);
                        s_vga_green <= data_vga_2(c_vga_hsync)(15 downto 8);
                        s_vga_blue  <= data_vga_2(c_vga_hsync)(7 downto 0);
                    end if;
                end if;
                
            when DATA_DEL   =>
                s_vga_red   <= X"00";
                s_vga_green <= X"00";
                s_vga_blue  <= X"00";
                
                if(c_vga_hsync = 25) then
                    c_vga_hsync <= 0;
                    end_string  <= '0';
                    h_state     <= SYNC;
                    s_vga_hsync <= '0';
                    if(c_write_data = 7) then
                        write_data  <= not(write_data);
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
        end case;
    end if;
end process;

end Behavioral;